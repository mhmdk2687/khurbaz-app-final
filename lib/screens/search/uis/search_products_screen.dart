import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moona/utils/network/network_routes.dart';

import '../../../models/product_model.dart';
import '../../../utils/resources/app_colors.dart';
import '../../home/ui/widgets/app_bar_widget.dart';
import '../../products/ui/widgets/product_card.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;

  List<ProductModel> products = [];
  bool loading = false;
  bool hasSearched = false;

  int selectedSort = 0;
  bool availableOnly = false;
  bool discountOnly = false;

  final List<String> sortValues = ["cheap", "expensive"];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ================= SEARCH =================

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_controller.text.trim().isNotEmpty) {
        _search();
      } else {
        setState(() {
          products.clear();
          hasSearched = false;
        });
      }
    });
  }

  Future<void> _search() async {
    setState(() {
      loading = true;
      hasSearched = true;
    });

    final uri = Uri.parse("$baseUrl/products/search").replace(
      queryParameters: {
        "q": _controller.text,
        "sort": sortValues[selectedSort],
        "available": availableOnly ? "1" : "0",
        "discount": discountOnly ? "1" : "0",
      },
    );

    final response = await http.get(uri, headers: headersWithToken);
    print('=========searchProducts ${response.body}');

    final data = jsonDecode(response.body);

    final List<ProductModel> result = (data['data'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();

    setState(() {
      products = result;
      loading = false;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            ColoredBox(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [_buildSearchBar(), _buildFilters()],
              ),
            ),

            const SizedBox(height: 10),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Added Exit/Back Button Here
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
              tooltip: 'رجوع',
            ),
            const SizedBox(width: 8),

            // Wrapped TextField in Expanded to prevent layout issues
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "ابحث عن منتج...",
                  hintStyle: const TextStyle(color: kMainColor),
                  prefixIcon: const Icon(Icons.search, color: kMainColor),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, color: kMainColor),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              products.clear();
                              hasSearched = false;
                            });
                          },
                        ),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 45,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            _filterChip("الأرخص", 0),
            _filterChip("الأغلى", 1),
            _toggleChip("متوفر", availableOnly, () {
              setState(() => availableOnly = !availableOnly);
              _search();
            }),
            _toggleChip("خصومات", discountOnly, () {
              setState(() => discountOnly = !discountOnly);
              _search();
            }),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String text, int index) {
    final active = selectedSort == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ChoiceChip(
        label: Text(text),
        selected: active,
        selectedColor: kMainColor,
        labelStyle: TextStyle(color: active ? Colors.white : Colors.black),
        checkmarkColor: Colors.white,
        onSelected: (_) {
          setState(() {
            if (index != selectedSort) {
              selectedSort = index;
            } else {
              selectedSort = 0;
            }
          });
          _search();
        },
      ),
    );
  }

  Widget _toggleChip(String text, bool value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FilterChip(
        label: Text(text),
        selected: value,
        selectedColor: kMainColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: value ? Colors.white : Colors.black),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasSearched) {
      return const _EmptyState();
    }

    if (products.isEmpty) {
      return const Center(child: Text("لا توجد نتائج"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 270,
        crossAxisSpacing: 0,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, index) {
        return ProductCard(product: products[index], onPop: _search);
      },
    );
  }
}

// ================= EMPTY STATE =================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "ابدأ بكتابة اسم المنتج للبحث",
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
      ),
    );
  }
}
