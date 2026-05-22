import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moona/screens/about_us_screen.dart';
import 'package:moona/screens/contact_us_screen.dart';
import 'package:moona/screens/main/singup_section.dart';
import 'package:moona/screens/main/ui/main_screen.dart';
import 'package:moona/screens/main/webview_screen.dart';
import 'package:moona/screens/manage_account_screen.dart';
import 'package:moona/state-managment/bloc/auth/auth_cubit.dart';
import 'package:moona/utils/helper/navigation/push_to.dart';
//import 'package:url_launcher/url_launcher.dart';

import '../../managers/cash_manager.dart';
import '../../utils/helper/navigation/push_replacement.dart';
import '../../utils/resources/app_colors.dart';
import '../../utils/widgets/check_dialog.dart';
//import '../privacy_policy_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Future<bool> onCheck() async {
    await AuthCubit.instance(context).deleteAccount();
    if (!kIsWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(
        'User-${AuthCubit.user!.id}',
      );
    }
    CacheManager.getInstance()!.logout();
    AuthCubit.user = null;
    pushReplacement(context, const MainScreen());

    pushReplacement(context, const MainScreen());
    return true;
  }

  // Future<void> _launchFAQWebpage() async {
  //   // Replace the URL below with your actual link
  //   final Uri url = Uri.parse('https://moonastore.cloud/support.html');
  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //     debugPrint('Could not launch $url');
  //   }
  // }

  // Future<void> _launchPrivacyWebpage() async {
  //   // Replace the URL below with your actual link
  //   final Uri url = Uri.parse('https://moonastore.cloud/privacy-policy.html');
  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //     debugPrint('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: (AuthCubit.user?.phoneNumber != null)
            ? AppBar(
                leading: SizedBox(),
                actions: [
                  SizedBox(width: 8),

                  Text(
                    'أهلاً',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AuthCubit.user?.fullName,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kMainColor,
                      ),
                    ),
                  ),

                  /// LOGOUT
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(),
                  //   child: ElevatedButton(
                  //     onPressed: () async {
                  //       if (!kIsWeb) {
                  //         FirebaseMessaging.instance.unsubscribeFromTopic(
                  //           'User-${AuthCubit.user!.id}',
                  //         );
                  //       }
                  //       CacheManager.getInstance()!.logout();
                  //       AuthCubit.user = null;
                  //       pushReplacement(context, const MainScreen());
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: kMainColor.withOpacity(0.2),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       elevation: 0,
                  //     ),
                  //     child: SvgPicture.asset(
                  //       'assets/images/sign-out-alt.svg',
                  //       width: 18,
                  //       color: kMainColor,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(width: 8),

                  /// DELETE ACCOUNT
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(),
                  //   child: ElevatedButton(
                  //     onPressed: () async {
                  //       showDialog(
                  //         context: context,
                  //         builder: (BuildContext context) => CheckDialog(
                  //           textButton: 'حذف',
                  //           text: 'هل انت متأكد انك تريد حذف الحساب ؟',
                  //           onCheck: () async => await onCheck(),
                  //         ),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.red.withOpacity(0.2),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       elevation: 0,
                  //     ),
                  //     child: Icon(Icons.delete_outline, color: Colors.red),
                  //   ),
                  // ),
                  SizedBox(width: 8),
                ],
              )
            : null,
        backgroundColor: kScaffoldBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (AuthCubit.user?.phoneNumber != null)
                    /// HEADER
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                      ],
                    ),
                  if (AuthCubit.user?.phoneNumber == null) SignupSection(),

                  const SizedBox(height: 24),

                  /// MENU ITEMS
                  _MoreItem(
                    icon: Icons.info_outline,
                    title: 'عن خربز',
                    onTap: () => pushTo(context, AboutKhurbazScreen()),
                  ),
                  _MoreItem(
                    icon: Icons.phone_outlined,
                    title: 'تواصل معنا',
                    onTap: () => pushTo(context, ContactUsScreen()),
                  ),
                  // <-- ADDED THIS NEW ITEM
                  _MoreItem(
                    icon: Icons.help_outline,
                    title: ' الدعم الفني',
                    onTap: () => pushTo(
                      context,
                      WebviewScreen(
                        title: 'الدعم الفني ',
                        url:
                            'https://moonastore.cloud/support.html', // Put the client's actual URL here
                      ),
                    ),
                  ),

                  _MoreItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    onTap:
                        //() => pushTo(context, PrivacyPolicyScreen())
                        () => pushTo(
                          context,
                          WebviewScreen(
                            title: 'سياسة الخصوصية',
                            url:
                                'https://moonastore.cloud/privacy-policy.html', // Put the client's actual URL here
                          ),
                        ),
                  ),
                  if (AuthCubit.user?.phoneNumber != null)
                    _MoreItem(
                      icon: Icons.account_circle,
                      title: ' ادارة الحساب',
                      onTap: () => pushTo(context, ManageAccountScreen()),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: kMainColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
