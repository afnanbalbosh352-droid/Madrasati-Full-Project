import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';
import '../General/user_type_screen.dart';
import 'activities_screen.dart';
import 'notifications_screen.dart';
import 'schedule_exam_screen.dart';
import 'assignments_screen.dart';
import 'schedule_class_screen.dart';
import 'grades_screen.dart';
import 'monthly_assessment_screen.dart';
import 'teacher_list_screen.dart';
import 'attendance_screen.dart';
import 'penalties_screen.dart';

class StudentScreen extends StatefulWidget {

  final String name;

  const StudentScreen({
    super.key,
    required this.name,
  });

  @override
  State<StudentScreen> createState() =>
      _StudentScreenState();

}

class _StudentScreenState
    extends State<StudentScreen> {

  String schoolName = "";

  String fullName = "";

  String studentId = "";

  bool isLoading = true;

  int notificationsCount = 0;

  // =========================================
  // LOAD USER DATA
  // =========================================

  Future<void> loadData() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      schoolName =
          prefs.getString("school_name") ??
              "Madrasati School";

      fullName =
          prefs.getString("full_name") ??
              widget.name;

      studentId =
          prefs.getString("profile_id") ?? "";

      await getNotificationsCount();

      setState(() {
        isLoading = false;
      });

    }

    catch (error) {

      setState(() {
        isLoading = false;
      });

    }

  }

  // =========================================
  // GET NOTIFICATIONS COUNT
  // =========================================

  Future<void> getNotificationsCount() async {

    try {

      final response = await http.get(

        Uri.parse(
          "${Api.studentNotifications}/$studentId",
        ),

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        notificationsCount =
            data["notifications"].length;

      }

    }

    catch (error) {

      print(error);

    }

  }

  // =========================================
  // LOGOUT
  // =========================================

  Future<void> logout() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(
        builder: (context) =>
        const UserTypeScreen(
          
        ),
      ),

          (route) => false,

    );

  }

  @override
  void initState() {

    super.initState();

    loadData();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      drawer: Drawer(

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding: const EdgeInsets.only(
                top: 60,
                bottom: 30,
                left: 20,
              ),

              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 50,
                  ),

                  const SizedBox(height: 15),

                  Text(

                    schoolName,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),

                  ),

                  const SizedBox(height: 5),

                  Text(

                    fullName,

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),

                  ),

                ],

              ),

            ),

            // SETTINGS

            ListTile(

              leading: const Icon(
                Icons.settings_outlined,
                color: AppColors.primary,
              ),

              title: const Text("Settings"),

              onTap: () {

                Navigator.pop(context);

              },

            ),

            // LOGOUT

            ListTile(

              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),

              title: const Text("Log out"),

              onTap: logout,

            ),

          ],

        ),

      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : Column(

        children: [

          // =================================
          // HEADER
          // =================================

          Container(

            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              25,
            ),

            decoration: const BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),

            child: SafeArea(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      Builder(

                        builder: (context) =>
                            IconButton(

                              icon: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                              ),

                              onPressed: () {

                                Scaffold.of(context)
                                    .openDrawer();

                              },

                            ),

                      ),

                      buildNotificationIcon(),

                    ],

                  ),

                  const SizedBox(height: 10),

                  Text(

                    "Welcome $fullName",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),

                  ),

                  Text(

                    schoolName,

                    style: const TextStyle(
                      color: Colors.white70,
                    ),

                  ),

                ],

              ),

            ),

          ),

          const SizedBox(height: 10),

          // =================================
          // GRID
          // =================================

          Expanded(

            child: GridView.count(

              padding: const EdgeInsets.all(16),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.05,

              children: [

                buildCard(
                  icon: Icons.event_note_rounded,
                  title: "Activities",
                  page: const ActivitiesScreen(),
                ),

                buildCard(
                  icon: Icons.quiz_rounded,
                  title: "Exam Schedule",
                  page:  ScheduleExamScreen(),
                ),

                buildCard(
                  icon: Icons.assignment_rounded,
                  title: "Assignments",
                  page:  AssignmentsScreen(),
                ),

                buildCard(
                  icon: Icons.schedule_rounded,
                  title: "Class Schedule",
                  page:  ScheduleClassScreen(),
                ),

                buildCard(
                  icon: Icons.grade_rounded,
                  title: "Grades",
                  page:  GradesScreen(),
                ),

                buildCard(
                  icon: Icons.analytics_rounded,
                  title: "Assessment",
                  page:
                   MonthlyAssessmentScreen(),
                ),

                buildCard(
                  icon:
                  Icons.chat_bubble_outline_rounded,
                  title: "Teacher Chat",
                  page: const TeacherListScreen(),
                ),

                buildCard(
                  icon:
                  Icons.calendar_today_rounded,
                  title: "Attendance",
                  page: const AttendanceScreen(),
                ),

                buildCard(
                  icon:
                  Icons.report_problem_rounded,
                  title: "Warnings &\nPenalties",
                  page: const PenaltiesScreen(),
                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  // =========================================
  // NOTIFICATION ICON
  // =========================================

  Widget buildNotificationIcon() {

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
            const NotificationsScreen(),
          ),

        );

      },

      child: Stack(

        alignment: Alignment.center,

        children: [

          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),

          if (notificationsCount > 0)

            Positioned(

              right: 2,
              top: 2,

              child: Container(

                padding: const EdgeInsets.all(5),

                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),

                child: Text(

                  notificationsCount.toString(),

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),

                ),

              ),

            ),

        ],

      ),

    );

  }

  // =========================================
  // CARD
  // =========================================

  Widget buildCard({

    required IconData icon,

    required String title,

    required Widget page,

  }) {

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) => page,
          ),

        );

      },

      child: Card(

        elevation: 3,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color:
                AppColors.primary.withOpacity(
                  0.08,
                ),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                size: 34,
                color: AppColors.primary,
              ),

            ),

            const SizedBox(height: 12),

            Text(

              title,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),

            ),

          ],

        ),

      ),

    );

  }

}