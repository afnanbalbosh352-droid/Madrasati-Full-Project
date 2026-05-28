import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';
import 'user_type_screen.dart';

class SchoolSelectionScreen extends StatefulWidget {
  const SchoolSelectionScreen({super.key});

  @override
  State<SchoolSelectionScreen> createState() =>
      _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState
    extends State<SchoolSelectionScreen> {

  final TextEditingController _schoolController =
  TextEditingController();

  bool isLoading = false;

  // =========================================
  // VERIFY SCHOOL
  // =========================================

  Future<void> verifySchool() async {

    if (_schoolController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter school ID"),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(
        Uri.parse("${Api.baseUrl}/verify-school"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "school_code": _schoolController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      // =====================================
      // SUCCESS
      // =====================================

      if (response.statusCode == 200 &&
          data["success"] == true) {

        // حفظ المدرسة المختارة
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          "school_id",
          data["school"]["id"],
        );

        await prefs.setString(
          "school_name",
          data["school"]["school_name"],
        );

        await prefs.setString(
          "school_code",
          data["school"]["school_code"],
        );

        // الانتقال لاختيار نوع المستخدم
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserTypeScreen(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "School not found",
            ),
          ),
        );

      }

    } catch (error) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 80,
          ),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // =====================================
              // LOGO
              // =====================================

              Icon(
                Icons.school_outlined,
                size: 100,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                "Madrasati",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter your school ID to continue",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              // =====================================
              // SCHOOL ID FIELD
              // =====================================

              TextField(

                controller: _schoolController,

                keyboardType: TextInputType.text,

                decoration: InputDecoration(

                  labelText: "School ID",

                  hintText: "e.g. MAD001",

                  prefixIcon: Icon(
                    Icons.pin_outlined,
                    color: AppColors.primary,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),

                ),

              ),

              const SizedBox(height: 30),

              // =====================================
              // BUTTON
              // =====================================

              SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),

                  onPressed: isLoading
                      ? null
                      : verifySchool,

                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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