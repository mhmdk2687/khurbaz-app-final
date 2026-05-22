import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart';

import 'package:moona/screens/checkout/success_dialog.dart';
import '../../managers/server/payment_service.dart';
import '../addresses/data/entities/address_entity.dart';
// import '../../utils/resources/app_colors.dart';

class PaymentBottomSheet extends StatefulWidget {
  const PaymentBottomSheet({
    super.key,
    required this.amount,
    required this.selectedAddress,
    required this.executionTime,
    required this.selectedMethod, // 'credit_card', 'apple_pay', or 'samsung_pay'
  });

  final double amount;
  final DateTime? executionTime;
  final AddressEntity selectedAddress;
  final String selectedMethod;

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  late final paymentConfig = PaymentConfig(
    publishableApiKey: 'pk_live_8eupn7AcS3FneiZkE9SWNXmVgjH3684FNhUZEuNY',
    amount: (widget.amount * 100).toInt(),
    description: 'khurbaz Order',
    creditCard: CreditCardConfig(saveCard: true, manual: false),
    applePay: ApplePayConfig(
      merchantId: 'merchant.com.khurbaz',
      label: 'khurbaz',
      manual: false,
      saveCard: true,
    ),
    // أضف إعدادات Samsung Pay هنا إذا كانت مدعومة في نسختك المخصصة من البكج
    samsungPay: SamsungPayConfig(
      serviceId: '0a2ffd0de3e141d3a52671',
      merchantName: 'SamsungPay-khurbaz',
      manual: false,
    ),
  );

  void showFail(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> onPaid(PaymentResponse result) async {
    String moyasarId = result.id;
    String paymentMethod = "";

    try {
      paymentMethod = result.source.company ?? "online";
    } catch (e) {
      paymentMethod = "online";
    }

    final paymentService = PaymentService();

    final response = await paymentService.checkout(
      executionTime: widget.executionTime,
      moyasarId: moyasarId,
      paymentMethod: paymentMethod,
      addressId: widget.selectedAddress.id.toString(),
    );

    if (!mounted) return;

    if (!response['success']) {
      showFail(response.toString());
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "main", (route) => false);

      showDialog(
        context: context,
        builder: (_) => SuccessDialog(orderId: response['order_id']),
      );
    }
    debugPrint("Checkout Response: $response");
  }

  void onPaymentResult(dynamic result) async {
    if (result is PaymentResponse) {
      if (result.status == PaymentStatus.paid) {
        onPaid(result);
      } else if (result.status == PaymentStatus.failed) {
        debugPrint("❌ Payment FAILED");
        showFail('فشلت عملية الدفع، يرجى المحاولة مرة أخرى');
      } else if (result.status == PaymentStatus.initiated) {
        debugPrint("⏳ Payment INITIATED");
        showFail("⏳ جاري بدء الدفع");
      } else if (result.status == PaymentStatus.authorized) {
        debugPrint("🔐 Payment AUTHORIZED");
        showFail("🔐 تم التحقق من الدفع");
      } else {
        debugPrint("⚠️ Unknown Status: ${result.status}");
        showFail("⚠️ حالة غير معروفة: ${result.status}");
      }
    } else if (result is PaymentCanceledError) {
      debugPrint("🔥 Unexpected result: message ${result.message}");
      showFail('تم إلغاء عملية الدفع');
    } else {
      debugPrint("🔥 Unexpected result: $result");
      showFail('حدث خطأ غير متوقع');
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد الارتفاع المطلوب (البطاقة الائتمانية تحتاج مساحة أكبر من أزرار Apple/Samsung Pay)
    final heightFactor = widget.selectedMethod == 'credit_card' ? 0.85 : 0.4;

    // تحديد عنوان الـ BottomSheet
    String getTitle() {
      if (widget.selectedMethod == 'credit_card') return "بيانات البطاقة";
      if (widget.selectedMethod == 'samsung_pay')
        return "الدفع بواسطة Samsung Pay";
      return "الدفع بواسطة Apple Pay"; // default for apple_pay
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * heightFactor,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              getTitle(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  children: [
                    if (widget.selectedMethod == 'credit_card') ...[
                      CreditCard(
                        config: paymentConfig,
                        onPaymentResult: onPaymentResult,
                        locale: Localization.ar(),
                      ),
                    ] else if (widget.selectedMethod == 'samsung_pay') ...[
                      const SizedBox(height: 20),
                      // تأكد أن ويدجت SamsungPay متاح في نسختك من مكتبة ميسر
                      SamsungPay(
                        config: paymentConfig,
                        onPaymentResult: onPaymentResult,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "سيتم خصم المبلغ بأمان عبر Samsung Pay",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      ApplePay(
                        config: paymentConfig,
                        onPaymentResult: onPaymentResult,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "سيتم خصم المبلغ بأمان عبر Apple Pay",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
