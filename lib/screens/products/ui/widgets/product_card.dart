import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moona/models/product_model.dart';
import 'package:moona/utils/widgets/check_dialog.dart';

import '../../../../features/cart_summury/presentation/cubit/cart_summary_cubit.dart';
import '../../../../managers/server/cart/cart_api.dart';
import '../../../../utils/helper/navigation/push_to.dart';
import '../../../../utils/network/network_routes.dart';
import '../../../../utils/resources/app_colors.dart';
import '../../../../utils/widgets/cach_network_image_widget.dart';
import '../../../../utils/widgets/currency.dart';
import '../../../product_details/product_details_screen.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, required this.onPop});

  final ProductModel product;
  final VoidCallback onPop;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int count = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    count = widget.product.inCartQuantity;
  }

  Future<void> increment() async {
    if (loading) return;
    setState(() {
      loading = true;
      count++;
    });
    int? availableQuantity;
    try {
      if (widget.product.cartItemId == null) {
        widget.product.cartItemId = await CartApi.add(
          productId: widget.product.id,
          quantity: 1,
        );
      } else {
        availableQuantity = await CartApi.update(
          cartItemId: widget.product.cartItemId!,
          quantity: count,
        );
      }
      if (availableQuantity != null) {
        setState(() {
          loading = true;
          count--;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CheckDialog(
              text: 'هذه الكمية غير متاحة من المنتج',
              textButton: 'أكبر كمية متاحة',
              onCheck: () async {
                setState(() => count = availableQuantity!);
                Navigator.pop(context);
                return true;
              },
            );
          },
        );
      }
      context.read<CartSummaryCubit>().loadSummary();
    } catch (_) {
      setState(() => count--);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> decrement() async {
    print('====decrement');

    if (loading || count == 0) return;

    setState(() {
      loading = true;
      count--;
    });
    print('====count${count}');

    try {
      if (count == 0 && widget.product.cartItemId != null) {
        print('====remove');
        await CartApi.remove(widget.product.cartItemId!);
        widget.product.cartItemId = null;
        count == 0;
      } else if (widget.product.cartItemId != null) {
        print('====update $count');

        await CartApi.update(
          cartItemId: widget.product.cartItemId!,
          quantity: count,
        );
      }
      context.read<CartSummaryCubit>().loadSummary();
    } catch (_) {
      setState(() => count++); // rollback
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _showQuantityDialog() async {
    final controller = TextEditingController(text: count.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حدد الكمية'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text) ?? count;
                Navigator.pop(context, value);
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );

    if (result == null || result < 0) return;

    setState(() => count = result);

    if (result == 0 && widget.product.cartItemId != null) {
      await CartApi.remove(widget.product.cartItemId!);
    } else if (widget.product.cartItemId != null) {
      await CartApi.update(
        cartItemId: widget.product.cartItemId!,
        quantity: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await pushTo(
          context,
          ProductDetailsScreen(productId: widget.product.id),
        );
        widget.onPop();
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: kContainerBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kShadowColor.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              height:
                  128, // Increased from 115 to make the image visibly larger
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kPrimaryWhiteColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorderOverlayColor),
              ),
              child: CacheNetworkImageWidget(
                url: productsImagePathUrl + widget.product.image,
                width: double.infinity,
              ),
            ),

            // NAME
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTitleBodyColor,
                  ),
                ),
              ),
            ),

            // PRICE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: widget.product.hasDiscount
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // OLD PRICE (LINE THROUGH)
                        Text(
                          '${widget.product.price}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),

                        // DISCOUNT PRICE
                        Row(
                          children: [
                            Text(
                              '${widget.product.finalPrice}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.red,
                              ),
                            ),
                            Currency(isRed: true),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          '${widget.product.price}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Currency(),
                      ],
                    ),
            ),

            // ADD / COUNTER
            widget.product.availableQuantity! <= 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.red.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            'الكمية نفذت',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: count == 0
                        ? AddButton(
                            key: const ValueKey('add'),
                            onTap: increment,
                          )
                        : CounterControls(
                            key: const ValueKey('counter'),
                            count: count,
                            onAdd: increment,
                            onRemove: decrement,
                            onCountTap: _showQuantityDialog,
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// ================= ADD BUTTON =================

class AddButton extends StatefulWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  Timer? _timer;

  void _start() {
    widget.onTap();
    _timer = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) => widget.onTap(),
    );
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: (_) => _start(),
        onLongPressEnd: (_) => _stop(),
        onLongPressCancel: _stop,
        child: Container(
          decoration: const BoxDecoration(
            color: kMainColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Icon(Icons.add, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

/// ================= COUNTER =================

class CounterControls extends StatelessWidget {
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onCountTap;

  const CounterControls({
    super.key,
    required this.count,
    required this.onAdd,
    required this.onRemove,
    required this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CounterButton(
          icon: Icons.add,
          onTap: onAdd,
          radius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(20),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onCountTap,
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kMainColor,
            ),
          ),
        ),
        const Spacer(),
        CounterButton(
          icon: Icons.remove,
          onTap: onRemove,
          radius: const BorderRadius.only(
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(20),
          ),
        ),
      ],
    );
  }
}

class CounterButton extends StatelessWidget {
  final IconData icon;
  final BorderRadius radius;
  final VoidCallback onTap;

  const CounterButton({
    super.key,
    required this.icon,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kMainColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
