import 'package:flutter/material.dart';
import 'package:moona/utils/network/network_routes.dart';
import 'package:moona/utils/widgets/cach_network_image_widget.dart';

import '../../managers/server/order/order_api.dart';
import '../../models/order/order_details.dart';
import '../../utils/helper/formatters/date_formatter.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
          'تفاصيل الطلب',
          style: TextStyle(fontSize: 20),
        )),
        body: SafeArea(
          child: FutureBuilder<OrderDetailsModel>(
            future: OrdersApi.getOrderDetails(orderId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final order = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'طلب رقم #${order.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(formatDate(DateTime.parse(order.date.toString()))),
                  const SizedBox(height: 20),
                  const Text(
                    'المنتجات',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CacheNetworkImageWidget(
                            url: productsImagePathUrl + item.image,
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name),
                                Text('${item.price} × ${item.quantity}'),
                              ],
                            ),
                          ),
                          Text(
                            '${item.price * item.quantity} ﷼',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'الإجمالي: ${order.grandTotal} ﷼',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
