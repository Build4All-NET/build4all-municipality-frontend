// reset_password_page.dart

import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "استعادة كلمة المرور",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              const Text(
                "أدخل بريدك الإلكتروني وسنرسل لك رابط لاستعادة كلمة المرور",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              const TextField(
                decoration: InputDecoration(
                  hintText: "staff@municipality.gov.lb",
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {},
                child: const Text("إرسال رابط الاستعادة"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}