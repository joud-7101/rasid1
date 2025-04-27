import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rasid/widgets/navbar_top.dart';
import 'package:rasid/widgets/navbar_bottom.dart';

// خدمة عرض المخالفات المرسلة
class ServiceToViewSentViolationsPage extends StatefulWidget {
  const ServiceToViewSentViolationsPage({super.key});
  static const String screenRoute = 'service_view_sent_violations';

  @override
  _ServiceToViewSentViolationsPageState createState() =>
      _ServiceToViewSentViolationsPageState();
}

class _ServiceToViewSentViolationsPageState
    extends State<ServiceToViewSentViolationsPage> {
  List<Map<String, dynamic>> sentViolationsList = [];

  @override
  void initState() {
    super.initState();
    fetchSentViolations();
  }

  Future<void> fetchSentViolations() async {
    final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

    try {
      final snapshot = await databaseReference.once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map) {
        sentViolationsList.clear();
        data.forEach((key, value) {
          sentViolationsList.add({
            'violationNumber': value['violationNumber'],
            'phoneNumber': value['phoneNumber'],
            'carNumber': value['carNumber'],
            'violationDate': value['violationDate'],
            'violationMessage': value['violationMessage'],
            'violationDetails': value['violationDetails'],
          });
        });
        setState(() {}); // تحديث الواجهة بعد جلب البيانات
      } else {
        print('No sent violations found.');
      }
    } catch (e) {
      print('Error fetching sent violations: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        children: [
          const NavBarTop(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildDivider(),
                  ...sentViolationsList
                      .map((violation) => _buildViolationCard(violation)),
                ],
              ),
            ),
          ),
          const NavBarBottom(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.all(35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 10),
            Text(
              'النظام  لرصد المخالفات المرورية',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20),
            Text(
              'المخالفات التي تم ارسالها',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              'من هنا يمكنك رؤية المخالفات التي تم رفعها وتحقق منها وأرسالها كا مخالفة مسبقًا',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: double.infinity,
      child: const Column(
        children: [
          SizedBox(height: 5),
          Divider(thickness: 0.2, color: Colors.grey),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildViolationCard(Map<String, dynamic> violation) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'رقم المخالفة: ${violation['violationNumber']}',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            'رقم الهاتف: ${violation['phoneNumber']}',
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          const SizedBox(height: 5.0),
          Text(
            'رقم السيارة: ${violation['carNumber']}',
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          const SizedBox(height: 5.0),
          Text(
            'تاريخ المخالفة: ${violation['violationDate']}',
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          const SizedBox(height: 5.0),
          Text(
            'رسالة المخالفة: ${violation['violationMessage']}',
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
          const SizedBox(height: 5.0),
          Text(
            'تفاصيل المخالفة: ${violation['violationDetails']}',
            style: const TextStyle(fontSize: 14.0, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
