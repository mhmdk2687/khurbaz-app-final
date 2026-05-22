import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moona/managers/cash_manager.dart';
import 'package:moona/screens/main/ui/main_screen.dart';
import 'package:moona/screens/main/webview_screen.dart';
import 'package:moona/state-managment/bloc/auth/auth_cubit.dart';
import 'package:moona/utils/helper/navigation/push_replacement.dart';
import 'package:moona/utils/helper/navigation/push_to.dart';

import '../../utils/resources/app_colors.dart';

class ManageAccountScreen extends StatelessWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kScaffoldBackground,
        appBar: AppBar(
          title: const Text(
            " ادارة الحساب ",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------
                // LOGOUT BUTTON
                // ------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!kIsWeb) {
                        FirebaseMessaging.instance.unsubscribeFromTopic(
                          'User-${AuthCubit.user!.id}',
                        );
                      }
                      CacheManager.getInstance()!.logout();
                      AuthCubit.user = null;
                      pushReplacement(context, const MainScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor.withOpacity(
                        0.1,
                      ), // Soft main color background
                      foregroundColor: kMainColor, // Ripple effect color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/images/sign-out-alt.svg',
                            width: 20,
                            color: kMainColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ------------------------------------
                // DELETE ACCOUNT BUTTON
                // ------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => pushTo(
                      context,
                      const WebviewScreen(
                        title: 'طلب حذف الحساب',
                        url: 'https://moonastore.cloud/delete-account.html',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(
                        0.1,
                      ), // Soft red background
                      foregroundColor: Colors.red, // Ripple effect color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_delete_outlined,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'طلب حذف الحساب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors
                                  .red, // Red text to indicate a critical action
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),

                // _SectionTitle("1. المعلومات التي نجمعها"),
                // _SectionText(
                //   "نقوم بجمع المعلومات التي تقدمها عند إنشاء الحساب أو إتمام الطلب، "
                //   "مثل الاسم، رقم الهاتف، عنوان التوصيل، والبريد الإلكتروني.",
                // ),

                // _SectionTitle("2. كيفية استخدام المعلومات"),
                // _SectionText(
                //   "نستخدم معلوماتك لتقديم خدماتنا، معالجة الطلبات، "
                //   "تحسين تجربة المستخدم، والتواصل معك بخصوص الطلبات أو العروض.",
                // ),

                // _SectionTitle("3. حماية البيانات"),
                // _SectionText(
                //   "نلتزم بحماية بياناتك باستخدام تقنيات أمان حديثة، "
                //   "ولا نقوم بمشاركة معلوماتك مع أي طرف ثالث إلا عند الضرورة "
                //   "لتنفيذ الخدمة أو وفقًا للأنظمة المعمول بها.",
                // ),

                // _SectionTitle("4. المدفوعات"),
                // _SectionText(
                //   "تتم عمليات الدفع عبر مزود خدمة دفع آمن ومعتمد، "
                //   "ولا نقوم بتخزين بيانات بطاقتك البنكية على خوادمنا.",
                // ),

                // _SectionTitle("5. ملفات تعريف الارتباط (Cookies)"),
                // _SectionText(
                //   "قد نستخدم تقنيات مشابهة لملفات تعريف الارتباط "
                //   "لتحسين أداء التطبيق وتجربة المستخدم.",
                // ),

                // _SectionTitle("6. حقوق المستخدم"),
                // _SectionText(
                //   "يمكنك طلب تعديل أو حذف بياناتك من خلال إعدادات الحساب "
                //   "أو التواصل مع فريق الدعم.",
                // ),

                // _SectionTitle("7. التعديلات على السياسة"),
                // _SectionText(
                //   "قد نقوم بتحديث سياسة الخصوصية من وقت لآخر، "
                //   "وسيتم نشر أي تغييرات داخل التطبيق.",
                // ),
                SizedBox(height: 30),

                Center(
                  child: Text(
                    "آخر تحديث: 2026",
                    style: TextStyle(color: kTitleGreyColor, fontSize: 13),
                  ),
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===================== WIDGETS =====================

// class _SectionTitle extends StatelessWidget {
//   final String text;

//   const _SectionTitle(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 22, bottom: 8),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontFamily: 'DINNextLT',

//           fontSize: 17,
//           fontWeight: FontWeight.w800,
//           color: kMainColor,
//         ),
//       ),
//     );
//   }
// }

// class _SectionText extends StatelessWidget {
//   final String text;

//   const _SectionText(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontFamily: 'DINNextLT',
//         fontSize: 14,
//         height: 1.8,
//         color: kTitleBodyColor,
//       ),
//     );
//   }
// }
