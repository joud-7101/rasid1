import 'package:flutter/material.dart';

class NavBarBottom extends StatelessWidget {
  const NavBarBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // ارتفاع الشريط
      width: double.infinity, // عرض كامل الشاشة
      color: const Color(0xFF074D31), // اللون الأخضر
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // محاذاة النص في المنتصف عموديًا
        children: [
          const SizedBox(height: 30),
          const Text(
            'تم تطويره وصيانته بواسطة فريق عمل النظام',
            style: TextStyle(
              color: Color(0xFFF7FDF9), // لون النص أبيض
              fontSize: 9, // حجم خط صغير
            ),
            textAlign: TextAlign.center, // محاذاة النص في المنتصف
          ),
          const Text(
            'آخر تعديل: 25/4/2025',
            style: TextStyle(
              color: Color(0xFFF7FDF9), // لون النص أبيض
              fontSize: 9, // حجم خط صغير
            ),
            textAlign: TextAlign.center, // محاذاة النص في المنتصف
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class NavBarBottom extends StatelessWidget {
//   const NavBarBottom({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 90, // ارتفاع الشريط
//       width: double.infinity, // عرض كامل الشاشة
//       color: const Color(0xFF074D31), // اللون الأخضر
//     );
//   }
// }
