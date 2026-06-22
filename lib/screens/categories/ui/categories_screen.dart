import 'package:flutter/material.dart';
import 'package:moona/utils/helper/navigation/push_to.dart';
import 'package:moona/utils/network/network_routes.dart';

import '../../../managers/server/categories/categories_api.dart';
import '../../../models/category_model.dart';
import '../../../utils/widgets/cach_network_image_widget.dart';
import '../../home/ui/widgets/search_bar_widget.dart';
import '../../products/ui/products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryModel> categories = [];
  bool loading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      categories = await CategoriesApi.getCategories();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = categories.where((c) {
      return c.arName.contains(query) ||
          c.subCategories.any((s) => s.arName.contains(query));
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          leading: SizedBox(),
          title: const Text(
            'التصنيفات',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SearchBarWidget(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        return _CategoryCard(category: filtered[i]);
                      },
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => expanded = !expanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CacheNetworkImageWidget(
                    url: categoriesImagePathUrl + widget.category.imageUrl,
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.category.arName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.category.subCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (_, i) {
                  final sub = widget.category.subCategories[i];
                  return GestureDetector(
                    onTap: () {
                      pushTo(
                        context,
                        ProductsScreen(
                          daily: false,
                          hasDiscount: false,
                          categoryId: widget.category.id,
                          title: widget.category.arName,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CacheNetworkImageWidget(
                          url: categoriesImagePathUrl + sub.imageUrl,
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sub.arName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
