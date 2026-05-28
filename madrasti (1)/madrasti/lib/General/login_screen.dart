import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madrasati/General/app_localizations.dart';
import 'package:madrasati/General/language_provider.dart';
import 'package:madrasati/Student/student_screen.dart';
import 'package:madrasati/Teacher/teacher_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Admin/admin_screen.dart';
import '../General/app_colors.dart';
import '../api.dart';

class LoginScreen extends StatefulWidget {

  final String role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController nationalIdController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isLoading = false;

  // =========================================
  // LOGIN
  // =========================================

  Future<void> login() async {

    String nationalId =
    nationalIdController.text.trim();

    String password =
    passwordController.text.trim();

    if (nationalId.isEmpty ||
        password.isEmpty) {

      showError(
        "Please enter all fields",
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(Api.login),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "national_id": nationalId,
          "password": password,

        }),

      );

      final data =
      jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      print(data);

      // =====================================
      // LOGIN SUCCESS
      // =====================================

      if (response.statusCode == 200 &&
          data["success"] == true) {

        // =================================
        // CHECK ROLE
        // =================================

        if (data["user"]["role"] !=
            widget.role) {

          showError(
            "Wrong role selected",
          );

          return;
        }

        // =================================
        // SAVE USER DATA
        // =================================


final prefs = await SharedPreferences.getInstance();

await prefs.setString("token", data["token"]?.toString() ?? "");
await prefs.setString("user_id", data["user"]["id"]?.toString() ?? "");
await prefs.setString("profile_id", data["profile_id"]?.toString() ?? "");
await prefs.setString("role", data["user"]["role"]?.toString() ?? "");
await prefs.setString("full_name", data["user"]["full_name"]?.toString() ?? "");
await prefs.setString("national_id", data["user"]["national_id"]?.toString() ?? "");
await prefs.setString("school_id", data["user"]["school_id"]?.toString() ?? "");
        // =================================
        // OPEN STUDENT
        // =================================

        if (widget.role == "student") {

          Navigator.pushAndRemoveUntil(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  StudentScreen(
                    name:
                    data["user"]["full_name"],
                  ),
            ),

                (route) => false,

          );

        }

        // =================================
        // OPEN TEACHER
        // =================================

        else if (widget.role == "teacher") {

          Navigator.pushAndRemoveUntil(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  TeacherScreen(
                    name:
                    data["user"]["full_name"],
                  ),
            ),

                (route) => false,

          );

        }

        // =================================
        // OPEN ADMIN
        // =================================

        else if (widget.role == "admin") {

          Navigator.pushAndRemoveUntil(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  AdminScreen(
                    name:
                    data["user"]["full_name"],
                  ),
            ),

                (route) => false,

          );

        }

      }

      // =====================================
      // LOGIN FAILED
      // =====================================

      else {

        showError(
          data["message"] ??
              "Login failed",
        );

      }

    }

    catch (error) {

      setState(() {
        isLoading = false;
      });

      showError(error.toString());

    }

  }

  // =========================================
  // RESET PASSWORD
  // =========================================

  Future<void> resetPassword() async {

    String nationalId =
    nationalIdController.text.trim();

    if (nationalId.isEmpty) {

      showError(
        "Enter national ID first",
      );

      return;
    }

    showDialog(

      context: context,

      builder: (context) {

        final TextEditingController
        newPasswordController =
        TextEditingController();

        return AlertDialog(

          title: const Text(
            "Reset Password",
          ),

          content: TextField(

            controller:
            newPasswordController,

            obscureText: true,

            decoration:
            const InputDecoration(
              hintText:
              "Enter new password",
            ),

          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),

            ),

            ElevatedButton(

              onPressed: () async {

                try {

                  final response =
                  await http.post(

                    Uri.parse(
                      Api.resetPassword,
                    ),

                    headers: {
                      "Content-Type":
                      "application/json",
                    },

                    body: jsonEncode({

                      "national_id":
                      nationalId,

                      "new_password":
                      newPasswordController
                          .text
                          .trim(),

                    }),

                  );

                  final data =
                  jsonDecode(
                    response.body,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    SnackBar(
                      content: Text(
                        data["message"],
                      ),
                    ),

                  );

                }

                catch (error) {

                  Navigator.pop(context);

                  showError(
                    error.toString(),
                  );

                }

              },

              child: const Text("Save"),

            ),

          ],

        );

      },

    );

  }

  // =========================================
  // SHOW ERROR
  // =========================================

  void showError(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(msg),
      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      resizeToAvoidBottomInset: true,

      body: SafeArea(

        child: SingleChildScrollView(

          child: Column(

            children: [

              // =====================================
              // HEADER
              // =====================================

              Container(

                width: double.infinity,

                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 50,
                ),

                decoration: const BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: Column(

                  children: [

                    Align(

                      alignment: Alignment.topRight,

                      child: Padding(

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),

                        child: TextButton.icon(

                          onPressed: () {

                            var provider =
                            Provider.of<
                                LanguageProvider>(
                              context,
                              listen: false,
                            );

                            if (Localizations
                                .localeOf(context)
                                .languageCode ==
                                'ar') {

                              provider.changeLanguage(
                                const Locale('en'),
                              );

                            }

                            else {

                              provider.changeLanguage(
                                const Locale('ar'),
                              );

                            }

                          },

                          icon: const Icon(
                            Icons.language,
                            color: Colors.white,
                            size: 20,
                          ),

                          label: Text(

                            Localizations
                                .localeOf(context)
                                .languageCode ==
                                'ar'
                                ? "English"
                                : "عربي",

                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),

                          ),

                        ),

                      ),

                    ),

                    const Icon(
                      Icons.school,
                      size: 70,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 10),

                    Text(

                      widget.role.toUpperCase(),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(height: 30),

              Padding(

                padding: const EdgeInsets.all(20),

                child: Card(

                  elevation: 6,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Padding(

                    padding:
                    const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        Text(

                          AppLocalizations.of(context)!
                              .translate('login'),

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                            color: AppColors.primary,
                          ),

                        ),

                        const SizedBox(height: 20),

                        TextField(

                          controller:
                          nationalIdController,

                          keyboardType:
                          TextInputType.number,

                          decoration:
                          InputDecoration(

                            labelText:
                            AppLocalizations
                                .of(context)!
                                .translate(
                              'national_id',
                            ),

                            prefixIcon:
                            const Icon(Icons.badge),

                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                          ),

                        ),

                        const SizedBox(height: 15),

                        TextField(

                          controller:
                          passwordController,

                          obscureText: true,

                          decoration:
                          InputDecoration(

                            labelText:
                            AppLocalizations
                                .of(context)!
                                .translate(
                              'password',
                            ),

                            prefixIcon:
                            const Icon(Icons.lock),

                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                          ),

                        ),

                        Align(

                          alignment:
                          Alignment.centerRight,

                          child: TextButton(

                            onPressed:
                            resetPassword,

                            child: Text(

                              AppLocalizations
                                  .of(context)!
                                  .translate(
                                'Forgot Password',
                              ),

                              style: TextStyle(
                                color:
                                AppColors.primary,
                                fontWeight:
                                FontWeight.bold,
                              ),

                            ),

                          ),

                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            AppColors.primary,

                            foregroundColor:
                            Colors.white,

                            minimumSize:
                            const Size(
                              double.infinity,
                              50,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),

                          ),

                          onPressed:
                          isLoading
                              ? null
                              : login,

                          child:
                          isLoading
                              ? const CircularProgressIndicator(
                            color:
                            Colors.white,
                          )
                              : Text(
                            AppLocalizations
                                .of(context)!
                                .translate(
                              'login_button',
                            ),
                          ),

                        ),

                      ],

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