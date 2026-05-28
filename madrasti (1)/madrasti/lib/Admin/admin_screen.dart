import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../General/user_type_screen.dart';
import 'admin_students_screen.dart';
import 'admin_teachers_screen.dart';
import 'admin_sections_screen.dart';
import 'admin_activities_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_grades_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_class_schedule_screen.dart';
import 'admin_discipline_screen.dart';

class AdminScreen extends StatelessWidget {

  final String name;

  const AdminScreen({

    super.key,

    required this.name,

  });

  // =====================================
  // LOGOUT
  // =====================================

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // مسح بيانات الأدمين

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const UserTypeScreen()),
    (route) => false, 
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      // =================================
      // DRAWER
      // =================================

      drawer: Drawer(

        child: ListView(

          padding: EdgeInsets.zero,

          children: [

            const DrawerHeader(

              decoration: BoxDecoration(

                gradient:
                AppColors.gradient,

              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Icon(

                    Icons.admin_panel_settings,

                    color: Colors.white,

                    size: 42,

                  ),

                  SizedBox(
                    height: 12,
                  ),

                  Text(

                    "Admin Panel",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ],

              ),

            ),

            // =========================
            // SETTINGS
            // =========================

            ListTile(

              leading: const Icon(

                Icons.settings_outlined,

                color:
                AppColors.primary,

              ),

              title: const Text(
                "Settings",
              ),

              onTap: () {

                Navigator.pop(context);

              },

            ),

            // =========================
            // LOGOUT
            // =========================

            ListTile(

              leading: const Icon(

                Icons.logout_rounded,

                color: Colors.redAccent,

              ),

              title: const Text(
                "Log out",
              ),

              onTap: () {

                logout(context);

              },

            ),

          ],

        ),

      ),

      // =================================
      // BODY
      // =================================

      body: SafeArea(

        child: Column(

          children: [

            // =========================
            // HEADER
            // =========================

            buildHeader(context),

            const SizedBox(
              height: 10,
            ),

            // =========================
            // GRID
            // =========================

            Expanded(

              child: GridView(

                padding:
                const EdgeInsets.all(16),

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 2,

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: 1.05,

                ),

                children: [

                  buildCard(

                    context,

                    Icons.people_rounded,

                    "Students",

                    const AdminStudentsScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.person_rounded,

                    "Teachers",

                    const AdminTeachersScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.grid_view_rounded,

                    "Sections",

                    const AdminSectionsScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.table_chart_rounded,

                    "Class Schedule",

                    const AdminClassScheduleScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.event_available_rounded,

                    "Activities Approval",

                    const AdminActivitiesScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.campaign_rounded,

                    "Notifications",

                    const AdminNotificationsScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.grade_rounded,

                    "Grades Review",

                    const AdminGradesScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.fact_check_rounded,

                    "Attendance",

                    const AdminAttendanceScreen(),

                  ),

                  buildCard(

                    context,

                    Icons.gavel_rounded,

                    "Warnings & Penalties",

                    const AdminPenaltiesScreen(),

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

  // =====================================
  // HEADER
  // =====================================

  Widget buildHeader(
      BuildContext context,
      ) {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        25,
      ),

      decoration: const BoxDecoration(

        gradient:
        AppColors.gradient,

        borderRadius:
        BorderRadius.only(

          bottomLeft:
          Radius.circular(25),

          bottomRight:
          Radius.circular(25),

        ),

      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          // =========================
          // TOP ROW
          // =========================

          Row(

            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              Builder(

                builder: (context) {

                  return IconButton(

                    icon: const Icon(

                      Icons.menu_rounded,

                      color: Colors.white,

                    ),

                    onPressed: () {

                      Scaffold.of(context)
                          .openDrawer();

                    },

                  );

                },

              ),

              const Icon(

                Icons.admin_panel_settings,

                color: Colors.white,

                size: 30,

              ),

            ],

          ),

          const SizedBox(
            height: 12,
          ),

          // =========================
          // WELCOME
          // =========================

          Text(

            "Welcome $name",

            style: const TextStyle(

              color: Colors.white,

              fontSize: 24,

              fontWeight:
              FontWeight.bold,

            ),

          ),

          const SizedBox(
            height: 4,
          ),

          const Text(

            "School Administration Dashboard",

            style: TextStyle(

              color: Colors.white70,

              fontSize: 14,

            ),

          ),

        ],

      ),

    );

  }

  // =====================================
  // CARD
  // =====================================

  Widget buildCard(

      BuildContext context,
      IconData icon,
      String title,
      Widget page,

      ) {

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

        elevation: 4,

        shadowColor:
        Colors.black26,

        shape:
        RoundedRectangleBorder(

          borderRadius:
          BorderRadius.circular(
            16,
          ),

        ),

        child: Padding(

          padding:
          const EdgeInsets.all(12),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Container(

                padding:
                const EdgeInsets.all(
                  14,
                ),

                decoration:
                BoxDecoration(

                  color:
                  AppColors.primary
                      .withOpacity(0.1),

                  shape:
                  BoxShape.circle,

                ),

                child: Icon(

                  icon,

                  size: 34,

                  color:
                  AppColors.primary,

                ),

              ),

              const SizedBox(
                height: 14,
              ),

              Text(

                title,

                textAlign:
                TextAlign.center,

                style:
                const TextStyle(

                  fontWeight:
                  FontWeight.bold,

                  fontSize: 14,

                  color:
                  Colors.black87,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}