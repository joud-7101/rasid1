import 'package:flutter/material.dart';
import 'package:rasid/widgets/navbar_top.dart';
import 'package:rasid/widgets/navbar_bottom.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rasid/widgets/web_image_widget.dart';

class ServiceSendViolationsPage extends StatefulWidget {
  const ServiceSendViolationsPage({super.key});

  static const String screenRoute = 'service_send_violations';

  @override
  _ServiceSendViolationsPageState createState() =>
      _ServiceSendViolationsPageState();
}

class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
  int? activeServiceIndex;
  List<Map<String, dynamic>> violationsList = [];

  @override
  void initState() {
    super.initState();
    fetchViolationNumbers();
  }

  Future<void> fetchViolationNumbers() async {
    final databaseReference =
        FirebaseDatabase.instance.ref("violation_information");

    try {
      final snapshot = await databaseReference.once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map) {
        violationsList.clear();
        data.forEach((key, value) {
          violationsList.add({
            'violationNumber': value['violationNumber'],
            'imageUrl': value['imageUrl'],
          });
        });
        setState(() {});
      } else {
        print('No data found or data is not in the expected format.');
      }
    } catch (e) {
      print('Error fetching violation details: ${e.toString()}');
    }
  }

  Future<void> saveViolationInformation(
    int violationNumber,
    String phoneNumber,
    String carNumber,
    String violationDate,
    String violationMessage,
    String violationDetails,
  ) async {
    final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

    try {
      await databaseReference.push().set({
        'violationNumber': violationNumber,
        'phoneNumber': phoneNumber,
        'carNumber': carNumber,
        'violationDate': violationDate,
        'violationMessage': violationMessage,
        'violationDetails': violationDetails,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال المخالفة بنجاح.')),
      );
    } catch (e) {
      print('Error saving violation information: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال المخالفة.')),
      );
    }
  }

  void _sendViolation(
    int number,
    String? phoneNumber,
    String? carNumber,
    String? violationDate,
    String? violationMessage,
    String? violationDetails,
  ) {
    if (phoneNumber != null &&
        carNumber != null &&
        violationDate != null &&
        violationMessage != null &&
        violationDetails != null) {
      saveViolationInformation(
        number,
        phoneNumber,
        carNumber,
        violationDate,
        violationMessage,
        violationDetails,
      );
    } else {
      print('يرجى تعبئة جميع الحقول قبل إرسال المخالفة.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const NavBarTop(),
              _buildHeader(),
              ...violationsList
                  .map((violation) => _buildViolationContainer(violation))
                  .toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBarBottom(),
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
              'خدمة رفع المخالفات وتحقق',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 10),
            Text(
              'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationContainer(Map<String, dynamic> violation) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildViolationHeader(violation),
          _buildViolationDetails(violation),
        ],
      ),
    );
  }

  Widget _buildViolationHeader(Map<String, dynamic> violation) {
    return Align(
      alignment: Alignment.topRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTextStyle(
            text: '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 14, 39, 2),
          ),
          const SizedBox(height: 5.0),
          const Text(
            'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildViolationDetails(Map<String, dynamic> violation) {
    return Row(
      children: [
        if (violation['imageUrl'] != null)
          _buildImageContainer(violation['imageUrl']),
        const SizedBox(width: 10.0), // Add spacing between image and form
        Expanded(
          child: _buildViolationForm(violationsList.first['violationNumber']),
        ),
      ],
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: 150,
      height: 150,
      margin: const EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: WebImageWidget(imageUrl),
      ),
    );
  }

  Widget _buildTextStyle({
    required String text,
    double fontSize = 12.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  Widget _buildViolationForm(int violationNumber) {
    final formKey = GlobalKey<FormState>();
    String? phoneNumber,
        carNumber,
        violationDate,
        violationMessage,
        violationDetails;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTextField(
            label: 'تفاصيل المخالفة',
            hintText: 'أدخل تفاصيل المخالفة هنا',
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'يرجى إدخال تفاصيل المخالفة';
              return null;
            },
            onChanged: (value) => violationDetails = value,
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'رقم الهاتف',
                  hintText: '+966 000 000 000',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'يرجى إدخال رقم الهاتف';
                    return null;
                  },
                  onChanged: (value) => phoneNumber = value,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildTextField(
                  label: 'رقم السيارة',
                  hintText: '0000',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'يرجى إدخال رقم السيارة';
                    return null;
                  },
                  onChanged: (value) => carNumber = value,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildTextField(
                  label: 'تاريخ المخالفة',
                  hintText: 'YYYY-MM-DD',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'يرجى إدخال تاريخ المخالفة';
                    return null;
                  },
                  onChanged: (value) => violationDate = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _buildTextField(
            label: 'رسالة المخالفة',
            hintText: ' ...المحترم صاحب المركبة رقم ',
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'يرجى إدخال رسالة المخالفة';
              return null;
            },
            onChanged: (value) => violationMessage = value,
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _sendEmail(violationNumber);
                _sendViolation(
                  violationNumber,
                  phoneNumber,
                  carNumber,
                  violationDate,
                  violationMessage,
                  violationDetails,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8354),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text(
              'إرسال المخالفة',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmail(int violationNumber) async {
    try {
      final url = Uri.parse('https://freeemailapi.vercel.app/sendEmail/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "toEmail": "alalmsabi@gmail.com",
          "title": "Violation",
          "subject": " Violation number $violationNumber",
          "body":
              "Dear Vehicle Owner Number [4204],\n\nWe would like to inform you that your behavioral violation, which contravenes safety regulations, has been recorded.We kindly request that you promptly settle the prescribed violation amount through the approved platform. Thank you for your cooperation."
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'emailSendSuccess') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('تم إرسال البريد الإلكتروني بنجاح')));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('فشل: $responseData')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('فشل: $e')));
    }
  }

  Widget _buildTextField({
    required String label,
    String? hintText,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 150, 148)),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1B8354)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD2D6DB)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}


















// // --
// import 'package:flutter/material.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ServiceSendViolationsPage extends StatefulWidget {
//   const ServiceSendViolationsPage({super.key});

//   static const String screenRoute = 'service_send_violations';

//   @override
//   _ServiceSendViolationsPageState createState() =>
//       _ServiceSendViolationsPageState();
// }

// class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
//   int? activeServiceIndex;
//   List<Map<String, dynamic>> violationsList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchViolationNumbers();
//   }

//   Future<void> fetchViolationNumbers() async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref("violation_information");

//     try {
//       final snapshot = await databaseReference.once();
//       final data = snapshot.snapshot.value;

//       if (data != null && data is Map) {
//         violationsList.clear();
//         data.forEach((key, value) {
//           violationsList.add({
//             'violationNumber': value['violationNumber'],
//             'imageUrl': value['imageUrl'],
//           });
//         });
//         setState(() {});
//       } else {
//         print('No data found or data is not in the expected format.');
//       }
//     } catch (e) {
//       print('Error fetching violation details: ${e.toString()}');
//     }
//   }

//   Future<void> saveViolationInformation(
//     int violationNumber,
//     String phoneNumber,
//     String carNumber,
//     String violationDate,
//     String violationMessage,
//     String violationDetails,
//   ) async {
//     final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

//     try {
//       await databaseReference.push().set({
//         'violationNumber': violationNumber,
//         'phoneNumber': phoneNumber,
//         'carNumber': carNumber,
//         'violationDate': violationDate,
//         'violationMessage': violationMessage,
//         'violationDetails': violationDetails,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم إرسال المخالفة بنجاح.')),
//       );
//     } catch (e) {
//       print('Error saving violation information: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('حدث خطأ أثناء إرسال المخالفة.')),
//       );
//     }
//   }

//   void _sendViolation(
//     int number,
//     String? phoneNumber,
//     String? carNumber,
//     String? violationDate,
//     String? violationMessage,
//     String? violationDetails,
//   ) {
//     if (phoneNumber != null &&
//         carNumber != null &&
//         violationDate != null &&
//         violationMessage != null &&
//         violationDetails != null) {
//       saveViolationInformation(
//         number,
//         phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//       );
//     } else {
//       print('يرجى تعبئة جميع الحقول قبل إرسال المخالفة.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const NavBarTop(),
//               _buildHeader(),
//               ...violationsList
//                   .map((violation) => _buildViolationContainer(violation))
//                   .toList(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const NavBarBottom(),
//     );
//   }

//   Widget _buildHeader() {
//     return const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 10),
//             Text(
//               'راصد لرصد المخالفات المرورية',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'خدمة رفع المخالفات وتحقق',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
//               style: TextStyle(fontSize: 16, color: Colors.black),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViolationContainer(Map<String, dynamic> violation) {
//     return Container(
//       padding: const EdgeInsets.all(15.0),
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: [
//           _buildViolationHeader(violation),
//           _buildViolationDetails(violation),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationHeader(Map<String, dynamic> violation) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextStyle(
//             text: '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
//             fontSize: 14.0,
//             fontWeight: FontWeight.bold,
//             color: const Color.fromARGB(255, 14, 39, 2),
//           ),
//           const SizedBox(height: 5.0),
//           const Text(
//             'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
//             textAlign: TextAlign.right,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationDetails(Map<String, dynamic> violation) {
//     return Row(
//       children: [
//         if (violation['imageUrl'] != null)
//           _buildImageContainer(violation['imageUrl']),
//         const SizedBox(width: 10.0), // Add spacing between image and form
//         Expanded(
//           child: _buildViolationForm(violationsList.first['violationNumber']),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContainer(String imageUrl) {
//     return Container(
//       width: 150,
//       height: 150,
//       margin: const EdgeInsets.only(right: 20.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.0),
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent? loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                         (loadingProgress.expectedTotalBytes ?? 1)
//                     : null,
//               ),
//             );
//           },
//           errorBuilder:
//               (BuildContext context, Object error, StackTrace? stackTrace) {
//             return const Center(child: Text('خطأ في تحميل الصورة'));
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTextStyle({
//     required String text,
//     double fontSize = 12.0,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black,
//   }) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }

//   Widget _buildViolationForm(int violationNumber) {
//     final formKey = GlobalKey<FormState>();
//     String? phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//         email; // إضافة متغير لحفظ الإيميل

//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextField(
//             label: 'تفاصيل المخالفة',
//             hintText: 'أدخل تفاصيل المخالفة هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال تفاصيل المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationDetails = value,
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'البريد الإلكتروني', // حقل البريد الإلكتروني
//             hintText: 'أدخل البريد الإلكتروني هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال البريد الإلكتروني';
//               return null;
//             },
//             onChanged: (value) => email = value, // حفظ قيمة الإيميل
//           ),
//           const SizedBox(height: 10.0),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم الهاتف',
//                   hintText: '+966 000 000 000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم الهاتف';
//                     return null;
//                   },
//                   onChanged: (value) => phoneNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم السيارة',
//                   hintText: '0000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم السيارة';
//                     return null;
//                   },
//                   onChanged: (value) => carNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'تاريخ المخالفة',
//                   hintText: 'YYYY-MM-DD',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال تاريخ المخالفة';
//                     return null;
//                   },
//                   onChanged: (value) => violationDate = value,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'رسالة المخالفة',
//             hintText: ' ...المحترم صاحب المركبة رقم ',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال رسالة المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationMessage = value,
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 await _sendEmail(violationNumber, email); // تمرير الإيميل
//                 _sendViolation(
//                   violationNumber,
//                   phoneNumber,
//                   carNumber,
//                   violationDate,
//                   violationMessage,
//                   violationDetails,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1B8354),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0)),
//             ),
//             child: const Text(
//               'إرسال المخالفة',
//               style: TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _sendEmail(int violationNumber, String? email) async {
//     try {
//       final url = Uri.parse('https://freeemailapi.vercel.app/sendEmail/');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({
//           "toEmail": email ??
//               "alalmsabi@gmail.com", // استخدام الإيميل المدخل أو الافتراضي
//           "title": "RASID",
//           "subject": "Violation number $violationNumber",
//           "body":
//               "Dear Vehicle Owner Number [4204],\n\nWe would like to inform you that your behavioral violation, which contravenes safety regulations, has been recorded.\n\nWe kindly request that you promptly settle the prescribed violation amount through the approved platform.\n\nThank you for your cooperation.\n\nRasid."
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['message'] == 'emailSendSuccess') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text('تم إرسال البريد الإلكتروني بنجاح')));
//         } else {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text('فشل: $responseData')));
//         }
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('فشل: ${response.body}')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('فشل: $e')));
//     }
//   }

//   Widget _buildTextField({
//     required String label,
//     String? hintText,
//     required String? Function(String?) validator,
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextFormField(
//       textAlign: TextAlign.right,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 150, 148)),
//         border: const OutlineInputBorder(),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF1B8354)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFFD2D6DB)),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
// }



// -------





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http; // تأكد من استيراد مكتبة http
// import 'dart:convert'; // لاستعمال jsonEncode
// import 'package:firebase_database/firebase_database.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';

// class ServiceSendViolationsPage extends StatefulWidget {
//   const ServiceSendViolationsPage({super.key});

//   static const String screenRoute = 'service_send_violations';

//   @override
//   _ServiceSendViolationsPageState createState() =>
//       _ServiceSendViolationsPageState();
// }

// class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
//   int? activeServiceIndex;
//   List<Map<String, dynamic>> violationsList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchViolationNumbers();
//   }

//   Future<void> fetchViolationNumbers() async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref("violation_information");

//     try {
//       final snapshot = await databaseReference.once();
//       final data = snapshot.snapshot.value;

//       if (data != null && data is Map) {
//         violationsList.clear();
//         data.forEach((key, value) {
//           violationsList.add({
//             'violationNumber': value['violationNumber'],
//             'imageUrl': value['imageUrl'],
//           });
//         });
//         setState(() {});
//       } else {
//         print('No data found or data is not in the expected format.');
//       }
//     } catch (e) {
//       print('Error fetching violation details: ${e.toString()}');
//     }
//   }

//   Future<void> saveViolationInformation(
//     int violationNumber,
//     String phoneNumber,
//     String carNumber,
//     String violationDate,
//     String violationMessage,
//     String violationDetails,
//   ) async {
//     final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

//     try {
//       await databaseReference.push().set({
//         'violationNumber': violationNumber,
//         'phoneNumber': phoneNumber,
//         'carNumber': carNumber,
//         'violationDate': violationDate,
//         'violationMessage': violationMessage,
//         'violationDetails': violationDetails,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم إرسال المخالفة بنجاح.')),
//       );
//     } catch (e) {
//       print('Error saving violation information: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('حدث خطأ أثناء إرسال المخالفة.')),
//       );
//     }
//   }
//   Future<void> _sendSMS(String phoneNumber, String carNumber) async {
//   String message =
//       'نحيطكم علماً بأنه تم رصد مخالفتكم السلوكية التي تخالف أنظمة السلامة. نرجو منكم سرعة سداد مبلغ المخالفة المقررة من خلال المنصة المعتمدة. المحترم مالك المركبة رقم: $carNumber. شكراً لتعاونكم، راصد.';

//   final url = Uri.parse('https://rest.nexmo.com/sms/json');

//   try {
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'api_key': '2a767343', // استبدل بمفتاح API الخاص بك
//         'api_secret': 'aQk1gVXdiDmqiJDJ', // استبدل بسر API الخاص بك
//         'to': phoneNumber,
//         'from': '14155550101', // استبدل برقم الافتراضي من Nexmo
//         'text': message,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('SMS sent successfully');
//       print('Response: ${response.body}');
//     } else {
//       print('Failed to send SMS: ${response.statusCode} - ${response.body}');
//     }
//   } catch (e) {
//     print('Error sending SMS: ${e.toString()}');
//   }
// }

//   // Future<void> _sendSMS(String phoneNumber, String carNumber) async {
//   //   String message =
//   //       'نحيطكم علماً بأنه تم رصد مخالفتكم السلوكية التي تخالف أنظمة السلامة. نرجو منكم سرعة سداد مبلغ المخالفة المقررة من خلال المنصة المعتمدة. المحترم مالك المركبة رقم: $carNumber. شكراً لتعاونكم، راصد.';

//   //   final url = Uri.parse('https://rest.nexmo.com/sms/json');

//   //   try {
//   //     final response = await http.post(
//   //       url,
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: jsonEncode({
//   //         'api_key': '2a767343', // استبدل بمفتاح API الخاص بك
//   //         'api_secret': 'aQk1gVXdiDmqiJDJ', // استبدل بسر API الخاص بك
//   //         'to': phoneNumber,
//   //         'from': '14155550101', // استبدل برقم الافتراضي من Nexmo
//   //         'text': message,
//   //       }),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       print('SMS sent successfully');
//   //       print('Response: ${response.body}');
//   //     } else {
//   //       print('Failed to send SMS: ${response.statusCode} - ${response.body}');
//   //     }
//   //   } catch (e) {
//   //     print('Error sending SMS: ${e.toString()}');
//   //   }
//   // }

//   void _sendViolation(
//     int number,
//     String? phoneNumber,
//     String? carNumber,
//     String? violationDate,
//     String? violationMessage,
//     String? violationDetails,
//   ) {
//     // تحقق من صحة رقم الهاتف
//     if (phoneNumber != null && phoneNumber.isNotEmpty) {
//       // إضافة مفتاح الدولة إذا لم يكن موجودًا
//       if (!phoneNumber.startsWith('+966')) {
//         if (phoneNumber.startsWith('5') && phoneNumber.length == 10) {
//           phoneNumber =
//               '+966${phoneNumber.substring(1)}'; // إزالة الصفر وإضافة مفتاح الدولة
//         } else if (phoneNumber.length == 9) {
//           phoneNumber = '+966$phoneNumber'; // إضافة مفتاح الدولة
//         } else {
//           print('رقم الهاتف يجب أن يكون 9 أرقام بعد مفتاح الدولة.');
//           return;
//         }
//       }

//       // الطباعة للتحقق من الرقم
//       print('Formatted phone number: $phoneNumber');

//       // التحقق من أن الرقم يحتوي على 13 حرفًا (بما في ذلك مفتاح الدولة)
//       if (phoneNumber.length != 13) {
//         print('رقم الهاتف يجب أن يتكون من 13 حرفًا (بما في ذلك مفتاح الدولة).');
//         return;
//       }

//       // التحقق من أن الرقم يبدأ بالرقم 5
//       if (!phoneNumber.substring(4, 5).startsWith('5')) {
//         print('رقم الهاتف يجب أن يبدأ بالرقم 5.');
//         return;
//       }
//     } else {
//       print('رقم الهاتف مطلوب.');
//       return;
//     }

//     // إضافة شرط التحقق قبل إرسال الرسالة
//     if (carNumber != null &&
//         violationDate != null &&
//         violationMessage != null &&
//         violationDetails != null) {
//       saveViolationInformation(
//         number,
//         phoneNumber!,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//       );
//       _sendSMS(phoneNumber!, carNumber!); // استدعاء دالة إرسال SMS
//     } else {
//       print('يرجى تعبئة جميع الحقول قبل إرسال المخالفة.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const NavBarTop(),
//               _buildHeader(),
//               ...violationsList
//                   .map((violation) => _buildViolationContainer(violation))
//                   .toList(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const NavBarBottom(),
//     );
//   }

//   Widget _buildHeader() {
//     return const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 10),
//             Text(
//               'راصد لرصد المخالفات المرورية',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'خدمة رفع المخالفات وتحقق',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
//               style: TextStyle(fontSize: 16, color: Colors.black),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViolationContainer(Map<String, dynamic> violation) {
//     return Container(
//       padding: const EdgeInsets.all(15.0),
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[500]!),
//       ),
//       child: Column(
//         children: [
//           _buildViolationHeader(violation),
//           _buildViolationDetails(violation),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationHeader(Map<String, dynamic> violation) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextStyle(
//             text: '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
//             fontSize: 14.0,
//             fontWeight: FontWeight.bold,
//             color: const Color.fromARGB(255, 14, 39, 2),
//           ),
//           const SizedBox(height: 5.0),
//           const Text(
//             'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
//             textAlign: TextAlign.right,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationDetails(Map<String, dynamic> violation) {
//     return Row(
//       children: [
//         if (violation['imageUrl'] != null)
//           _buildImageContainer(violation['imageUrl']),
//         const SizedBox(width: 10.0),
//         Expanded(
//           child: _buildViolationForm(violationsList.first['violationNumber']),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContainer(String imageUrl) {
//     return Container(
//       width: 150,
//       height: 150,
//       margin: const EdgeInsets.only(right: 20.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.0),
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent? loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                         (loadingProgress.expectedTotalBytes ?? 1)
//                     : null,
//               ),
//             );
//           },
//           errorBuilder:
//               (BuildContext context, Object error, StackTrace? stackTrace) {
//             return const Center(child: Text('خطأ في تحميل الصورة'));
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTextStyle({
//     required String text,
//     double fontSize = 12.0,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black,
//   }) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }

//   Widget _buildViolationForm(int violationNumber) {
//     final formKey = GlobalKey<FormState>();
//     String? phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails;

//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextField(
//             label: 'تفاصيل المخالفة',
//             hintText: 'أدخل تفاصيل المخالفة هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال تفاصيل المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationDetails = value,
//           ),
//           const SizedBox(height: 10.0),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم الهاتف',
//                   hintText: '+966 500 000 000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم الهاتف';
//                     return null;
//                   },
//                   onChanged: (value) => phoneNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم السيارة',
//                   hintText: '0000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم السيارة';
//                     return null;
//                   },
//                   onChanged: (value) => carNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'تاريخ المخالفة',
//                   hintText: 'YYYY-MM-DD',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال تاريخ المخالفة';
//                     return null;
//                   },
//                   onChanged: (value) => violationDate = value,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'رسالة المخالفة',
//             hintText: ' ...المحترم صاحب المركبة رقم ',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال رسالة المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationMessage = value,
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 _sendViolation(
//                   violationNumber,
//                   phoneNumber,
//                   carNumber,
//                   violationDate,
//                   violationMessage,
//                   violationDetails,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1B8354),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0)),
//             ),
//             child: const Text(
//               'إرسال المخالفة',
//               style: TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     String? hintText,
//     required String? Function(String?) validator,
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextFormField(
//       textAlign: TextAlign.right,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 150, 148)),
//         border: const OutlineInputBorder(),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF1B8354)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFFD2D6DB)),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';
// import 'package:firebase_database/firebase_database.dart';

// class ServiceSendViolationsPage extends StatefulWidget {
//   const ServiceSendViolationsPage({super.key});

//   static const String screenRoute = 'service_send_violations';

//   @override
//   _ServiceSendViolationsPageState createState() =>
//       _ServiceSendViolationsPageState();
// }

// class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
//   int? activeServiceIndex;
//   List<Map<String, dynamic>> violationsList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchViolationNumbers();
//   }

//   Future<void> fetchViolationNumbers() async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref("violation_information");

//     try {
//       final snapshot = await databaseReference.once();
//       final data = snapshot.snapshot.value;

//       if (data != null && data is Map) {
//         violationsList.clear();
//         data.forEach((key, value) {
//           violationsList.add({
//             'violationNumber': value['violationNumber'],
//             'imageUrl': value['imageUrl'],
//           });
//         });
//         setState(() {});
//       } else {
//         print('No data found or data is not in the expected format.');
//       }
//     } catch (e) {
//       print('Error fetching violation details: ${e.toString()}');
//     }
//   }

//   Future<void> saveViolationInformation(
//     int violationNumber,
//     String phoneNumber,
//     String carNumber,
//     String violationDate,
//     String violationMessage,
//     String violationDetails,
//   ) async {
//     final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

//     try {
//       await databaseReference.push().set({
//         'violationNumber': violationNumber,
//         'phoneNumber': phoneNumber,
//         'carNumber': carNumber,
//         'violationDate': violationDate,
//         'violationMessage': violationMessage,
//         'violationDetails': violationDetails,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم إرسال المخالفة بنجاح.')),
//       );
//     } catch (e) {
//       print('Error saving violation information: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('حدث خطأ أثناء إرسال المخالفة.')),
//       );
//     }
//   }

//   void _sendViolation(
//     int number,
//     String? phoneNumber,
//     String? carNumber,
//     String? violationDate,
//     String? violationMessage,
//     String? violationDetails,
//   ) {
//     // تحقق من صحة رقم الهاتف
//     if (phoneNumber != null && phoneNumber.isNotEmpty) {
//       // إضافة مفتاح الدولة إذا لم يكن موجودًا
//       if (!phoneNumber.startsWith('+966')) {
//         if (phoneNumber.startsWith('5') && phoneNumber.length == 10) {
//           phoneNumber =
//               '+966${phoneNumber.substring(1)}'; // إزالة الصفر وإضافة مفتاح الدولة
//         } else if (phoneNumber.length == 9) {
//           phoneNumber = '+966$phoneNumber'; // إضافة مفتاح الدولة
//         } else {
//           print('رقم الهاتف يجب أن يكون 9 أرقام بعد مفتاح الدولة.');
//           return;
//         }
//       }

//       // الطباعة للتحقق من الرقم
//       print('Formatted phone number: $phoneNumber');

//       // التحقق من أن الرقم يحتوي على 13 حرفًا (بما في ذلك مفتاح الدولة)
//       if (phoneNumber.length != 13) {
//         print('رقم الهاتف يجب أن يتكون من 13 حرفًا (بما في ذلك مفتاح الدولة).');
//         return;
//       }

//       // التحقق من أن الرقم يبدأ بالرقم 5
//       if (!phoneNumber.substring(4, 5).startsWith('5')) {
//         print('رقم الهاتف يجب أن يبدأ بالرقم 5.');
//         return;
//       }
//     } else {
//       print('رقم الهاتف مطلوب.');
//       return;
//     }

//     // إضافة شرط التحقق قبل إرسال الرسالة
//     if (carNumber != null &&
//         violationDate != null &&
//         violationMessage != null &&
//         violationDetails != null) {
//       saveViolationInformation(
//         number,
//         phoneNumber!,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//       );
//     } else {
//       print('يرجى تعبئة جميع الحقول قبل إرسال المخالفة.');
//     }
//   }





//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const NavBarTop(),
//               _buildHeader(),
//               ...violationsList
//                   .map((violation) => _buildViolationContainer(violation))
//                   .toList(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const NavBarBottom(),
//     );
//   }

//   Widget _buildHeader() {
//     return const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 10),
//             Text(
//               'راصد لرصد المخالفات المرورية',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'خدمة رفع المخالفات وتحقق',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
//               style: TextStyle(fontSize: 16, color: Colors.black),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViolationContainer(Map<String, dynamic> violation) {
//     return Container(
//       padding: const EdgeInsets.all(15.0),
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[500]!),
//       ),
//       child: Column(
//         children: [
//           _buildViolationHeader(violation),
//           _buildViolationDetails(violation),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationHeader(Map<String, dynamic> violation) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextStyle(
//             text: '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
//             fontSize: 14.0,
//             fontWeight: FontWeight.bold,
//             color: const Color.fromARGB(255, 14, 39, 2),
//           ),
//           const SizedBox(height: 5.0),
//           const Text(
//             'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
//             textAlign: TextAlign.right,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationDetails(Map<String, dynamic> violation) {
//     return Row(
//       children: [
//         if (violation['imageUrl'] != null)
//           _buildImageContainer(violation['imageUrl']),
//         const SizedBox(width: 10.0),
//         Expanded(
//           child: _buildViolationForm(violationsList.first['violationNumber']),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContainer(String imageUrl) {
//     return Container(
//       width: 150,
//       height: 150,
//       margin: const EdgeInsets.only(right: 20.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.0),
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent? loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                         (loadingProgress.expectedTotalBytes ?? 1)
//                     : null,
//               ),
//             );
//           },
//           errorBuilder:
//               (BuildContext context, Object error, StackTrace? stackTrace) {
//             return const Center(child: Text('خطأ في تحميل الصورة'));
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTextStyle({
//     required String text,
//     double fontSize = 12.0,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black,
//   }) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }

//   Widget _buildViolationForm(int violationNumber) {
//     final formKey = GlobalKey<FormState>();
//     String? phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails;

//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextField(
//             label: 'تفاصيل المخالفة',
//             hintText: 'أدخل تفاصيل المخالفة هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال تفاصيل المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationDetails = value,
//           ),
//           const SizedBox(height: 10.0),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم الهاتف',
//                   hintText: '+966 500 000 000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم الهاتف';
//                     return null;
//                   },
//                   onChanged: (value) => phoneNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم السيارة',
//                   hintText: '0000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم السيارة';
//                     return null;
//                   },
//                   onChanged: (value) => carNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'تاريخ المخالفة',
//                   hintText: 'YYYY-MM-DD',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال تاريخ المخالفة';
//                     return null;
//                   },
//                   onChanged: (value) => violationDate = value,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'رسالة المخالفة',
//             hintText: ' ...المحترم صاحب المركبة رقم ',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال رسالة المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationMessage = value,
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 _sendViolation(
//                   violationNumber,
//                   phoneNumber,
//                   carNumber,
//                   violationDate,
//                   violationMessage,
//                   violationDetails,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1B8354),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0)),
//             ),
//             child: const Text(
//               'إرسال المخالفة',
//               style: TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     String? hintText,
//     required String? Function(String?) validator,
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextFormField(
//       textAlign: TextAlign.right,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 150, 148)),
//         border: const OutlineInputBorder(),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF1B8354)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFFD2D6DB)),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
// }



// ----------------------------





// ------------------


// import 'package:flutter/material.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ServiceSendViolationsPage extends StatefulWidget {
//   const ServiceSendViolationsPage({super.key});

//   static const String screenRoute = 'service_send_violations';

//   @override
//   _ServiceSendViolationsPageState createState() =>
//       _ServiceSendViolationsPageState();
// }

// class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
//   int? activeServiceIndex;
//   List<Map<String, dynamic>> violationsList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchViolationNumbers();
//   }

//   Future<void> fetchViolationNumbers() async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref("violation_information");

//     try {
//       final snapshot = await databaseReference.once();
//       final data = snapshot.snapshot.value;

//       if (data != null && data is Map) {
//         violationsList.clear();
//         data.forEach((key, value) {
//           violationsList.add({
//             'violationNumber': value['violationNumber'],
//             'imageUrl': value['imageUrl'],
//           });
//         });
//         setState(() {});
//       } else {
//         print('No data found or data is not in the expected format.');
//       }
//     } catch (e) {
//       print('Error fetching violation details: ${e.toString()}');
//     }
//   }

//   Future<void> saveViolationInformation(
//     int violationNumber,
//     String phoneNumber,
//     String carNumber,
//     String violationDate,
//     String violationMessage,
//     String violationDetails,
//   ) async {
//     final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

//     try {
//       await databaseReference.push().set({
//         'violationNumber': violationNumber,
//         'phoneNumber': phoneNumber,
//         'carNumber': carNumber,
//         'violationDate': violationDate,
//         'violationMessage': violationMessage,
//         'violationDetails': violationDetails,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم إرسال المخالفة بنجاح.')),
//       );
//     } catch (e) {
//       print('Error saving violation information: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('حدث خطأ أثناء إرسال المخالفة.')),
//       );
//     }
//   }

//   void _sendViolation(
//     int number,
//     String? phoneNumber,
//     String? carNumber,
//     String? violationDate,
//     String? violationMessage,
//     String? violationDetails,
//   ) {
//     if (phoneNumber != null &&
//         carNumber != null &&
//         violationDate != null &&
//         violationMessage != null &&
//         violationDetails != null) {
//       saveViolationInformation(
//         number,
//         phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//       );
//     } else {
//       print('يرجى تعبئة جميع الحقول قبل إرسال المخالفة.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const NavBarTop(),
//               _buildHeader(),
//               ...violationsList
//                   .map((violation) => _buildViolationContainer(violation))
//                   .toList(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const NavBarBottom(),
//     );
//   }

//   Widget _buildHeader() {
//     return const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 10),
//             Text(
//               'راصد لرصد المخالفات المرورية',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'خدمة رفع المخالفات وتحقق',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
//               style: TextStyle(fontSize: 16, color: Colors.black),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViolationContainer(Map<String, dynamic> violation) {
//     return Container(
//       padding: const EdgeInsets.all(15.0),
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: [
//           _buildViolationHeader(violation),
//           _buildViolationDetails(violation),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationHeader(Map<String, dynamic> violation) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextStyle(
//             text: '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
//             fontSize: 14.0,
//             fontWeight: FontWeight.bold,
//             color: const Color.fromARGB(255, 14, 39, 2),
//           ),
//           const SizedBox(height: 5.0),
//           const Text(
//             'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
//             textAlign: TextAlign.right,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationDetails(Map<String, dynamic> violation) {
//     return Row(
//       children: [
//         if (violation['imageUrl'] != null)
//           _buildImageContainer(violation['imageUrl']),
//         const SizedBox(width: 10.0), // Add spacing between image and form
//         Expanded(
//           child: _buildViolationForm(violationsList.first['violationNumber']),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContainer(String imageUrl) {
//     return Container(
//       width: 150,
//       height: 150,
//       margin: const EdgeInsets.only(right: 20.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.0),
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent? loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                         (loadingProgress.expectedTotalBytes ?? 1)
//                     : null,
//               ),
//             );
//           },
//           errorBuilder:
//               (BuildContext context, Object error, StackTrace? stackTrace) {
//             return const Center(child: Text('خطأ في تحميل الصورة'));
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTextStyle({
//     required String text,
//     double fontSize = 12.0,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black,
//   }) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }

//   Widget _buildViolationForm(int violationNumber) {
//     final formKey = GlobalKey<FormState>();
//     String? phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails;

//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextField(
//             label: 'تفاصيل المخالفة',
//             hintText: 'أدخل تفاصيل المخالفة هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال تفاصيل المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationDetails = value,
//           ),
//           const SizedBox(height: 10.0),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم الهاتف',
//                   hintText: '+966 000 000 000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم الهاتف';
//                     return null;
//                   },
//                   onChanged: (value) => phoneNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم السيارة',
//                   hintText: '0000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم السيارة';
//                     return null;
//                   },
//                   onChanged: (value) => carNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'تاريخ المخالفة',
//                   hintText: 'YYYY-MM-DD',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال تاريخ المخالفة';
//                     return null;
//                   },
//                   onChanged: (value) => violationDate = value,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'رسالة المخالفة',
//             hintText: ' ...المحترم صاحب المركبة رقم ',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال رسالة المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationMessage = value,
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 await _sendEmail(violationNumber);
//                 _sendViolation(
//                   violationNumber,
//                   phoneNumber,
//                   carNumber,
//                   violationDate,
//                   violationMessage,
//                   violationDetails,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1B8354),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0)),
//             ),
//             child: const Text(
//               'إرسال المخالفة',
//               style: TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _sendEmail(int violationNumber) async {
//     try {
//       final url = Uri.parse('https://freeemailapi.vercel.app/sendEmail/');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({
//           "toEmail": "alalmsabi@gmail.com",
//           "title": "RAASID",
//           "subject": "$violationNumber",
//           "body": "A ticket has been issued for you",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['message'] == 'emailSendSuccess') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text('تم إرسال البريد الإلكتروني بنجاح')));
//         } else {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text('فشل: $responseData')));
//         }
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('فشل: ${response.body}')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('فشل: $e')));
//     }
//   }

//   Widget _buildTextField({
//     required String label,
//     String? hintText,
//     required String? Function(String?) validator,
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextFormField(
//       textAlign: TextAlign.right,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 150, 148)),
//         border: const OutlineInputBorder(),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF1B8354)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFFD2D6DB)),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ServiceSendViolationsPage extends StatefulWidget {
//   const ServiceSendViolationsPage({super.key});

//   static const String screenRoute = 'service_send_violations';

//   @override
//   _ServiceSendViolationsPageState createState() =>
//       _ServiceSendViolationsPageState();
// }

// class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
//   int? activeServiceIndex;
//   List<Map<String, dynamic>> violationsList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchViolationNumbers();
//   }

//   /// Fetch violation numbers from Firebase Database
//   Future<void> fetchViolationNumbers() async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref("violation_information");

//     try {
//       final snapshot = await databaseReference.once();
//       final data = snapshot.snapshot.value;

//       if (data != null && data is Map) {
//         violationsList.clear();
//         data.forEach((key, value) {
//           violationsList.add({
//             'violationNumber': value['violationNumber'],
//             'imageUrl': value['imageUrl'],
//           });
//         });
//         setState(() {});
//       } else {
//         print('No data found or data is not in the expected format.');
//       }
//     } catch (e) {
//       print('Error fetching violation details: ${e.toString()}');
//     }
//   }

//   /// Save violation information to Firebase Database
//   Future<void> saveViolationInformation(
//     int violationNumber,
//     String phoneNumber,
//     String carNumber,
//     String violationDate,
//     String violationMessage,
//     String violationDetails,
//   ) async {
//     final databaseReference = FirebaseDatabase.instance.ref('SentViolation');

//     try {
//       await databaseReference.push().set({
//         'violationNumber': violationNumber,
//         'phoneNumber': phoneNumber,
//         'carNumber': carNumber,
//         'violationDate': violationDate,
//         'violationMessage': violationMessage,
//         'violationDetails': violationDetails,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('تم إرسال المخالفة بنجاح.')),
//       );
//     } catch (e) {
//       print('Error saving violation information: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('حدث خطأ أثناء إرسال المخالفة.')),
//       );
//     }
//   }

//   void _sendViolation(
//     int number,
//     String? phoneNumber,
//     String? carNumber,
//     String? violationDate,
//     String? violationMessage,
//     String? violationDetails,
//   ) {
//     if (phoneNumber != null &&
//         carNumber != null &&
//         violationDate != null &&
//         violationMessage != null &&
//         violationDetails != null) {
//       saveViolationInformation(
//         number,
//         phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//       );
//     } else {
//       print('يرجى تعبئة جميع الحقول قبل إرسال المخالفة.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const NavBarTop(),
//             _buildHeader(),
//             ...violationsList
//                 .map((violation) => _buildViolationContainer(violation, h, w))
//                 .toList(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const NavBarBottom(),
//     );
//   }

//   Widget _buildHeader() {
//     return const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 10),
//             Text(
//               'راصد لرصد المخالفات المرورية',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'خدمة رفع المخالفات وتحقق',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
//               style: TextStyle(fontSize: 16, color: Colors.black),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildViolationContainer(
//       Map<String, dynamic> violation, double height, double width) {
//     return Container(
//       height: height * .6,
//       width: width * .9,
//       padding: const EdgeInsets.all(15.0),
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: [
//           _buildViolationHeader(violation, height, width),
//           _buildViolationDetails(violation, height, width),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationHeader(
//       Map<String, dynamic> violation, double height, double width) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           SizedBox(
//             height: height * .15,
//             width: width * .3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _buildTextStyle(
//                   text:
//                       '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
//                   fontSize: 14.0,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 14, 39, 2),
//                 ),
//                 const SizedBox(height: 5.0),
//                 const Text(
//                   'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
//                   textAlign: TextAlign.right,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViolationDetails(
//       Map<String, dynamic> violation, double height, double width) {
//     return SizedBox(
//       height: height * .3,
//       width: width * .9,
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 if (violation['imageUrl'] != null)
//                   _buildImageContainer(violation['imageUrl']),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: _buildViolationForm(violationsList.first['violationNumber']),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageContainer(String imageUrl) {
//     return Container(
//       width: 150,
//       height: 150,
//       margin: const EdgeInsets.only(right: 20.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12.0),
//         child: Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (BuildContext context, Widget child,
//               ImageChunkEvent? loadingProgress) {
//             if (loadingProgress == null) return child;
//             return Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                         (loadingProgress.expectedTotalBytes ?? 1)
//                     : null,
//               ),
//             );
//           },
//           errorBuilder:
//               (BuildContext context, Object error, StackTrace? stackTrace) {
//             return const Center(child: Text('خطأ في تحميل الصورة'));
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTextStyle({
//     required String text,
//     double fontSize = 12.0,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black,
//   }) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }

//   Widget _buildViolationForm(int violationNumber) {
//     final formKey = GlobalKey<FormState>();
//     String? phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails;

//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextField(
//             label: 'تفاصيل المخالفة',
//             hintText: 'أدخل تفاصيل المخالفة هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال تفاصيل المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationDetails = value,
//           ),
//           const SizedBox(height: 10.0),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم الهاتف',
//                   hintText: '+966 000 000 000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم الهاتف';
//                     return null;
//                   },
//                   onChanged: (value) => phoneNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم السيارة',
//                   hintText: '0000',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال رقم السيارة';
//                     return null;
//                   },
//                   onChanged: (value) => carNumber = value,
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'تاريخ المخالفة',
//                   hintText: 'YYYY-MM-DD',
//                   validator: (value) {
//                     if (value == null || value.isEmpty)
//                       return 'يرجى إدخال تاريخ المخالفة';
//                     return null;
//                   },
//                   onChanged: (value) => violationDate = value,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'رسالة المخالفة',
//             hintText: ' ...المحترم صاحب المركبة رقم ',
//             validator: (value) {
//               if (value == null || value.isEmpty)
//                 return 'يرجى إدخال رسالة المخالفة';
//               return null;
//             },
//             onChanged: (value) => violationMessage = value,
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 await _sendEmail(violationNumber);
//                 _sendViolation(
//                   violationNumber,
//                   phoneNumber,
//                   carNumber,
//                   violationDate,
//                   violationMessage,
//                   violationDetails,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1B8354),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0)),
//             ),
//             child: const Text(
//               'إرسال المخالفة',
//               style: TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _sendEmail(int violationNumber) async {
//     try {
//       final url = Uri.parse('https://freeemailapi.vercel.app/sendEmail/');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json; charset=UTF-8'},
//         body: jsonEncode({
//           "toEmail": "alalmsabi@gmail.com",
//           "title": "RAASID",
//           "subject": "$violationNumber",
//           "body": "A ticket has been issued for you",
//         }),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         if (responseData['message'] == 'emailSendSuccess') {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//               content: Text('تم إرسال البريد الإلكتروني بنجاح')));
//         } else {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text('فشل: $responseData')));
//         }
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('فشل: ${response.body}')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('فشل: $e')));
//     }
//   }

//   Widget _buildTextField({
//     required String label,
//     String? hintText,
//     required String? Function(String?) validator,
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextFormField(
//       textAlign: TextAlign.right, // جعل النص من اليمين
//       textDirection: TextDirection.rtl, // تحديد اتجاه النص من اليمين لليسار
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle:
//             const TextStyle(color: Colors.black), // تغيير لون label إلى الأسود
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 150, 148)),
//         border: const OutlineInputBorder(),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF1B8354)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFFD2D6DB)),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//             horizontal: 10.0,
//             vertical: 10.0), // إضافة padding لجعل label أقرب لليمين
//         // alignLabelWithHint: true, // محاذاة label مع hint
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:rasid/widgets/navbar_top.dart';
// import 'package:rasid/widgets/navbar_bottom.dart';
// import 'package:firebase_database/firebase_database.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ServiceSendViolationsPage extends StatefulWidget {
//   const ServiceSendViolationsPage({super.key});

//   static const String screenRoute = 'service_send_violations';

//   @override
//   _ServiceSendViolationsPageState createState() =>
//       _ServiceSendViolationsPageState();
// }

// class _ServiceSendViolationsPageState extends State<ServiceSendViolationsPage> {
//   int? activeServiceIndex;
//   List<Map<String, dynamic>> violationsList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchViolationNumbers();
//     print("👉 2");
//   }

//   Future<void> fetchViolationNumbers() async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref("violation_information");

//     try {
//       final snapshot = await databaseReference.once();
//       final data = snapshot.snapshot.value;

//       if (data != null && data is Map) {
//         violationsList.clear();
//         data.forEach((key, value) {
//           violationsList.add({
//             'violationNumber': value['violationNumber'],
//             'imageUrl': value['imageUrl'], // إضافة رابط الصورة
//           });
//         });
//         setState(() {}); // تحديث الواجهة بعد جلب البيانات
//       } else {
//         print('No data found or data is not in the expected format.');
//       }
//     } catch (e) {
//       print('Error fetching violation details: ${e.toString()}');
//     }
//   }

//   Future<void> saveViolationInformation(
//     int violationNumber,
//     String phoneNumber,
//     String carNumber,
//     String violationDate,
//     String violationMessage,
//     String violationDetails,
//   ) async {
//     final databaseReference =
//         FirebaseDatabase.instance.ref('SentViolation'); // مجموعة البيانات

//     try {
//       // إضافة بيانات المخالفة كعنصر جديد في مجموعة SentViolation
//       await databaseReference.push().set({
//         'violationNumber': violationNumber,
//         'phoneNumber': phoneNumber,
//         'carNumber': carNumber,
//         'violationDate': violationDate,
//         'violationMessage': violationMessage,
//         'violationDetails': violationDetails,
//       });

//       // رسالة النجاح
//       print('Violation information saved successfully.');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم إرسال المخالفة بنجاح.'),
//         ),
//       );
//     } catch (e) {
//       // معالجة الأخطاء
//       print('Error saving violation information: ${e.toString()}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('حدث خطأ أثناء إرسال المخالفة.'),
//         ),
//       );
//     }
//   }

//   void _sendViolation(
//     int number,
//     String? phoneNumber,
//     String? carNumber,
//     String? violationDate,
//     String? violationMessage,
//     String? violationDetails,
//   ) {
//     if (phoneNumber != null &&
//         carNumber != null &&
//         violationDate != null &&
//         violationMessage != null &&
//         violationDetails != null) {
//       saveViolationInformation(
//         number,
//         phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails,
//       );
//     } else {
//       print('Please fill in all fields before submitting the violation.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;
//     const double titleFontSize = 14.0;
//     const double numberFontSize = 20.0;
//     const Color titleColor = Color.fromARGB(255, 14, 39, 2);
//     const Color numberColor = Color(0xFF1B8354);
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const NavBarTop(),
//             _buildHeader(),
//             ...violationsList.map((violation) {
//               return Container(
//                 height: h * .6,
//                 width: w * .9,
//                 padding: const EdgeInsets.all(15.0),
//                 margin: const EdgeInsets.symmetric(vertical: 10.0),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(
//                       color: Colors.grey[300]!,
//                     )),
//                 child: Column(
//                   children: [
//                     Align(
//                       alignment: Alignment.topRight,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           SizedBox(
//                             height: h * .15,
//                             width: w * .3,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 _buildTextStyle(
//                                   text:
//                                       '${violation['violationNumber']}  : تفاصيل رفع المخالفة رقم ',
//                                   fontSize: titleFontSize,
//                                   fontWeight: FontWeight.bold,
//                                   color: titleColor,
//                                 ),
//                                 const SizedBox(height: 5.0),
//                                 const Text(
//                                   'لرفع المخالفة يجب عليك تعبئة حقول \nالبيانات المطلوبة',
//                                   textAlign: TextAlign.right,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: h * .3,
//                       width: w * .9,
//                       child: Row(
//                         children: [
//                           Expanded(
//                               child: Column(
//                             children: [
//                               if (violation['imageUrl'] != null)
//                                 Container(
//                                   width: 150,
//                                   height: 150,
//                                   margin: const EdgeInsets.only(right: 20.0),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12.0),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.2),
//                                         spreadRadius: 2,
//                                         blurRadius: 4,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(12.0),
//                                     child: Image.network(
//                                       violation['imageUrl'],
//                                       fit: BoxFit.cover,
//                                       loadingBuilder: (BuildContext context,
//                                           Widget child,
//                                           ImageChunkEvent? loadingProgress) {
//                                         if (loadingProgress == null) {
//                                           return child;
//                                         }
//                                         return Center(
//                                           child: CircularProgressIndicator(
//                                             value: loadingProgress
//                                                         .expectedTotalBytes !=
//                                                     null
//                                                 ? loadingProgress
//                                                         .cumulativeBytesLoaded /
//                                                     (loadingProgress
//                                                             .expectedTotalBytes ??
//                                                         1)
//                                                 : null,
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder: (BuildContext context,
//                                           Object error,
//                                           StackTrace? stackTrace) {
//                                         return const Center(
//                                             child: Text('خطأ في تحميل الصورة'));
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           )),
//                           Expanded(
//                               flex: 3,
//                               child: _buildViolationForm(
//                                   violationsList.first['violationNumber'])),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             })
//           ],
//         ),
//       ),
//       bottomNavigationBar: const NavBarBottom(),
//     );
//   }

//   Widget _buildHeader() {
//     return const Align(
//       alignment: Alignment.centerRight,
//       child: Padding(
//         padding: EdgeInsets.all(35.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 10),
//             Text(
//               'راصد لرصد المخالفات المرورية',
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'خدمة رفع المخالفات وتحقق',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.right,
//             ),
//             SizedBox(height: 10),
//             Text(
//               'من هنا يمكنك رفع المخالفات وتحقق قبل رفعها',
//               style: TextStyle(fontSize: 16, color: Colors.black),
//               textAlign: TextAlign.right,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextStyle({
//     required String text,
//     double fontSize = 12.0,
//     FontWeight fontWeight = FontWeight.normal,
//     Color color = Colors.black,
//   }) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: fontSize,
//         fontWeight: fontWeight,
//         color: color,
//       ),
//     );
//   }

//   Widget _buildViolationForm(int violationNumber) {
//     final formKey = GlobalKey<FormState>();
//     String? phoneNumber,
//         carNumber,
//         violationDate,
//         violationMessage,
//         violationDetails;

//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildTextField(
//             label: 'تفاصيل المخالفة',
//             hintText: 'أدخل تفاصيل المخالفة هنا',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'يرجى إدخال تفاصيل المخالفة';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               violationDetails = value;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم الهاتف',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال رقم الهاتف';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     phoneNumber = value;
//                   },
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'رقم السيارة',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال رقم السيارة';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     carNumber = value;
//                   },
//                 ),
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: _buildTextField(
//                   label: 'تاريخ المخالفة',
//                   hintText: 'YYYY-MM-DD',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال تاريخ المخالفة';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     violationDate = value;
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10.0),
//           _buildTextField(
//             label: 'رسالة المخالفة',
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'يرجى إدخال رسالة المخالفة';
//               }
//               return null;
//             },
//             onChanged: (value) {
//               violationMessage = value;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 try {
//                   final url =
//                       Uri.parse('https://freeemailapi.vercel.app/sendEmail/');
//                   final response = await http.post(url,
//                       headers: {
//                         'Content-Type': 'application/json; charset=UTF-8'
//                       },
//                       body: jsonEncode({
//                         "toEmail": "alharbi55555b@gmail.com",
//                         "title": "RAASID",
//                         "subject": "$violationNumber",
//                         // "body": "تم رصد مخالفة الرجاء مطابقتها و رفعها",
//                         "body": "A ticket has been issued for you",
//                       }));

//                   if (response.statusCode == 200) {
//                     final responseData = jsonDecode(response.body);
//                     if (responseData['message'] == 'emailSendSuccess') {
//                       print('Email sent successfully: $responseData');
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content:
//                               const Text('تم إرسال البريد الإلكتروني بنجاح'),
//                           action: SnackBarAction(
//                               label: 'موافق',
//                               onPressed: () {
//                                 // Perform some action if needed
//                               })));
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                           content: Text('Fail: $responseData'),
//                           action: SnackBarAction(
//                               label: 'موافق',
//                               onPressed: () {
//                                 // Perform some action if needed
//                               })));
//                       print('Email sending failed: $responseData');
//                     }
//                   } else {
//                     print('Request failed with status: ${response.statusCode}');
//                     print('Response body: ${response.body}');
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text('Fail: ${response.body}'),
//                         action: SnackBarAction(
//                             label: 'موافق',
//                             onPressed: () {
//                               // Perform some action if needed
//                             })));
//                   }
//                 } catch (e, st) {
//                   print("💥 error is $e, stack trace: $st");
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text('Fail: $e'),
//                       action: SnackBarAction(
//                           label: 'موافق',
//                           onPressed: () {
//                             // Perform some action if needed
//                           })));
//                 }
//                 _sendViolation(
//                   violationNumber,
//                   phoneNumber,
//                   carNumber,
//                   violationDate,
//                   violationMessage,
//                   violationDetails,
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1B8354),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//             ),
//             child: const Text(
//               'إرسال المخالفة',
//               style: TextStyle(fontSize: 16.0),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     String? hintText,
//     required String? Function(String?) validator,
//     required ValueChanged<String> onChanged,
//   }) {
//     return TextFormField(
//       textAlign: TextAlign.right,
//       textDirection: TextDirection.rtl,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hintText,
//         hintStyle: const TextStyle(
//             color: Color.fromARGB(255, 145, 150, 148)), // لون النص في hintText
//         border: const OutlineInputBorder(),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xFF1B8354)),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide:
//               BorderSide(color: Color(0xFFD2D6DB)), // لون الحافة العادية
//         ),
//       ),
//       validator: validator,
//       onChanged: onChanged,
//     );
//   }
// }
