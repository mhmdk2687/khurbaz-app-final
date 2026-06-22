import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:moona/screens/auth/uis/screens/signup_screen.dart';
import 'package:moona/screens/main/ui/main_screen.dart';

import '../../../../state-managment/bloc/auth/auth_cubit.dart';
import '../../../../utils/helper/navigation/push_replacement.dart';
import '../../../../utils/resources/app_colors.dart';
import '../../../../utils/widgets/field.dart';
import '../../../../utils/widgets/snackbar/failed_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'أهلاً!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: kMainColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'سجّل دخولك للمتابعة',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Image.asset(
                              'assets/images/login.jpeg',
                              height: 280,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'رقم الجوال',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Field(
                              text: 'رقم الهاتف',
                              validateText: 'يجب إدخال رقم الهاتف',
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              controller: _phoneController,
                              readOnly: false,
                              obscureText: false,
                              prefixIcon: CountryCodePicker(
                                showCountryOnly: true,
                                initialSelection: 'SA',
                                favorite: const ['+966', 'SA'],
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _onLoginPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kMainColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                pushReplacement(context, RegisterScreen());
                              },
                              child: const Text(
                                'مستخدم جديد؟ إنشاء حساب',
                                style: TextStyle(
                                  color: kMainColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                if (loading)
                  Container(
                    color: Colors.black38,
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: kMainColor),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });
    final result = await AuthCubit.login(
      phoneNumber: "966${_phoneController.text}",
    );

    setState(() {
      loading = false;
    });
    if (result == null) {
      pushReplacement(context, const MainScreen());
    } else {
      showFailedTopSnackBar(
        context: context,
        title: 'خطأ',
        // content: result['message'],
        content: 'ليس لديك حساب مسجل بهذا الرقم',
      );
    }
  }
}
