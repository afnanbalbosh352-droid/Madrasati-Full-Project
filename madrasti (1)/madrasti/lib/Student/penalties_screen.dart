import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../General/app_colors.dart';
import '../api.dart';

class PenaltiesScreen extends StatefulWidget {

  const PenaltiesScreen({super.key});

  @override
  State<PenaltiesScreen> createState() =>
      _PenaltiesScreenState();

}

class _PenaltiesScreenState
    extends State<PenaltiesScreen> {

  List warnings = [];

  bool isLoading = true;

  // =========================================
  // GET WARNINGS
  // =========================================

  Future<void> getWarnings() async {

    try {

      final prefs =
      await SharedPreferences.getInstance();

      final studentId =
      prefs.getString("profile_id");

      final response = await http.get(

        Uri.parse(
          "${Api.studentWarnings}/$studentId",
        ),

        headers: {
          "Content-Type": "application/json",
        },

      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        setState(() {

          warnings =
          data["warnings"];

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

    getWarnings();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        title: const Text(
          "Warnings & Penalties",
          style: TextStyle(
            color: Colors.white,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.gradient,
          ),
        ),

        iconTheme:
        const IconThemeData(
          color: Colors.white,
        ),

      ),

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : warnings.isEmpty

          ? const Center(
        child: Text(
          "No Warnings Found",
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(16),

        itemCount:
        warnings.length,

        itemBuilder:
            (context, index) {

          final warning =
          warnings[index];

          return buildPenaltyCard(
            warning,
          );

        },

      ),

    );

  }

  // =========================================
  // WARNING CARD
  // =========================================

  Widget buildPenaltyCard(
      Map<String, dynamic> warning,
      ) {

    final warningType =
        warning["warning_type"] ?? "";

    final actionTaken =
        warning["action_taken"] ?? "";

    final isSerious =
    warningType
        .toString()
        .toLowerCase()
        .contains("serious");

    return Card(

      elevation: 4,

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),

      child: Container(

        decoration: BoxDecoration(

          border: Border(

            left: BorderSide(

              color:
              isSerious
                  ? Colors.red
                  : Colors.orange,

              width: 6,

            ),

          ),

        ),

        padding:
        const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =============================
            // HEADER
            // =============================

            Row(

              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: [

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Text(

                        warningType,

                        style: const TextStyle(

                          fontSize: 17,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                ),

                Icon(

                  Icons.warning_amber_rounded,

                  color:
                  isSerious
                      ? Colors.red
                      : Colors.orange,

                  size: 30,

                ),

              ],

            ),

            const Divider(height: 20),

            // =============================
            // DATE
            // =============================

            Text(

              "Date: ${warning["warning_date"].toString().substring(0, 10)}",

              style: const TextStyle(

                color: Colors.blueGrey,

                fontSize: 13,

                fontWeight:
                FontWeight.w500,

              ),

            ),

            const SizedBox(height: 12),

            // =============================
            // REASON
            // =============================

            const Text(

              "Reason:",

              style: TextStyle(

                fontWeight:
                FontWeight.bold,

                fontSize: 14,

              ),

            ),

            const SizedBox(height: 5),

            Text(

              warning["reason"] ?? "",

              style: const TextStyle(

                color: Colors.black87,

                fontSize: 14,

              ),

            ),

            const SizedBox(height: 15),

            // =============================
            // ACTION
            // =============================

            Row(

              children: [

                const Text(

                  "Action: ",

                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),

                ),

                Container(

                  padding:
                  const EdgeInsets.symmetric(

                    horizontal: 10,
                    vertical: 4,

                  ),

                  decoration: BoxDecoration(

                    color:
                    isSerious

                        ? Colors.red
                        .withOpacity(0.1)

                        : Colors.orange
                        .withOpacity(0.1),

                    borderRadius:
                    BorderRadius.circular(
                      8,
                    ),

                  ),

                  child: Text(

                    actionTaken,

                    style: TextStyle(

                      color:
                      isSerious
                          ? Colors.red
                          : Colors.orange,

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 12,

                    ),

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

}