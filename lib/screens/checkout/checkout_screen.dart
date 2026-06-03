import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;

import 'package:moona/screens/checkout/payment_dialog.dart';
import 'package:moona/utils/resources/app_colors.dart';
import 'package:moona/utils/widgets/snackbar/failed_snackbar.dart';

import '../../managers/server/cart/cart_api.dart';
import '../../utils/helper/navigation/push_to.dart';
import '../../utils/widgets/currency.dart';
import '../addresses/data/entities/address_entity.dart';
import '../addresses/presentation/cubit/addresses_cubit.dart';
import '../addresses/presentation/cubit/addresses_state.dart';
import '../addresses/presentation/screens/add_address_screen.dart';
import '../addresses/presentation/screens/dialog/addresses_dialog.dart';
import '../addresses/presentation/screens/widgets/address_card_shimmer.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool checkoutLoading = false;
  String type = 'delivery';
  String time = 'now';
  double totalAmount = 0;
  String executionTimeTime = '';
  DateTime? executionTime;

  String selectedPaymentMethod = 'credit_card';

  bool _isApple = false;
  bool _isAndroid = false;

  @override
  void initState() {
    super.initState();
    context.read<AddressesCubit>().loadAddresses();
    _checkDeviceInfo();
  }

  void _checkDeviceInfo() {
    if (Platform.isIOS) {
      _isApple = true;
    } else if (Platform.isAndroid) {
      _isAndroid = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kScaffoldBackground,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            // icon: SvgPicture.asset('assets/images/arrow-right.svg'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text(
            'إتمام الطلب',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    /// ================= ORDER SUMMARY =================
                    const _SectionTitle(
                      title: 'ملخص الطلب',
                      icon: Icons.receipt_long,
                    ),

                    FutureBuilder<CartSummury>(
                      future: CartApi.summary(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 120,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!snapshot.hasData) return const SizedBox();

                        totalAmount = snapshot.data!.grandTotal;
                        return OrderSummaryCard(summary: snapshot.data!);
                      },
                    ),

                    const SizedBox(height: 20),

                    /// ================= DELIVERY TIME =================
                    _Section(
                      title: 'وقت التوصيل',
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w800,
                      ),
                      child: _SegmentedRow(
                        leftText: "توصيل مباشرة",
                        rightText: executionTime != null
                            ? executionTimeTime
                            : "وقت لاحق",
                        leftSelected: time == 'now',
                        onLeft: () => setState(() => time = 'now'),
                        onRight: () async {
                          setState(() => time = 'later');
                          DatePicker.showDateTimePicker(
                            context,
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                            onConfirm: (date) {
                              setState(() {
                                executionTime = date;
                                executionTimeTime = intl.DateFormat(
                                  'yyyy-MM-dd / HH:mm',
                                ).format(date);
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// ================= ADDRESS =================
                    const _SectionTitle(
                      title: 'عنوان التوصيل',
                      icon: Icons.location_on_outlined,
                    ),

                    BlocBuilder<AddressesCubit, AddressesState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case AddressesStatus.loading:
                            return const AddressCardShimmer();

                          case AddressesStatus.error:
                            return _ErrorBox(
                              message: state.errorMessage ?? 'حدث خطأ',
                            );

                          case AddressesStatus.loaded:
                            if (state.addresses.isEmpty) {
                              return _InfoBox(
                                icon: Icons.location_off_outlined,
                                text: 'لا يوجد عناوين مسجلة',
                                actionText: 'إضافة عنوان',
                                onTap: () {},
                              );
                            }

                            final AddressEntity selectedAddress = state
                                .addresses
                                .firstWhere(
                                  (e) => e.isDefault,
                                  orElse: () => state.addresses.first,
                                );

                            return DeliveryLocationCard(
                              address: selectedAddress,
                              onChange: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => const AddressesDialog(),
                                );
                              },
                            );

                          default:
                            return const SizedBox();
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    /// ================= PAYMENT METHOD =================
                    const _SectionTitle(
                      title: 'طريقة الدفع',
                      icon: Icons.account_balance_wallet_outlined,
                    ),

                    _PaymentOptionTile(
                      title: 'البطاقة الائتمانية / مدى',
                      icons: [
                        SvgPicture.asset('assets/images/visa.svg', width: 32),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/images/mastercard.svg',
                          width: 32,
                        ),
                        const SizedBox(width: 4),
                        Image.asset('assets/images/mada.png', width: 32),
                      ],
                      isSelected: selectedPaymentMethod == 'credit_card',
                      onTap: () =>
                          setState(() => selectedPaymentMethod = 'credit_card'),
                    ),

                    if (_isApple) ...[
                      const SizedBox(height: 10),
                      _PaymentOptionTile(
                        title: 'Apple Pay',
                        icons: [
                          Image.asset('assets/images/apple-pay.png', width: 40),
                        ],
                        isSelected: selectedPaymentMethod == 'apple_pay',
                        onTap: () =>
                            setState(() => selectedPaymentMethod = 'apple_pay'),
                      ),
                    ],

                    if (_isAndroid) ...[
                      const SizedBox(height: 10),

                      // _PaymentOptionTile(
                      //   title: 'Samsung Pay',
                      //   icons: [
                      //     SvgPicture.asset(
                      //       'assets/images/samsung-pay.svg',
                      //       width: 40,
                      //     ),
                      //   ],
                      //   isSelected: selectedPaymentMethod == 'samsung_pay',
                      //   onTap: () => setState(
                      //     () => selectedPaymentMethod = 'samsung_pay',
                      //   ),
                      // ),
                    ],
                  ],
                ),
              ),

              /// ================= CONFIRM BUTTON =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: kMainColor.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: checkoutLoading
                        ? null
                        : () async {
                            final state = context.read<AddressesCubit>().state;

                            if (state.status != AddressesStatus.loaded ||
                                state.addresses.isEmpty) {
                              showFailedTopSnackBar(
                                context: context,
                                title: 'الرجاء اختيار عنوان',
                                content: '',
                              );
                              return;
                            }
                            if (time != 'now' && executionTime == null) {
                              showFailedTopSnackBar(
                                context: context,
                                title: 'الرجاء اختيار وقت التوصيل',
                                content: '',
                              );
                              return;
                            }

                            final selectedAddress = state.addresses.firstWhere(
                              (e) => e.isDefault,
                              orElse: () => state.addresses.first,
                            );

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PaymentBottomSheet(
                                amount: totalAmount,
                                selectedAddress: selectedAddress,
                                executionTime: executionTime,
                                selectedMethod: selectedPaymentMethod,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: checkoutLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تأكيد الطلب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== NEW PAYMENT OPTION WIDGET =====================
class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final List<Widget> icons;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.icons,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? kMainColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kMainColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? kMainColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(children: icons),
          ],
        ),
      ),
    );
  }
}

/// ===================== ORDER SUMMARY =====================

class OrderSummaryCard extends StatelessWidget {
  final CartSummury summary;

  const OrderSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SummaryRow(
            'عدد المنتجات',
            summary.totalItems.toString(),
            showCurrency: false,
          ),
          const SizedBox(height: 10),
          _SummaryRow('سعر المنتجات', '${summary.productsTotal}', bold: true),
          const SizedBox(height: 10),
          _SummaryRow(
            'رسوم التوصيل',
            summary.deliveryFee == 0 ? 'توصيل مجاني' : '${summary.deliveryFee}',
          ),
          if (summary.discountTotal > 0) ...[
            const SizedBox(height: 10),
            _SummaryRow('الخصم', '- ${summary.discountTotal}'),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _SummaryRow(
            'الإجمالي',
            '${summary.grandTotal}',
            bold: true,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

/// ===================== DELIVERY LOCATION =====================

class DeliveryLocationCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback? onChange;

  const DeliveryLocationCard({super.key, required this.address, this.onChange});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: kMainColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined, color: kMainColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.addressName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildFullAddress(address),
                  style: const TextStyle(fontSize: 13, color: kSubtitleColor),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('تغيير', style: TextStyle(color: kMainColor)),
          ),
        ],
      ),
    );
  }

  String _buildFullAddress(AddressEntity a) {
    List<String> parts = [];

    parts.add(a.locationName);

    if (a.buildingName != null && a.buildingName!.isNotEmpty) {
      parts.add(a.buildingName!);
    }

    if (a.floor != null && a.floor!.isNotEmpty) {
      parts.add('الدور ${a.floor}');
    }

    return parts.join('، ');
  }
}

/// ===================== SHARED UI =====================

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: kMainColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kMainColor.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool highlight;
  final bool showCurrency;

  const _SummaryRow(
    this.label,
    this.value, {
    this.bold = false,
    this.highlight = false,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 18 : 16,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: label == 'الخصم'
                ? Colors.red
                : highlight
                ? kMainColor
                : kTitleBodyColor,
            fontSize: highlight ? 22 : 16,
          ),
        ),
        if (showCurrency && value != 'توصيل مجاني')
          Currency(isRed: label == 'الخصم'),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'DINNextLT',
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.actionText,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kMainColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: kMainColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'DINNextLT',
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => pushTo(context, AddAddressScreen(add: true)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kMainColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontFamily: 'DINNextLT',
                    fontSize: 12,
                    color: kMainColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.titleStyle,
    required this.child,
  });

  final String title;
  final TextStyle titleStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_sharp, color: kMainColor, size: 16),
            const SizedBox(width: 4),
            Text(title, style: titleStyle),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  const _SegmentedRow({
    required this.leftText,
    required this.rightText,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String leftText;
  final String rightText;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              text: leftText,
              selected: leftSelected,
              onTap: onLeft,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SegBtn(
              text: rightText,
              selected: !leftSelected,
              onTap: onRight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kMainColor.withOpacity(0.12) : kScaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kMainColor.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: selected ? kMainColor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
