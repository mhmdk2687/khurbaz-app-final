import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moona/utils/helper/navigation/push_to.dart';
import 'package:moona/utils/network/network_routes.dart';

import '../../../../models/sub_category_model.dart';
import '../../../products/ui/products_screen.dart';

class SubCategoriesBanners extends StatefulWidget {
  const SubCategoriesBanners({super.key});

  @override
  State<SubCategoriesBanners> createState() => _SubCategoriesBannersState();
}

class _SubCategoriesBannersState extends State<SubCategoriesBanners> {
  List<SubCategoryModel> banners = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/sub-categories-banners"),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        final List list = data['banners'];
        banners = list.map((e) => SubCategoryModel.fromJson(e)).toList();
      }
    } catch (e) {
      banners = [];
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (banners.isEmpty) return const SizedBox();

    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final banner = banners[index];

          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: PromoCard(
              categoryId: banner.categoryId,
              subCategoryId: banner.id,
              title: banner.arName,
              image: banner.homeBanner ?? banner.imageUrl,
            ),
          );
        },
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  final int categoryId;
  final int subCategoryId;
  final String title;
  final String image;

  const PromoCard({
    super.key,
    required this.title,
    required this.image,
    required this.categoryId,
    required this.subCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pushTo(
        context,
        ProductsScreen(
          categoryId: categoryId,
          initialSubCategoryId: subCategoryId,
          daily: false,
          hasDiscount: false,
          title: title,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Image.network(
              categoriesImagePathUrl + image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Container(
            //   height: 220,
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [Colors.black.withOpacity(.4), Colors.transparent],
            //       begin: Alignment.bottomCenter,
            //       end: Alignment.topCenter,
            //     ),
            //   ),
            // ),
            // Positioned(
            //   bottom: 16,
            //   left: 16,
            //   right: 16,
            //   child: Text(
            //     title,
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 18,
            //       fontWeight: FontWeight.w700,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
