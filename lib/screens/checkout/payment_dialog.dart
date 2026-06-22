// import 'package:flutter/material.dart';
// import 'package:moyasar/moyasar.dart';

// import 'package:moona/screens/checkout/success_dialog.dart';
// import '../../managers/server/payment_service.dart';
// import '../addresses/data/entities/address_entity.dart';
// // import '../../utils/resources/app_colors.dart';

// class PaymentBottomSheet extends StatefulWidget {
//   const PaymentBottomSheet({
//     super.key,
//     required this.amount,
//     required this.selectedAddress,
//     required this.executionTime,
//     required this.selectedMethod,
//     this.couponCode,
//   });

//   final double amount;
//   final DateTime? executionTime;
//   final AddressEntity selectedAddress;
//   final String selectedMethod;
//   final String? couponCode;

//   @override
//   State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
// }

// class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
//   late final paymentConfig = PaymentConfig(
//     publishableApiKey: 'pk_live_8eupn7AcS3FneiZkE9SWNXmVgjH3684FNhUZEuNY',
//     amount: (widget.amount * 100).toInt(),
//     description: 'khurbaz Order',
//     creditCard: CreditCardConfig(saveCard: true, manual: false),
//     applePay: ApplePayConfig(
//       merchantId: 'merchant.com.khurbaz',
//       label: 'khurbaz',
//       manual: false,
//       saveCard: true,
//     ),
//     // أضف إعدادات Samsung Pay هنا إذا كانت مدعومة في نسختك المخصصة من البكج
//     samsungPay: SamsungPayConfig(
//       serviceId: '0a2ffd0de3e141d3a52671',
//       merchantName: 'SamsungPay-khurbaz',
//       manual: false,
//     ),
//   );

//   void showFail(String text) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(text, style: const TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<void> onPaid(PaymentResponse result) async {
//     String moyasarId = result.id;
//     String paymentMethod = "";

//     try {
//       paymentMethod = result.source.company ?? "online";
//     } catch (e) {
//       paymentMethod = "online";
//     }

//     final paymentService = PaymentService();

//     final response = await paymentService.checkout(
//       executionTime: widget.executionTime,
//       moyasarId: moyasarId,
//       paymentMethod: paymentMethod,
//       addressId: widget.selectedAddress.id.toString(),
//       couponCode: widget.couponCode,
//     );
//     if (!mounted) return;

//     if (!response['success']) {
//       showFail(response.toString());
//     } else {
//       Navigator.pushNamedAndRemoveUntil(context, "main", (route) => false);

//       showDialog(
//         context: context,
//         builder: (_) => SuccessDialog(orderId: response['order_id']),
//       );
//     }
//     debugPrint("Checkout Response: $response");
//   }

//   void onPaymentResult(dynamic result) async {
//     if (result is PaymentResponse) {
//       if (result.status == PaymentStatus.paid) {
//         onPaid(result);
//       } else if (result.status == PaymentStatus.failed) {
//         debugPrint("❌ Payment FAILED");
//         showFail('فشلت عملية الدفع، يرجى المحاولة مرة أخرى');
//       } else if (result.status == PaymentStatus.initiated) {
//         debugPrint("⏳ Payment INITIATED");
//         showFail("⏳ جاري بدء الدفع");
//       } else if (result.status == PaymentStatus.authorized) {
//         debugPrint("🔐 Payment AUTHORIZED");
//         showFail("🔐 تم التحقق من الدفع");
//       } else {
//         debugPrint("⚠️ Unknown Status: ${result.status}");
//         showFail("⚠️ حالة غير معروفة: ${result.status}");
//       }
//     } else if (result is PaymentCanceledError) {
//       debugPrint("🔥 Unexpected result: message ${result.message}");
//       showFail('تم إلغاء عملية الدفع');
//     } else {
//       debugPrint("🔥 Unexpected result: $result");
//       showFail('حدث خطأ غير متوقع');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // تحديد الارتفاع المطلوب (البطاقة الائتمانية تحتاج مساحة أكبر من أزرار Apple/Samsung Pay)
//     final heightFactor = widget.selectedMethod == 'credit_card' ? 0.85 : 0.4;

//     // تحديد عنوان الـ BottomSheet
//     String getTitle() {
//       if (widget.selectedMethod == 'credit_card') return "بيانات البطاقة";
//       if (widget.selectedMethod == 'samsung_pay')
//         return "الدفع بواسطة Samsung Pay";
//       return "الدفع بواسطة Apple Pay"; // default for apple_pay
//     }

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         height: MediaQuery.of(context).size.height * heightFactor,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 12),
//             Container(
//               height: 5,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               getTitle(),
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(height: 30),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.only(
//                   left: 20,
//                   right: 20,
//                   bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//                 ),
//                 child: Column(
//                   children: [
//                     if (widget.selectedMethod == 'credit_card') ...[
//                       CreditCard(
//                         config: paymentConfig,
//                         onPaymentResult: onPaymentResult,
//                         locale: Localization.ar(),
//                       ),
//                     ] else if (widget.selectedMethod == 'samsung_pay') ...[
//                       const SizedBox(height: 20),
//                       // تأكد أن ويدجت SamsungPay متاح في نسختك من مكتبة ميسر
//                       SamsungPay(
//                         config: paymentConfig,
//                         onPaymentResult: onPaymentResult,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "سيتم خصم المبلغ بأمان عبر Samsung Pay",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ] else ...[
//                       const SizedBox(height: 20),
//                       ApplePay(
//                         config: paymentConfig,
//                         onPaymentResult: onPaymentResult,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "سيتم خصم المبلغ بأمان عبر Apple Pay",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // }  new  code
// import 'package:flutter/material.dart';
// import 'package:moyasar/moyasar.dart';

// import 'package:moona/screens/checkout/success_dialog.dart';
// import '../../managers/server/payment_service.dart';
// import '../addresses/data/entities/address_entity.dart';
// // import '../../utils/resources/app_colors.dart';

// class PaymentBottomSheet extends StatefulWidget {
//   const PaymentBottomSheet({
//     super.key,
//     required this.amount,
//     required this.selectedAddress,
//     required this.executionTime,
//     required this.selectedMethod,
//     this.couponCode,
//   });

//   final double amount;
//   final DateTime? executionTime;
//   final AddressEntity selectedAddress;
//   final String selectedMethod;
//   final String? couponCode;

//   @override
//   State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
// }

// class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
//   late final paymentConfig = PaymentConfig(
//     publishableApiKey: 'pk_live_8eupn7AcS3FneiZkE9SWNXmVgjH3684FNhUZEuNY',
//     amount: (widget.amount * 100).toInt(),
//     description: 'khurbaz Order',
//     creditCard: CreditCardConfig(saveCard: true, manual: false),
//     applePay: ApplePayConfig(
//       merchantId: 'merchant.com.khurbaz',
//       label: 'khurbaz',
//       manual: false,
//       saveCard: true,
//     ),
//     samsungPay: SamsungPayConfig(
//       serviceId: '0a2ffd0de3e141d3a52671',
//       merchantName: 'SamsungPay-khurbaz',
//       manual: false,
//     ),
//   );

//   void showFail(String text) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(text, style: const TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<void> onPaid(PaymentResponse result) async {
//     String moyasarId = result.id;
//     String paymentMethod = "";

//     try {
//       paymentMethod = result.source.company.name ?? "online";
//     } catch (e) {
//       paymentMethod = "online";
//     }
//     // --- NEW LOGIC FOR SAVING CARDS ---
//     String? cardBrand;
//     String? maskedCardNumber;
//     String? cardSourceId;

//     // If the user paid with a credit card, extract the safe details
//     if (result.source is CardPaymentResponseSource) {
//       final cardSource = result.source as CardPaymentResponseSource;

//       cardBrand = cardSource.company.name;
//       maskedCardNumber = cardSource.number;

//       // SAFE FIX: Since the source doesn't have an ID, we use the main Payment ID.
//       // Moyasar uses this original Payment ID as the token to charge the card in the future.
//       cardSourceId = moyasarId;
//     }
//     // ----------------------------------

//     final paymentService = PaymentService();

//     final response = await paymentService.checkout(
//       executionTime: widget.executionTime,
//       moyasarId: moyasarId,
//       paymentMethod: paymentMethod,
//       addressId: widget.selectedAddress.id.toString(),
//       couponCode: widget.couponCode,

//       // Pass the new data to your backend
//       cardBrand: cardBrand,
//       maskedCardNumber: maskedCardNumber,
//       cardSourceId: cardSourceId,
//     );

//     if (!mounted) return;

//     if (!response['success']) {
//       showFail(response.toString());
//     } else {
//       Navigator.pushNamedAndRemoveUntil(context, "main", (route) => false);

//       showDialog(
//         context: context,
//         builder: (_) => SuccessDialog(orderId: response['order_id']),
//       );
//     }
//     debugPrint("Checkout Response: $response");
//   }

//   void onPaymentResult(dynamic result) async {
//     if (result is PaymentResponse) {
//       if (result.status == PaymentStatus.paid) {
//         onPaid(result);
//       } else if (result.status == PaymentStatus.failed) {
//         debugPrint("❌ Payment FAILED");
//         showFail('فشلت عملية الدفع، يرجى المحاولة مرة أخرى');
//       } else if (result.status == PaymentStatus.initiated) {
//         debugPrint("⏳ Payment INITIATED");
//         showFail("⏳ جاري بدء الدفع");
//       } else if (result.status == PaymentStatus.authorized) {
//         debugPrint("🔐 Payment AUTHORIZED");
//         showFail("🔐 تم التحقق من الدفع");
//       } else {
//         debugPrint("⚠️ Unknown Status: ${result.status}");
//         showFail("⚠️ حالة غير معروفة: ${result.status}");
//       }
//     } else if (result is PaymentCanceledError) {
//       debugPrint("🔥 Unexpected result: message ${result.message}");
//       showFail('تم إلغاء عملية الدفع');
//     } else {
//       debugPrint("🔥 Unexpected result: $result");
//       showFail('حدث خطأ غير متوقع');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final heightFactor = widget.selectedMethod == 'credit_card' ? 0.85 : 0.4;

//     String getTitle() {
//       if (widget.selectedMethod == 'credit_card') return "بيانات البطاقة";
//       if (widget.selectedMethod == 'samsung_pay')
//         return "الدفع بواسطة Samsung Pay";
//       return "الدفع بواسطة Apple Pay";
//     }

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         height: MediaQuery.of(context).size.height * heightFactor,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           children: [
//             const SizedBox(height: 12),
//             Container(
//               height: 5,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               getTitle(),
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const Divider(height: 30),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.only(
//                   left: 20,
//                   right: 20,
//                   bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//                 ),
//                 child: Column(
//                   children: [
//                     if (widget.selectedMethod == 'credit_card') ...[
//                       CreditCard(
//                         config: paymentConfig,
//                         onPaymentResult: onPaymentResult,
//                         locale: Localization.ar(),
//                       ),
//                     ] else if (widget.selectedMethod == 'samsung_pay') ...[
//                       const SizedBox(height: 20),
//                       SamsungPay(
//                         config: paymentConfig,
//                         onPaymentResult: onPaymentResult,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "سيتم خصم المبلغ بأمان عبر Samsung Pay",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ] else ...[
//                       const SizedBox(height: 20),
//                       ApplePay(
//                         config: paymentConfig,
//                         onPaymentResult: onPaymentResult,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "سيتم خصم المبلغ بأمان عبر Apple Pay",
//                         style: TextStyle(color: Colors.grey, fontSize: 13),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    required this.selectedMethod,
    this.couponCode,
  });

  final double amount;
  final DateTime? executionTime;
  final AddressEntity selectedAddress;
  final String selectedMethod;
  final String? couponCode;

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  // --- متغيرات إدارة البطاقات المحفوظة ---
  bool isLoadingCards = true;
  List<dynamic> savedCards = [];
  bool showNewCardForm = false;
  bool isProcessingSavedCard = false;
  String? savedCardErrorMessage; // <-- تمت إضافة متغير لعرض رسالة الخطأ هنا
  // ------------------------------------

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
    samsungPay: SamsungPayConfig(
      serviceId: '0a2ffd0de3e141d3a52671',
      merchantName: 'SamsungPay-khurbaz',
      manual: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.selectedMethod == 'credit_card') {
      _fetchSavedCards();
    } else {
      setState(() => isLoadingCards = false);
    }
  }

  Future<void> _fetchSavedCards() async {
    final service = PaymentService();
    final cards = await service.getSavedCards();
    if (mounted) {
      setState(() {
        savedCards = cards;
        isLoadingCards = false;
        if (savedCards.isEmpty) showNewCardForm = true;
      });
    }
  }

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

  // ------------------------------------------------------------------------
  // الدفع عبر البطاقة المحفوظة
  // ------------------------------------------------------------------------
  Future<void> onPayWithSavedCard(String token) async {
    setState(() {
      isProcessingSavedCard = true;
      savedCardErrorMessage = null; // تصفير الخطأ عند بدء محاولة دفع جديدة
    });

    final paymentService = PaymentService();

    final response = await paymentService.checkoutWithSavedCard(
      addressId: widget.selectedAddress.id.toString(),
      savedCardToken: token,
      executionTime: widget.executionTime,
      couponCode: widget.couponCode,
    );

    if (!mounted) return;
    setState(() => isProcessingSavedCard = false);

    if (!response['success']) {
      // <-- التعديل هنا: عرض الخطأ داخل الواجهة بدلاً من الـ SnackBar
      setState(() {
        savedCardErrorMessage = response['message']?.toString() ??
            'تم رفض الدفع، يرجى المحاولة ببطاقة أخرى';
      });
    } else {
      Navigator.pushNamedAndRemoveUntil(context, "main", (route) => false);
      showDialog(
        context: context,
        builder: (_) => SuccessDialog(orderId: response['order_id']),
      );
    }
  }

  // ------------------------------------------------------------------------
  // حذف بطاقة محفوظة
// ------------------------------------------------------------------------
  // حذف بطاقة محفوظة (تعديل آمن للتوافق مع سيرفر لارافيل الحالي)
  // ------------------------------------------------------------------------
  Future<void> onDeleteCard(int cardId) async {
    setState(() => isProcessingSavedCard = true);

    final paymentService = PaymentService();
    final response = await paymentService.deleteSavedCard(cardId: cardId);

    if (!mounted) return;

    setState(() => isProcessingSavedCard = false);

    // التعديل: فحص 'status' ليتوافق مع لارافيل أو 'success' كخيار احتياطي
    if (response['status'] == true || response['success'] == true) {
      setState(() {
        // إزالة البطاقة من القائمة محلياً لتحديث الواجهة فوراً
        savedCards.removeWhere((card) => card['id'] == cardId);
        savedCardErrorMessage = null;
        if (savedCards.isEmpty) showNewCardForm = true;
      });
    } else {
      setState(() {
        savedCardErrorMessage =
            response['message']?.toString() ?? 'فشل حذف البطاقة';
      });
    }
  }

  // ------------------------------------------------------------------------
  // الدفع عبر إضافة بطاقة جديدة (تم ترك المنطق القديم تماماً كما هو)
  // ------------------------------------------------------------------------
  Future<void> onPaid(PaymentResponse result) async {
    String moyasarId = result.id;
    String paymentMethod = "";

    try {
      paymentMethod = result.source.company.name ?? "online";
    } catch (e) {
      paymentMethod = "online";
    }

    String? cardBrand;
    String? maskedCardNumber;
    String? cardSourceId;

    if (result.source is CardPaymentResponseSource) {
      final cardSource = result.source as CardPaymentResponseSource;

      cardBrand = cardSource.company.name;
      maskedCardNumber = cardSource.number;
      cardSourceId = moyasarId;
    }

    final paymentService = PaymentService();

    final response = await paymentService.checkout(
      executionTime: widget.executionTime,
      moyasarId: moyasarId,
      paymentMethod: paymentMethod,
      addressId: widget.selectedAddress.id.toString(),
      couponCode: widget.couponCode,
      cardBrand: cardBrand,
      maskedCardNumber: maskedCardNumber,
      cardSourceId: cardSourceId,
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
    final heightFactor = widget.selectedMethod == 'credit_card' ? 0.85 : 0.4;

    String getTitle() {
      if (widget.selectedMethod == 'credit_card') return "بيانات البطاقة";
      if (widget.selectedMethod == 'samsung_pay')
        return "الدفع بواسطة Samsung Pay";
      return "الدفع بواسطة Apple Pay";
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
                      // 1. حالة التحميل
                      if (isLoadingCards)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator())),

                      // 2. عرض البطاقات المحفوظة إن وُجدت
                      if (!isLoadingCards &&
                          savedCards.isNotEmpty &&
                          !showNewCardForm) ...[
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text("البطاقات المحفوظة",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(height: 10),

                        // <-- عرض رسالة الخطأ هنا إذا كانت موجودة
                        if (savedCardErrorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200)),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    savedCardErrorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ...savedCards.map((card) {
                          String brand =
                              card['card_name']?.toString().toUpperCase() ??
                                  "بطاقة";
                          String last4 =
                              card['last_four']?.toString() ?? "****";
                          String token = card['token']?.toString() ?? "";

                          // استخراج الـ id للحذف بأمان
                          int cardId = int.tryParse(card['id'].toString()) ?? 0;

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300)),
                            child: ListTile(
                              leading: const Icon(Icons.credit_card,
                                  color: Colors.blue),
                              title: Text("$brand تنتهي بـ $last4",
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.right),

                              // <-- إضافة أيقونة الحذف بجانب زر الدفع هنا
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: isProcessingSavedCard
                                        ? null
                                        : () => onDeleteCard(cardId),
                                  ),
                                  isProcessingSavedCard
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : ElevatedButton(
                                          onPressed: () =>
                                              onPayWithSavedCard(token),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white),
                                          child: const Text("ادفع"),
                                        ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("أو",
                                    style: TextStyle(color: Colors.grey))),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            showNewCardForm = true;
                            savedCardErrorMessage =
                                null; // إخفاء الخطأ عند الانتقال لبطاقة جديدة
                          }),
                          icon: const Icon(Icons.add),
                          label: const Text("الدفع ببطاقة جديدة"),
                        )
                      ],

                      // 3. عرض واجهة الدفع الأصلية للبطاقات الجديدة
                      if (!isLoadingCards && showNewCardForm) ...[
                        if (savedCards.isNotEmpty)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  setState(() => showNewCardForm = false),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text("العودة للبطاقات المحفوظة"),
                            ),
                          ),
                        CreditCard(
                          config: paymentConfig,
                          onPaymentResult: onPaymentResult,
                          locale: Localization.ar(),
                        ),
                      ],
                    ] else if (widget.selectedMethod == 'samsung_pay') ...[
                      const SizedBox(height: 20),
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
