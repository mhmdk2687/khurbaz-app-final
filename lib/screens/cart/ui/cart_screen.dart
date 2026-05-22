import 'package:flutter/material.dart';
import 'package:moona/models/product_model.dart';
import 'package:moona/screens/auth/uis/screens/login_screen.dart';
import 'package:moona/screens/main/ui/main_screen.dart';
import 'package:moona/utils/helper/navigation/push_replacement.dart';
import 'package:moona/utils/helper/navigation/push_to.dart';
import 'package:moona/utils/resources/app_colors.dart';
import 'package:moona/utils/widgets/snackbar/failed_snackbar.dart';

import '../../../managers/server/cart/cart_api.dart';
import '../../../state-managment/bloc/auth/auth_cubit.dart';
import '../../checkout/checkout_screen.dart';
import '../../products/ui/widgets/product_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.fromMain});

  final bool fromMain;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<ProductModel> items = [];

  int page = 1;
  int lastPage = 1;
  bool loading = false;
  bool firstLoading = true;

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();

    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (loading || page > lastPage) return;

    setState(() => loading = true);

    try {
      final res = await CartApi.getCart(page: page);

      items.addAll(res.items);
      lastPage = res.lastPage;
      page++;

      firstLoading = false;
    } catch (_) {
      firstLoading = false;
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (x, y) async {
        if (widget.fromMain) {
          pushReplacement(context, MainScreen());
        } else {
          Navigator.pop(context);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: items.isEmpty
              ? Colors.white
              : const Color(0xFFF6F7F9),
          appBar: AppBar(
            title: const Text(
              'سلة المشتريات',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                if (widget.fromMain) {
                  pushReplacement(context, MainScreen());
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                /// LIST
                Expanded(
                  child: firstLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? _EmptyCart()
                      : ListView.separated(
                          controller: _scroll,
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length + (loading ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return ProductCartTile(items[index]);
                          },
                        ),
                ),

                /// CHECKOUT
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: kMainColor.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (AuthCubit.user?.phoneNumber == null) {
                            pushTo(context, const LoginScreen());
                          } else {
                            bool isEmptyCart = true;
                            for (var item in items) {
                              if (item.inCartQuantity > 0 ||
                                  item.availableQuantity! > 0) {
                                isEmptyCart = false;
                              }
                            }
                            if (isEmptyCart) {
                              showFailedTopSnackBar(
                                context: context,
                                title: 'السلة فارغة',
                                content: 'لا يمكنك تأكيد الطلب',
                              );
                              return;
                            }
                            pushTo(context, const CheckoutScreen());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kMainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          ' اذهب للدفع',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no-items.png'),
          SizedBox(height: 16),
          Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'أضف بعض المنتجات لتظهر هنا',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
