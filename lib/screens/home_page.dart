import 'package:flutter/material.dart';
import 'package:rasid/widgets/navbar_top.dart';
import 'package:rasid/widgets/navbar_bottom.dart';
import 'package:rasid/screens/service_one_page.dart';
import 'package:rasid/screens/service_two_page.dart';
import 'package:rasid/screens/service_three_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String screenRoute = 'home_screen';

  @override
  _HomePageState createState() => _HomePageState();
}

// ألوان
// F7FDF9
// D2D6DB: رمادي حدود الكارد
// F7F6F6: رمادي إذا لم يضغط الزر
// 0xFFF7FDF9: أخضر فاتح

// 1-ServiceToSeeViolationsPage --> service_see_violations
// 2-ServiceSendViolationsPage --> service_send_violations
// 3-ServiceToViewSentViolationsPage --> service_view_sent_violations

class _HomePageState extends State<HomePage> {
  int? activeServiceIndex;

  void _onServiceTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(
            context, ServiceToViewSentViolationsPage.screenRoute);
        break;
      case 1:
        Navigator.pushNamed(context, ServiceSendViolationsPage.screenRoute);
        break;
      case 2:
        Navigator.pushNamed(context, ServiceToSeeViolationsPage.screenRoute);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBarTop(),
            _buildWelcomeText(),
            // _buildDivider(),
            _buildServiceCards(),
            const NavBarBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: 1000,
      child: const Column(
        children: [
          SizedBox(height: 5),
          Divider(thickness: 0.2, color: Colors.grey),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Padding(
      padding: EdgeInsets.all(35.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10),
          Text(
            'مرحبًا بك مرة أخرى، راصد يرحب بك',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 20),
          Text(
            'الخدمات المقدمة',
            style: TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 10),
          Text(
            'هنا الخدمات المقدمة من قبل راصد يمكنك رؤية المخالفات المرصودة مباشرةً ورفع المخالفات ورؤية المخالفات التي تم إرسالها, اضغط على تقديم الخدمة لتتمكن من استخدام الخدمة',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCards() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ServiceCard(
            title: 'رؤية المخالفات المرسلة',
            description:
                'من هنا يمكنك رؤية المخالفات التي تم التحقق منها وإرسالها',
            color: const Color(0xFF1B8354),
            isActive: activeServiceIndex == 0,
            onTap: () => _onServiceTap(0),
          ),
          const SizedBox(width: 16.0),
          ServiceCard(
            title: 'رفع المخالفات وتحقق',
            description: 'من هنا يمكنك رفع المخالفات والتحقق منها',
            color: const Color(0xFF1B8354),
            isActive: activeServiceIndex == 1,
            onTap: () => _onServiceTap(1),
          ),
          const SizedBox(width: 16.0),
          ServiceCard(
            title: 'رؤية المخالفات الصادرة',
            description:
                'من هنا يمكنك رؤية المخالفات الصادرة التي يتم التقاطها مباشرة عن طريق كاميرا راصد',
            color: const Color(0xFF1B8354),
            isActive: activeServiceIndex == 2,
            onTap: () => _onServiceTap(2),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isActive; // إضافة متغير لتحديد ما إذا كانت الخدمة نشطة

  const ServiceCard({
    Key? key,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    required this.isActive,
  }) : super(key: key);

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovering = false; // متغير لتتبع حالة المرور

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 300,
        height: 200,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xFFD2D6DB), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر
          children: [
            _buildServiceCardContent(),
            _buildServiceButton(),
            const SizedBox(height: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCardContent() {
    return Column(
      children: [
        const SizedBox(height: 5),
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceButton() {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true; // تعيين الحالة إلى true عند المرور
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false; // تعيين الحالة إلى false عند الخروج
        });
      },
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isHovering || widget.isActive
              ? const Color(0xFF1B8354) // اللون عند المرور
              : const Color(0xFFD2D6DB), // اللون الافتراضي
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
        ),
        child: const Text('تقديم الخدمة'),
      ),
    );
  }
}

































// import 'package:flutter/material.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';
// import 'package:rasid/screens/service_one_page.dart';
// import 'package:rasid/screens/service_two_page.dart';
// import 'package:rasid/screens/service_three_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   static const String screenRoute = 'home_screen';

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// // ألوان
// // F7FDF9
// // D2D6DB: رمادي حدود الكارد
// // F7F6F6: رمادي إذا لم يضغط الزر
// // 0xFFF7FDF9 اخضر فاتح

// // 1-ServiceToSeeViolationsPage --> service_see_violations
// // 2-ServiceSendViolationsPage --> service_send_violations
// // 3-ServiceToViewSentViolationsPage --> service_view_sent_violations

// class _HomePageState extends State<HomePage> {
//   int? activeServiceIndex;

//   void _onServiceTap(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushNamed(
//             context, ServiceToViewSentViolationsPage.screenRoute);
//         break;
//       case 1:
//         Navigator.pushNamed(context, ServiceSendViolationsPage.screenRoute);
//         break;
//       case 2:
//         Navigator.pushNamed(context, ServiceToSeeViolationsPage.screenRoute);
//         break;
//       default:
//         // يمكنك إضافة منطق آخر هنا إذا لزم الأمر
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       body: SingleChildScrollView(
//         // استخدام SingleChildScrollView
//         child: Column(
//           children: [
//             const NavBarTop(),

//             const Padding(
//               padding: EdgeInsets.all(35.0), // إضافة حشوة للنصوص
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end, // من اليمين
//                 children: [
//                   SizedBox(height: 10),
//                   Text(
//                     'مرحبًا بك مرة أخرى، راصد يرحب بك',
//                     style: TextStyle(
//                       color: Colors.grey, // لون رمادي
//                       fontSize: 12, // حجم خط صغير
//                     ),
//                     textAlign: TextAlign.right, // محاذاة النص لليمين
//                   ),
//                   SizedBox(height: 20), // مسافة بين النصوص

//                   // عنوان الخدمات المقدمة
//                   Text(
//                     'الخدمات المقدمة',
//                     style: TextStyle(
//                       color: Colors.black, // لون أسود
//                       fontSize: 30, // حجم خط كبير
//                       fontWeight: FontWeight.bold, // خط عريض
//                     ),
//                     textAlign: TextAlign.right, // محاذاة النص لليمين
//                   ),
//                   SizedBox(height: 10), // مسافة بين العنوان والوصف

//                   // وصف الخدمات المقدمة
//                   Text(
//                     'هنا الخدمات المقدمة من قبل راصد يمكنك رؤية المخالفات المرصودة مباشرةً ورفع المخالفات ورؤية المخالفات التي تم إرسالها, اضغط على تقديم الخدمة لتتمكن من استخدام الخدمة',
//                     style: TextStyle(
//                       fontSize: 16, // حجم خط 16
//                       color: Colors.black, // لون أسود
//                     ),
//                     textAlign: TextAlign.right, // محاذاة النص لليمين
//                   ),
//                 ],
//               ),
//             ),

//             // مساحة لعرض بطاقات الخدمات
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(30.0),
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ServiceCard(
//                     title: 'رؤية المخالفات المرسلة',
//                     description:
//                         'من هنا يمكنك رؤية المخالفات التي تم التحقق منها وإرسالها',
//                     color: const Color(0xFF1B8354),
//                     isActive: activeServiceIndex == 0,
//                     onTap: () {
//                       _onServiceTap(0);
//                     },
//                   ),
//                   const SizedBox(width: 16.0),
//                   ServiceCard(
//                     title: 'رفع المخالفات وتحقق',
//                     description: 'من هنا يمكنك رفع المخالفات والتحقق منها',
//                     color: const Color(0xFF1B8354),
//                     isActive: activeServiceIndex == 1,
//                     onTap: () {
//                       _onServiceTap(1);
//                     },
//                   ),
//                   const SizedBox(width: 16.0),
//                   ServiceCard(
//                     title: 'رؤية المخالفات الصادرة',
//                     description:
//                         'من هنا يمكنك رؤية المخالفات الصادرة التي يتم التقاطها مباشرة عن طريق كاميرا راصد',
//                     color: const Color(0xFF1B8354),
//                     isActive: activeServiceIndex == 2,
//                     onTap: () {
//                       _onServiceTap(2);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const NavBarBottom(),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: const NavBarBottom(),
//     );
//   }
// }

// class ServiceCard extends StatefulWidget {
//   final String title;
//   final String description;
//   final Color color; // يمكنك استخدام هذا المتغير إذا كنت بحاجة إليه
//   final VoidCallback onTap;
//   final bool isActive; // إضافة متغير لتحديد ما إذا كانت الخدمة نشطة

//   const ServiceCard({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.color,
//     required this.onTap,
//     required this.isActive, // إضافة المتغير هنا
//   }) : super(key: key);

//   @override
//   _ServiceCardState createState() => _ServiceCardState();
// }

// class _ServiceCardState extends State<ServiceCard> {
//   bool _isHovering = false; // متغير لتتبع حالة المرور

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         width: 300,
//         height: 200,
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10.0),
//           border: Border.all(color: const Color(0xFFD2D6DB), width: 1),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween, // توزيع العناصر
//           children: [
//             Column(
//               children: [
//                 const SizedBox(height: 5),
//                 Text(
//                   widget.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   widget.description,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//             MouseRegion(
//               onEnter: (_) {
//                 setState(() {
//                   _isHovering = true; // تعيين الحالة إلى true عند المرور
//                 });
//               },
//               onExit: (_) {
//                 setState(() {
//                   _isHovering = false; // تعيين الحالة إلى false عند الخروج
//                 });
//               },
//               child: ElevatedButton(
//                 onPressed: widget.onTap,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _isHovering || widget.isActive
//                       ? const Color(0xFF1B8354) // اللون عند المرور
//                       : const Color(0xFFD2D6DB), // اللون الافتراضي
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text('تقديم الخدمة'),
//               ),
//             ),
//             const SizedBox(height: 0.1),
//           ],
//         ),
//       ),
//     );import 'package:flutter/material.dart';
