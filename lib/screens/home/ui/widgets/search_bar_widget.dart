import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moona/utils/resources/app_colors.dart';

import '../../../../main.dart';
import '../../../../utils/helper/navigation/push_to.dart';
import '../../../search/uis/search_products_screen.dart';
import 'app_bar_widget.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  int _currentIndex = 0;
  Timer? _timer;

  // قائمة النصوص المتحركة المطلوبة
  final List<String> _textLines = [
    'ناقصك شي للبيت ؟ اطلبه الحين',
    'ابحث عن ألبان ، اجبان ، ومخبوزات',
    'ابحث عن منتجات عروض و سناكات',
  ];

  @override
  void initState() {
    super.initState();
    // تبديل النص كل 3 ثوانٍ
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _textLines.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // إلغاء المؤقت عند إغلاق الصفحة لمنع تسريب الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pushTo(context, ProductSearchScreen()),
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, color: mainColor),

                // تأثير حركة النصوص للأعلى والأسفل
                Expanded(
                  child: ClipRect(
                    // لمنع النص من الخروج خارج حدود شريط البحث أثناء الحركة
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1000),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            // تخصيص الحركة لتكون من الأسفل إلى الأعلى
                            final inAnimation = Tween<Offset>(
                              begin: const Offset(0.0, 1.2),
                              end: const Offset(0.0, 0.0),
                            ).animate(animation);

                            final outAnimation = Tween<Offset>(
                              begin: const Offset(0.0, -1.2),
                              end: const Offset(0.0, 0.0),
                            ).animate(animation);

                            if (child.key == ValueKey(_currentIndex)) {
                              return SlideTransition(
                                position: inAnimation,
                                child: child,
                              );
                            } else {
                              return SlideTransition(
                                position: outAnimation,
                                child: child,
                              );
                            }
                          },
                      child: Text(
                        _textLines[_currentIndex],
                        key: ValueKey(
                          _currentIndex,
                        ), // مفتاح ضروري ليعرف الـ AnimatedSwitcher أن النص تغير
                        style: TextStyle(
                          fontFamily: 'DINNextLT',
                          color: kMainColor.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
