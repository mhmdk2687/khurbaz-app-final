import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moona/screens/home/ui/widgets/app_bar_widget.dart';
import 'package:moona/screens/home/ui/widgets/categories_widget.dart';
import 'package:moona/screens/home/ui/widgets/home_top_widget.dart';
import 'package:moona/screens/home/ui/widgets/location_row.dart';
import 'package:moona/screens/home/ui/widgets/products_horizontal_list.dart';
import 'package:moona/screens/home/ui/widgets/promo_cards.dart';
import 'package:moona/screens/home/ui/widgets/search_bar_widget.dart';
import 'package:moona/screens/home/ui/widgets/section_tile.dart';
import 'package:moona/screens/products/ui/products_screen.dart';
import 'package:moona/utils/helper/navigation/push_to.dart';

import '../../../state-managment/bloc/auth/auth_cubit.dart';
import '../../addresses/presentation/cubit/addresses_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    if (AuthCubit.user != null) {
      context.read<AddressesCubit>().loadAddresses();
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ColoredBox(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 70,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (AuthCubit.user != null) LocationRow(),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedSearchDelegate(child: SearchBarWidget()),
        ),

        HomeTopWidget(),

        // ----------------------------------------------------
        // تم النقل: قسم عروض البقالة أصبح هنا (في الأعلى)
        // ----------------------------------------------------
        SliverToBoxAdapter(
          child: SectionHeader(
            showViewMore: true,
            title: 'عروض خربز',
            onTap: () {
              pushTo(
                context,
                ProductsScreen(
                  categoryId: 1,
                  title: 'عروض خربز',
                  daily: false,
                  hasDiscount: true,
                ),
              );
            },
          ),
        ),
        ProductHorizontalList(daily: false, hasDiscount: true),

        // ----------------------------------------------------
        SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
                colors: [light2Green, Colors.white, Colors.white],
              ),
            ),
            child: Column(
              children: [
                SectionHeader(
                  showViewMore: false,
                  title: 'تسوق أكثر',
                  onTap: () {},
                ),
                SubCategoriesBanners(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              children: [
                SectionHeader(
                  showViewMore: false,
                  title: 'الفئات',
                  onTap: () {},
                ),
                CategoriesHorizontalGrid(),
              ],
            ),
          ),
        ),

        // ----------------------------------------------------
        // تم النقل: قسم الاحتياجات اليومية أصبح هنا (في الأسفل)
        // ----------------------------------------------------
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
                colors: [
                  Colors.white,
                  light2Green,
                ], // تأكد أن light2Green معرفة لديك
              ),
            ),
            child: SectionHeader(
              showViewMore: true,
              title: 'احتياجاتك اليومية',
              onTap: () {
                pushTo(
                  context,
                  ProductsScreen(
                    categoryId: 1,
                    title: 'احتياجاتك اليومية',
                    daily: true,
                    hasDiscount: false,
                  ),
                );
              },
            ),
          ),
        ),
        ProductHorizontalList(daily: true, hasDiscount: false),

        // ----------------------------------------------------
        SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _PinnedSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedSearchDelegate({required this.child});

  @override
  double get minExtent => 82;

  @override
  double get maxExtent => 82;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
