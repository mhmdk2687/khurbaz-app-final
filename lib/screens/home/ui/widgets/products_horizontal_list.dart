import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../managers/server/products/products_api.dart';
import '../../../../models/product_model.dart';
import '../../../../utils/widgets/shimmers/horizontal_products_shimmer.dart';
import '../../../products/ui/widgets/product_card.dart';

class ProductHorizontalList extends StatefulWidget {
  const ProductHorizontalList({
    super.key,
    required this.daily,
    required this.hasDiscount,
  });

  final bool daily;
  final bool hasDiscount;

  @override
  State<ProductHorizontalList> createState() => _ProductHorizontalListState();
}

class _ProductHorizontalListState extends State<ProductHorizontalList> {
  List<ProductModel> products = [];

  bool loadingProducts = true;

  bool _isUserInteracting = false;

  final ScrollController _scrollController = ScrollController();

  Timer? _timer;

  Future<void> _loadProducts() async {
    loadingProducts = true;

    products.clear();

    setState(() {});

    final res = await ProductsApi.getProducts(
      page: 1,
      daily: widget.daily,
      hasDiscount: widget.hasDiscount,
    );

    products = res;

    loadingProducts = false;

    setState(() {});

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 35),
        (timer) {
          if (!_scrollController.hasClients) return;

          // أثناء تفاعل المستخدم يتوقف التحريك
          if (_isUserInteracting) return;

          final maxScroll = _scrollController.position.maxScrollExtent;

          final current = _scrollController.offset;

          const step = 0.6;

          double next = current + step;

          // العودة للبداية
          if (next >= maxScroll) {
            next = 0;
          }

          _scrollController.jumpTo(next);
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 265,
        child: loadingProducts
            ? HorizontalProductsShimmer()
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification) {
                    if (notification.direction != ScrollDirection.idle) {
                      _isUserInteracting = true;
                    } else {
                      Future.delayed(
                        const Duration(seconds: 2),
                        () {
                          if (mounted) {
                            _isUserInteracting = false;
                          }
                        },
                      );
                    }
                  }

                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 8),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    return ProductCard(
                      product: products[i],
                      onPop: () {},
                    );
                  },
                ),
              ),
      ),
    );
  }
}
