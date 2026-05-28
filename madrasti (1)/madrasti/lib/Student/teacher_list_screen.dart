import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../General/app_colors.dart';
import '../api.dart';
import 'chat_screen.dart';

class TeacherListScreen extends StatefulWidget {

  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() =>
      _TeacherListScreenState();

}

class _TeacherListScreenState
    extends State<TeacherListScreen> {

  List teachers = [];

  bool isLoading = true;

  // =========================================
  // GET TEACHERS
  // =========================================

  Future<void> getTeachers() async {

    try {

      final response = await http.get(

        Uri.parse(
          Api.studentTeachers,
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          teachers = data["teachers"];

          isLoading = false;

        });

      }

      else {

        setState(() {
          isLoading = false;
        });

      }

    }

    catch (error) {

      setState(() {
        isLoading = false;
      });

      print(error);

    }

  }

  @override
  void initState() {

    super.initState();

    getTeachers();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Select Teacher",
        ),

        backgroundColor:
        AppColors.primary,

        foregroundColor:
        Colors.white,

      ),

      backgroundColor:
      AppColors.background,

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : teachers.isEmpty

          ? const Center(
        child: Text(
          "No Teachers Found",
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(12),

        itemCount:
        teachers.length,

        itemBuilder:
            (context, index) {

          final teacher =
          teachers[index];

          return Card(

            elevation: 3,

            margin:
            const EdgeInsets.symmetric(
              vertical: 8,
            ),

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: ListTile(

              leading: CircleAvatar(

                backgroundColor:
                AppColors.primary
                    .withOpacity(0.8),

                child: Text(

                  teacher["full_name"]
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),

                ),

              ),

              title: Text(

                teacher["full_name"] ?? "",

                style: const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),

              ),

              subtitle: Text(
                teacher["specialization"] ??
                    "",
              ),

              trailing: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.blue,
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) =>
                        ChatScreen(

                          teacherName:
                          teacher["full_name"],

                          teacherId:
                          teacher["id"],

                        ),

                  ),

                );

              },

            ),

          );

        },

      ),

    );

  }

}