import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moona/screens/main/widgets/floating_action_button.dart';

import '../../../managers/network_manager.dart';
import '../../../utils/resources/app_colors.dart';
import '../../categories/ui/categories_screen.dart';
import '../../home/ui/home_screen.dart';
import '../../home/ui/widgets/app_bar_widget.dart';
import '../../orders/orders_screen.dart';
import '../more_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    OrdersScreen(), // طلباتي
    MoreScreen(), // المزيد
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkService().start(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: light2Green,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: FloatingActionButtonWidget(),
              body: Stack(
                children: [
                  _screens[_currentIndex],
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _FloatingNavBar(
                      currentIndex: _currentIndex,
                      onTap: _onTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // هوامش ممتازة لجعله عائماً بالكامل كجزيرة مستقلة عن الحواف
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: CustomPaint(
        painter: _FloatingNavbarPainter(),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: 'assets/images/home.svg',
                title: 'الرئيسية',
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: 'assets/images/categories.svg',
                title: 'التصنيفات',
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // الفراغ المخصص ليتمركز فوقه الزر العائم (السلة) تماماً
              const SizedBox(width: 48),

              _NavItem(
                icon: 'assets/images/orders.svg',
                title: 'طلباتي',
                active: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: 'assets/images/more.svg',
                title: 'المزيد',
                active: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? kMainColor : kTitleGreyColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: active ? 1.12 : 1.0,
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, active ? -2 : 0, 0),
                child: SvgPicture.asset(icon, color: color, height: 22),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// الرسام الخاص برسم خلفية الشريط مع التجويف والظلال بدقة تماثل التصميم المستهدف
class _FloatingNavbarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // محاكاة نفس خصائص الـ BoxShadow الأصلية بدقة
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    final path = Path();
    const double r = 16.0; // نصف قطر انحناء زوايا الشريط الدائرية
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;

    // بدء الرسم من الزاوية العلوية اليسرى
    path.moveTo(r, 0);

    // رسم الخط العلوي وصولاً إلى بداية انحناء تجويف السلة
    path.lineTo(cx - 45, 0);

    // رسم منحنى تجويف السلة الانسيابي (Smooth Cubic Notch)
    path.cubicTo(cx - 25, 0, cx - 25, 26, cx, 26);
    path.cubicTo(cx + 25, 26, cx + 25, 0, cx + 45, 0);

    // إكمال الخط العلوي إلى الزاوية العلوية اليمنى
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    // الزاوية السفلية اليمنى
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);

    // الزاوية السفلية اليسرى
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);

    // العودة لنقطة البداية وإغلاق المسار
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    // رسم الظل أولاً مع إزاحته للأسفل بمقدار Offset(0, 12)
    canvas.save();
    canvas.translate(0, 12);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // رسم مجسم الشريط الأبيض فوق الظل
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
