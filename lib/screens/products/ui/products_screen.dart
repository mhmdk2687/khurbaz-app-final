import 'package:flutter/material.dart';
import 'package:moona/screens/products/ui/widgets/product_card.dart';

import '../../../managers/server/categories/categories_api.dart';
import '../../../managers/server/products/products_api.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../models/sub_category_model.dart';
import '../../../utils/network/network_routes.dart';
import '../../../utils/resources/app_colors.dart';
import '../../../utils/widgets/shimmers/products_grid_shimmer.dart';
import '../../../utils/widgets/shimmers/sub_categories_shimmer.dart';

class ProductsScreen extends StatefulWidget {
  final int categoryId;
  final String title;
  final bool daily;
  final bool hasDiscount;
  final int? initialSubCategoryId;

  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.title,
    required this.daily,
    required this.hasDiscount,
    this.initialSubCategoryId,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int? _activeSubCategoryId;
  int selectedSubIndex = 0;

  List<CategoryModel> categories = [];
  List<SubCategoryModel> subs = [];
  List<ProductModel> products = [];
  bool loadingProducts = true;

  bool loadingSubs = true;
  bool loadingMore = false;
  bool hasMore = true;

  int currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
    // if(widget.hasDiscount||widget.daily){
    //   _loadCategories();
    // }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !loadingMore &&
          hasMore &&
          !loadingProducts) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// ================= SUB CATEGORIES =================

  Future<void> _loadCategories() async {
    loadingSubs = true;
    setState(() {});

    categories = await CategoriesApi.getCategories();

    loadingSubs = false;

    if (subs.isNotEmpty) {
      selectedSubIndex = 0;
      await _loadProducts(subs.first.id);
    }

    setState(() {});
  }

  // Future<void> _loadSubCategories() async {
  //   loadingSubs = true;
  //   setState(() {});

  //   subs = await CategoriesApi.getSubCategories(widget.categoryId);

  //   loadingSubs = false;

  //   if (subs.isNotEmpty) {
  //     selectedSubIndex = 0;
  //     await _loadProducts(subs.first.id);
  //   }

  //   setState(() {});
  // }
  Future<void> _loadSubCategories() async {
    loadingSubs = true;
    setState(() {});

    subs = await CategoriesApi.getSubCategories(widget.categoryId);

    loadingSubs = false;

    if (subs.isNotEmpty) {
      final initialIndex = widget.initialSubCategoryId == null
          ? 0
          : subs.indexWhere((sub) => sub.id == widget.initialSubCategoryId);

      selectedSubIndex = initialIndex >= 0 ? initialIndex : 0;
      _activeSubCategoryId = subs[selectedSubIndex].id;

      await _loadProducts(_activeSubCategoryId!);
    }

    setState(() {});
  }

  /// ================= PRODUCTS =================

  // Future<void> _loadProducts(int subCategoryId) async {
  //   loadingProducts = true;
  //   loadingMore = false;
  //   hasMore = true;
  //   currentPage = 1;
  //   products.clear();

  //   setState(() {});

  //   final res = await ProductsApi.getProducts(
  //     subCategoryId: widget.hasDiscount || widget.daily ? null : subCategoryId,
  //     page: currentPage,
  //     daily: widget.daily,
  //     hasDiscount: widget.hasDiscount,
  //   );

  //   products = res;
  //   hasMore = res.isNotEmpty;

  //   loadingProducts = false;
  //   setState(() {});
  // }
  Future<void> _loadProducts(int subCategoryId) async {
    _activeSubCategoryId = subCategoryId;

    loadingProducts = true;
    loadingMore = false;
    hasMore = true;
    currentPage = 1;
    products.clear();

    setState(() {});

    final res = await ProductsApi.getProducts(
      subCategoryId: widget.hasDiscount || widget.daily ? null : subCategoryId,
      page: currentPage,
      daily: widget.daily,
      hasDiscount: widget.hasDiscount,
    );

    products = res;
    hasMore = res.isNotEmpty;

    loadingProducts = false;
    setState(() {});
  }
  // Future<void> _loadMore() async {
  //   if (!hasMore) return;

  //   loadingMore = true;
  //   currentPage++;

  //   setState(() {});

  //   final res = await ProductsApi.getProducts(
  //     daily: widget.daily,
  //     hasDiscount: widget.hasDiscount,
  //     subCategoryId: subs[selectedSubIndex].id,
  //     page: currentPage,
  //   );

  //   if (res.isEmpty) {
  //     hasMore = false;
  //   } else {
  //     products.addAll(res);
  //   }

  //   loadingMore = false;
  //   setState(() {});
  // }
  Future<void> _loadMore() async {
    if (!hasMore || _activeSubCategoryId == null) return;

    loadingMore = true;
    currentPage++;

    setState(() {});

    final res = await ProductsApi.getProducts(
      daily: widget.daily,
      hasDiscount: widget.hasDiscount,
      subCategoryId:
          widget.hasDiscount || widget.daily ? null : _activeSubCategoryId,
      page: currentPage,
    );

    if (res.isEmpty) {
      hasMore = false;
    } else {
      products.addAll(res);
    }

    loadingMore = false;
    setState(() {});
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kScaffoldBackground,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              /// ================= SUB CATEGORIES =================
              if ((!widget.daily && !widget.hasDiscount))
                Container(
                  height: 100,
                  color: Colors.white,
                  child: loadingSubs
                      ? const SubCategoriesShimmer()
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: subs.length,
                          itemBuilder: (context, index) {
                            final active = index == selectedSubIndex;
                            final sub = subs[index];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  if (selectedSubIndex == index) return;

                                  selectedSubIndex = index;
                                  await _loadProducts(sub.id);
                                  setState(() {});
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: active
                                          ? kMainColor
                                          : Colors.grey.shade200,
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundImage: NetworkImage(
                                          categoriesImagePathUrl + sub.imageUrl,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      sub.arName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: active
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: active
                                            ? kMainColor
                                            : kTitleGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

              /// ================= PRODUCTS =================
              Expanded(
                child: loadingProducts
                    ? const ProductsGridShimmer()
                    : products.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد منتجات',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 12,
                              right:
                                  4, // Decrease to move cards closer to the right edge
                              left:
                                  16, // Increase to push cards away from the left edge
                            ),
                            child: Wrap(
                              spacing: 0,
                              runSpacing: 12,
                              children: [
                                ...products.map((product) {
                                  return SizedBox(
                                    width: (MediaQuery.of(context).size.width -
                                            24) /
                                        2,
                                    height: 250,
                                    child: ProductCard(
                                      product: product,
                                      onPop: () {
                                        _loadProducts(
                                            subs[selectedSubIndex].id);
                                      },
                                    ),
                                  );
                                }),
                                if (loadingMore)
                                  const SizedBox(
                                    width: double.infinity,
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                              ],
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
