import 'package:flutter/material.dart';

import '../General/app_colors.dart';
import 'login_screen.dart';

class UserTypeScreen extends StatelessWidget {

  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        title: const Text(
          "Select User Type",
        ),

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        elevation: 0,

      ),

      body: Padding(

        padding: const EdgeInsets.all(20.0),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Text(

              "Who are you?",

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),

            ),

            const SizedBox(height: 30),

            // =====================================
            // ADMIN
            // =====================================

            buildUserCard(

              context: context,

              title: "Admin",

              role: "admin",

              icon: Icons.admin_panel_settings,

              color: Colors.blue,

            ),

            const SizedBox(height: 15),

            // =====================================
            // TEACHER
            // =====================================

            buildUserCard(

              context: context,

              title: "Teacher",

              role: "teacher",

              icon: Icons.school,

              color: Colors.green,

            ),

            const SizedBox(height: 15),

            // =====================================
            // STUDENT
            // =====================================

            buildUserCard(

              context: context,

              title: "Student",

              role: "student",

              icon: Icons.person,

              color: Colors.orange,

            ),

          ],

        ),

      ),

    );

  }

  // =========================================
  // USER CARD
  // =========================================

  Widget buildUserCard({

    required BuildContext context,

    required String title,

    required String role,

    required IconData icon,

    required Color color,

  }) {

    return InkWell(

      borderRadius: BorderRadius.circular(15),

      onTap: () {

        // =====================================
        // OPEN LOGIN
        // =====================================

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context) => LoginScreen(
              role: role,
            ),

          ),

        );

      },

      child: Card(

        elevation: 4,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        child: Container(

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(

            borderRadius:
            BorderRadius.circular(15),

            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),

          ),

          child: Row(

            children: [

              CircleAvatar(

                backgroundColor:
                color.withOpacity(0.1),

                child: Icon(
                  icon,
                  color: color,
                ),

              ),

              const SizedBox(width: 20),

              Text(

                title,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

              ),

              const Spacer(),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),

            ],

          ),

        ),

      ),

    );

  }

}