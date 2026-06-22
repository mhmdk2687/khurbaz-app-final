// import 'dart:convert';

// import 'package:http/http.dart' as http;

// import '../../utils/network/network_routes.dart';

// class PaymentService {
//   Future<Map<String, dynamic>> startCheckout({required int addressId}) async {
//     final url = Uri.parse('$baseUrl/payment/start-checkout');

//     final body = jsonEncode({'address_id': addressId});

//     final response = await http.post(
//       url,
//       headers: headersWithToken,
//       body: body,
//     );
//     print('==========startCheckout ${response.body}');

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {
//         'success': true,
//         'checkout_url': data['checkout_url'],
//         'payment_id': data['payment_id'],
//       };
//     } else {
//       return {
//         'success': false,
//         'message': data['message'] ?? 'Checkout failed',
//       };
//     }
//   }

//   /*
//   |--------------------------------------------------------------------------
//   | 2️⃣ التحقق من الدفع بعد الرجوع من WebView
//   |--------------------------------------------------------------------------
//   */

//   Future<Map<String, dynamic>> verifyPayment({
//     required int paymentLocalId,
//     required String paymentMoyasarId,
//     required DateTime? executionTime,
//   }) async {
//     try {
//       final url = Uri.parse(
//         '$baseUrl/payment/verify/$paymentLocalId?id=$paymentMoyasarId'
//         '${executionTime != null ? '&execution_time=${executionTime.toIso8601String()}' : ""}',
//       );

//       print('🔵 URL: $url');

//       final response = await http.get(url, headers: headersWithToken);

//       print('🟢 Status Code: ${response.statusCode}');
//       print('🟢 Response: ${response.body}');

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['status'] == true) {
//         return {'success': true, 'order_id': data['order_id']};
//       }

//       return {
//         'success': false,
//         'message': data['message'] ?? 'Payment not completed',
//       };
//     } catch (e, stackTrace) {
//       print('🔴 ERROR: $e');
//       print('🔴 STACK: $stackTrace');

//       return {'success': false, 'message': e.toString()};
//     }
//   }

//   Future<Map<String, dynamic>> checkout({
//     required String addressId,
//     required String moyasarId,
//     required String paymentMethod,
//     required DateTime? executionTime,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl/payment/checkout');

//       final body = jsonEncode({
//         'address_id': addressId,
//         'moyasar_id': moyasarId,
//         'payment_method': paymentMethod,
//         if (executionTime != null)
//           'execution_time': executionTime.toIso8601String(),
//       });

//       final response = await http.post(
//         url,
//         headers: headersWithToken,
//         body: body,
//       );
//       print('==========checkout ${response.body}');

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'order_id': data['order_id'],
//           // 'payment_id': data['payment_id'],
//         };
//       } else {
//         return {'success': false, 'message': data['message']};
//       }
//     } catch (e, stackTrace) {
//       print('🔴 ERROR: $e');
//       print('🔴 STACK: $stackTrace');

//       return {'success': false, 'message': e.toString()};
//     }
//   }
// }
// import 'dart:convert';

// import 'package:http/http.dart' as http;

// import '../../utils/network/network_routes.dart';

// class PaymentService {
//   Future<Map<String, dynamic>> startCheckout({
//     required int addressId,
//   }) async {
//     final url = Uri.parse('$baseUrl/payment/start-checkout');

//     final body = jsonEncode({'address_id': addressId});

//     final response = await http.post(
//       url,
//       headers: headersWithToken,
//       body: body,
//     );

//     print('==========startCheckout ${response.body}');

//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {
//         'success': true,
//         'checkout_url': data['checkout_url'],
//         'payment_id': data['payment_id'],
//       };
//     } else {
//       return {
//         'success': false,
//         'message': data['message'] ?? 'Checkout failed',
//       };
//     }
//   }

//   /*
//   |--------------------------------------------------------------------------
//   | Verify payment after returning from Moyasar WebView
//   |--------------------------------------------------------------------------
//   */
//   Future<Map<String, dynamic>> verifyPayment({
//     required int paymentLocalId,
//     required String paymentMoyasarId,
//     required DateTime? executionTime,
//   }) async {
//     try {
//       final url = Uri.parse(
//         '$baseUrl/payment/verify/$paymentLocalId?id=$paymentMoyasarId'
//         '${executionTime != null ? '&execution_time=${executionTime.toIso8601String()}' : ''}',
//       );

//       print('🔵 URL: $url');

//       final response = await http.get(url, headers: headersWithToken);

//       print('🟢 Status Code: ${response.statusCode}');
//       print('🟢 Response: ${response.body}');

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['status'] == true) {
//         return {'success': true, 'order_id': data['order_id']};
//       }

//       return {
//         'success': false,
//         'message': data['message'] ?? 'Payment not completed',
//       };
//     } catch (e, stackTrace) {
//       print('🔴 ERROR: $e');
//       print('🔴 STACK: $stackTrace');

//       return {'success': false, 'message': e.toString()};
//     }
//   }

//   /*
//   |--------------------------------------------------------------------------
//   | Coupon validation
//   |--------------------------------------------------------------------------
//   */
//   Future<Map<String, dynamic>> validateCoupon({
//     required String couponCode,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl/coupon/validate');

//       final response = await http.post(
//         url,
//         headers: headersWithToken,
//         body: jsonEncode({'coupon_code': couponCode}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['status'] == true) {
//         return {
//           'success': true,
//           'coupon_code': data['data']['coupon_code'],
//           'coupon_discount':
//               double.parse(data['data']['coupon_discount'].toString()),
//           'products_total':
//               double.parse(data['data']['products_total'].toString()),
//           'delivery_fee': double.parse(data['data']['delivery_fee'].toString()),
//           'grand_total': double.parse(data['data']['grand_total'].toString()),
//         };
//       }

//       return {
//         'success': false,
//         'message': data['message'] ?? 'Coupon validation failed',
//       };
//     } catch (e) {
//       return {'success': false, 'message': e.toString()};
//     }
//   }

//   /*
//   |--------------------------------------------------------------------------
//   | Final checkout after payment success
//   |--------------------------------------------------------------------------
//   */
//   Future<Map<String, dynamic>> checkout({
//     required String addressId,
//     required String moyasarId,
//     required String paymentMethod,
//     required DateTime? executionTime,
//     String? couponCode,
//   }) async {
//     try {
//       final url = Uri.parse('$baseUrl/payment/checkout');

//       final body = jsonEncode({
//         'address_id': addressId,
//         'moyasar_id': moyasarId,
//         'payment_method': paymentMethod,
//         if (couponCode != null && couponCode.trim().isNotEmpty)
//           'coupon_code': couponCode.trim(),
//         if (executionTime != null)
//           'execution_time': executionTime.toIso8601String(),
//       });

//       final response = await http.post(
//         url,
//         headers: headersWithToken,
//         body: body,
//       );

//       print('==========checkout ${response.body}');

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['status'] == true) {
//         return {
//           'success': true,
//           'order_id': data['order_id'],
//         };
//       } else {
//         return {
//           'success': false,
//           'message': data['message'] ?? 'Checkout failed',
//         };
//       }
//     } catch (e, stackTrace) {
//       print('🔴 ERROR: $e');
//       print('🔴 STACK: $stackTrace');

//       return {'success': false, 'message': e.toString()};
//     }
//   }
// // }
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/network/network_routes.dart';

class PaymentService {
  Future<Map<String, dynamic>> startCheckout({
    required int addressId,
  }) async {
    final url = Uri.parse('$baseUrl/payment/start-checkout');

    final body = jsonEncode({'address_id': addressId});

    final response = await http.post(
      url,
      headers: headersWithToken,
      body: body,
    );

    print('==========startCheckout ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'checkout_url': data['checkout_url'],
        'payment_id': data['payment_id'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Checkout failed',
      };
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Verify payment after returning from Moyasar WebView
  |--------------------------------------------------------------------------
  */
  Future<Map<String, dynamic>> verifyPayment({
    required int paymentLocalId,
    required String paymentMoyasarId,
    required DateTime? executionTime,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/payment/verify/$paymentLocalId?id=$paymentMoyasarId'
        '${executionTime != null ? '&execution_time=${executionTime.toIso8601String()}' : ''}',
      );

      print('🔵 URL: $url');

      final response = await http.get(url, headers: headersWithToken);

      print('🟢 Status Code: ${response.statusCode}');
      print('🟢 Response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'order_id': data['order_id']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Payment not completed',
      };
    } catch (e, stackTrace) {
      print('🔴 ERROR: $e');
      print('🔴 STACK: $stackTrace');

      return {'success': false, 'message': e.toString()};
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Coupon validation
  |--------------------------------------------------------------------------
  */
  Future<Map<String, dynamic>> validateCoupon({
    required String couponCode,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/coupon/validate');

      final response = await http.post(
        url,
        headers: headersWithToken,
        body: jsonEncode({'coupon_code': couponCode}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'coupon_code': data['data']['coupon_code'],
          'coupon_discount':
              double.parse(data['data']['coupon_discount'].toString()),
          'products_total':
              double.parse(data['data']['products_total'].toString()),
          'delivery_fee': double.parse(data['data']['delivery_fee'].toString()),
          'grand_total': double.parse(data['data']['grand_total'].toString()),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Coupon validation failed',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Final checkout after payment success
  |--------------------------------------------------------------------------
  */
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String moyasarId,
    required String paymentMethod,
    required DateTime? executionTime,
    String? couponCode,

    // SAFELY ADDED NEW OPTIONAL PARAMETERS
    String? cardBrand,
    String? maskedCardNumber,
    String? cardSourceId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/payment/checkout');

      // استخراج آخر 4 أرقام لتتناسب مع قاعدة بياناتك (last_four)
      String? lastFour;
      if (maskedCardNumber != null) {
        if (maskedCardNumber.contains('-')) {
          lastFour = maskedCardNumber.split('-').last;
        } else if (maskedCardNumber.length >= 4) {
          lastFour = maskedCardNumber.substring(maskedCardNumber.length - 4);
        } else {
          lastFour = maskedCardNumber;
        }
      }

      final body = jsonEncode({
        'address_id': addressId,
        'moyasar_id': moyasarId,
        'payment_method': paymentMethod,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'coupon_code': couponCode.trim(),
        if (executionTime != null)
          'execution_time': executionTime.toIso8601String(),

        // الإرسال بنفس أسماء حقول قاعدة البيانات التي صممناها
        if (cardBrand != null) 'card_name': cardBrand,
        if (lastFour != null) 'last_four': lastFour,
        if (cardSourceId != null) 'token': cardSourceId,
      });

      final response = await http.post(
        url,
        headers: headersWithToken,
        body: body,
      );

      print('==========checkout ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'order_id': data['order_id'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Checkout failed',
        };
      }
    } catch (e, stackTrace) {
      print('🔴 ERROR: $e');
      print('🔴 STACK: $stackTrace');

      return {'success': false, 'message': e.toString()};
    }
  }

  // =======================================================================
  // الدوال الجديدة لميزة البطاقات المحفوظة (معزولة تماماً)
  // =======================================================================

  Future<List<dynamic>> getSavedCards() async {
    try {
      final url = Uri.parse('$baseUrl/saved-cards');
      final response = await http.get(url, headers: headersWithToken);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> checkoutWithSavedCard({
    required String addressId,
    required String savedCardToken,
    required DateTime? executionTime,
    String? couponCode,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/payment/checkout-saved-card');
      final body = jsonEncode({
        'address_id': addressId,
        'saved_card_token': savedCardToken,
        if (couponCode != null && couponCode.trim().isNotEmpty)
          'coupon_code': couponCode.trim(),
        if (executionTime != null)
          'execution_time': executionTime.toIso8601String(),
      });

      final response =
          await http.post(url, headers: headersWithToken, body: body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {'success': true, 'order_id': data['order_id']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشلت عملية الدفع بالبطاقة المحفوظة'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /*
  |--------------------------------------------------------------------------
  | Delete Saved Card
  |--------------------------------------------------------------------------
  */
  Future<Map<String, dynamic>> deleteSavedCard({required int cardId}) async {
    try {
      final url = Uri.parse('$baseUrl/saved-cards/$cardId');

      final response = await http.delete(
        url,
        headers: headersWithToken,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم الحذف بنجاح'
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل حذف البطاقة'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
