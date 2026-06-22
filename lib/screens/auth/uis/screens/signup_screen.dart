import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart'; // تم إضافة هذا الاستيراد لتفعيل ميزة الضغط
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moona/screens/auth/uis/screens/login_screen.dart';
import 'package:moona/utils/helper/navigation/push_to.dart';

import '../../../../state-managment/bloc/auth/auth_cubit.dart';
import '../../../../utils/helper/navigation/push_replacement.dart';
import '../../../../utils/resources/app_colors.dart';
import '../../../../utils/widgets/field.dart';
import '../../../../utils/widgets/snackbar/failed_snackbar.dart';
import '../../../main/ui/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  bool loading = false;
  bool obscureText = true;
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'عميل جديد',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kMainColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const SizedBox(height: 32),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'الاسم الكامل *',
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Field(
                            text: 'الاسم الكامل',
                            validateText: 'الاسم الكامل',
                            controller: _fullNameController,
                            readOnly: false,
                            obscureText: false,
                            prefixIcon: Icon(Icons.person, color: kMainColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                'رقم الهاتف *',
                                style: GoogleFonts.cairo(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Field(
                              text: 'رقم الهاتف',
                              validateText: 'رقم الهاتف',
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              controller: _phoneNumberController,
                              readOnly: false,
                              obscureText: false,
                              prefixIcon: CountryCodePicker(
                                onChanged: print,
                                initialSelection: '+966',
                                favorite: ['+966'],
                                padding: const EdgeInsets.all(0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Checkbox(
                            value: agree,
                            activeColor: kMainColor,
                            onChanged: (v) =>
                                setState(() => agree = v ?? false),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'أوافق على ',
                                style: GoogleFonts.cairo(color: Colors.black54),
                                children: [
                                  TextSpan(
                                    text: 'الشروط والأحكام',
                                    style: TextStyle(
                                      color: kMainColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' و '),
                                  TextSpan(
                                    text: 'سياسة الخصوصية',
                                    style: TextStyle(
                                      color: kMainColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: agree
                              ? () async {
                                  AuthCubit authCubit = AuthCubit.instance(
                                    context,
                                  );
                                  if (!key.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() {
                                    loading = true;
                                  });
                                  dynamic result = await authCubit.register(
                                    phoneNumber:
                                        "966${_phoneNumberController.text}",
                                    fullName: _fullNameController.text,
                                  );
                                  setState(() {
                                    loading = false;
                                  });
                                  if (result == null) {
                                    pushReplacement(context, MainScreen());
                                  } else {
                                    showFailedTopSnackBar(
                                      context: context,
                                      title: 'Failed',
                                      content: result['message'],
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kMainColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'تحقق من رقم الهاتف',
                            style: TextStyle(
                              fontSize: 16,
                              color: agree ? Colors.white : null,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// ================= الـ RichText المحدث هنا =================
                      RichText(
                        text: TextSpan(
                          text: 'هل لديك حساب؟ ',
                          style: GoogleFonts.cairo(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'تسجيل الدخول',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  pushTo(context, LoginScreen());
                                },
                              style: TextStyle(
                                color: kMainColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
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
          ),
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final String label;
  final TextInputType? keyboardType;

  const _RegisterField({required this.label, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
