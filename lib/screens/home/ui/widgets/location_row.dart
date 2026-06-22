import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/resources/app_colors.dart';
import '../../../addresses/presentation/cubit/addresses_cubit.dart';
import '../../../addresses/presentation/cubit/addresses_state.dart';
import '../../../addresses/presentation/screens/dialog/addresses_dialog.dart';

class LocationRow extends StatelessWidget {
  const LocationRow({super.key});

  // ==========================================
  // دالة لتحديد حالة خدمة التوصيل بناءً على الوقت
  // ==========================================
  bool get isDeliveryActive {
    final now = DateTime.now();
    // تحويل الوقت الحالي إلى دقائق تسهيلاً للمقارنة الدقيقة
    final currentMinutes = (now.hour * 60) + now.minute;

    if (now.weekday == DateTime.friday) {
      // يوم الجمعة: من 2:30 مساءً (14:30) حتى 12 منتصف الليل (24:00)
      final startMinutes = (14 * 60) + 30; // 870 دقيقة
      final endMinutes = 24 * 60; // 1440 دقيقة
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // باقي أيام الأسبوع: من 8:30 صباحاً حتى 12 منتصف الليل (24:00)
      final startMinutes = (8 * 60) + 30; // 510 دقائق
      final endMinutes = 24 * 60; // 1440 دقيقة
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return AddressesDialog();
            },
          );
        },
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: kSubtitleColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: BlocBuilder<AddressesCubit, AddressesState>(
                    builder: (context, state) {
                      switch (state.status) {
                        // =========================
                        // Loading
                        // =========================
                        case AddressesStatus.loading:
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 10,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 10,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          );

                        // =========================
                        // Loaded
                        // =========================
                        case AddressesStatus.loaded:
                          final address = state.addresses.isNotEmpty
                              ? state.addresses.first
                              : null;

                          return SizedBox(
                            height: 40,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  address == null
                                      ? 'إضافة عنوان'
                                      : address.addressName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                if (address != null)
                                  Text(
                                    address.locationName,
                                    maxLines: 1, // حماية إضافية لمنع تجاوز النص
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      height: 1,
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          );

                        // =========================
                        // Error
                        // =========================
                        case AddressesStatus.error:
                          return const SizedBox.shrink();

                        // =========================
                        // Initial
                        // =========================
                        case AddressesStatus.initial:
                        default:
                          return const SizedBox();
                      }
                    },
                  ),
                ),

                // ==========================================
                // شارة مؤشر التوصيل المضافة حديثاً
                // ==========================================
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 18,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: isDeliveryActive
                            ? Text(
                                'اطلب الان',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              )
                            : Text(
                                ' جدولة الطلب',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                      const SizedBox(width: 6),
                      _AnimatedStatusDot(
                        active: isDeliveryActive,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // ==========================================

                Icon(Icons.keyboard_arrow_down, color: kSubtitleColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatusDot extends StatefulWidget {
  final bool active;

  const _AnimatedStatusDot({
    required this.active,
  });

  @override
  State<_AnimatedStatusDot> createState() => _AnimatedStatusDotState();
}

class _AnimatedStatusDotState extends State<_AnimatedStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;

        final animatedColor = Color.lerp(
          const Color(0xFF10B981),
          const Color(0xFF4ADE80),
          value,
        );

        return Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.active ? animatedColor : Colors.grey.shade400,
          ),
        );
      },
    );
  }
}
