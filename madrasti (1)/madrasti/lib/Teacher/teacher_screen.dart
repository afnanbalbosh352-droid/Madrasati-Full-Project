import 'package:flutter/material.dart';
import 'package:madrasati/Teacher/teacher_exam_schedule_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../General/user_type_screen.dart';
import 'activities_teacher_screen.dart';
import 'teacher_assignments_screen.dart';
import 'teacher_grades_screen.dart';
import 'teacher_schedule_screen.dart';
import 'teacher_assessment_screen.dart';
import 'notifications_screen.dart';

import 'attendance_screen.dart' as attendance;
import 'messages_screen.dart' as messages;

class TeacherScreen extends StatelessWidget {
  final String name;

  const TeacherScreen({
    super.key,
    required this.name,
  });

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const UserTypeScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(gradient: AppColors.gradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text("Madrasati", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text("Log out"),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(context),
            const SizedBox(height: 10),
            Expanded(
              child: GridView(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                children: [
                  buildCard(context, Icons.event_note_rounded, "Activities", const ActivitiesTeacherScreen()),
                  buildCard(context, Icons.how_to_reg_rounded, "Attendance", const attendance.AdminAttendanceScreen()),
                  buildCard(context, Icons.assignment_turned_in_rounded, "Assignments", const TeacherAssignmentsScreen()),
                  buildCard(context, Icons.insights_rounded, "Grades", const TeacherGradesScreen()),
                  buildCard(context, Icons.calendar_today_rounded, "Class Schedule", const TeacherScheduleScreen()),
                  buildCard(context, Icons.assessment_outlined, "Assessment", const TeacherAssessmentScreen()),
                  buildCard(context, Icons.message_rounded, "Messages", messages.MessagesScreen(name: name)),
                  buildCard(context, Icons.campaign_rounded, "Notifications", const NotificationScreen(isViewOnly: false)),
                  buildCard(context, Icons.edit_calendar_rounded, "Exam Schedule", const TeacherExamScheduleScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 25),
      decoration: const BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              }),
              // تم التعديل هنا: أيقونة الجرس للعرض فقط
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(isViewOnly: true),
                    ),
                  );
                },
                child: const Stack(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: Colors.white, size: 28),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text("Welcome Teacher $name", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Madrasati School", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildCard(BuildContext context, IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}