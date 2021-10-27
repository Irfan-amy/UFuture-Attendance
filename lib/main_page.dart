import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:ufuture_attendance/backend.dart';
import 'package:ufuture_attendance/login_page.dart';
import 'package:ufuture_attendance/CourseAttendances.dart';
import 'package:ufuture_attendance/Attendance.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie_chart/pie_chart.dart';
import 'course_page.dart';
import 'dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _counter = "";
  int index = -1;

  bool isLoading = true;
  bool hasError = false;
  List<CourseAttendances> coursesAttendances = [];

  incrementCounter() async {}

  refreshPage() {
    setState(() {
      hasError = false;
      isLoading = true;
    });
    fetchAttendancesAllCourses(gListCourse).then((value) {
      setState(() {
        isLoading = false;
        coursesAttendances = value;
      });
    }, onError: (error) {
      setState(() {
        hasError = true;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return buildErrorDialog(context, error.toString());
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    refreshPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF232323),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFFFFFFF),
        ),
        title: Text(
          "UFUTURE ATTENDANCE",
          style:
              TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFC4CC7C)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () async {
              // fetchListCourse().then((value) {
              //   setState(() {
              //     listCourse = value;
              //   });
              // });
              refreshPage();
            },
          )
        ],
      ),
      drawer: Drawer(
        elevation: 0,
        child: Material(
          color: Color(0xFF232323),
          child: ListView(
            children: [
              SizedBox(
                height: 18,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Summary",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          MainPage(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              Divider(
                height: 26,
                color: Colors.white.withOpacity(0.2),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Course",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              for (int i = 0; i < gListCourse.length; i++)
                ListTile(
                  title: Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Icon(Icons.group, color: Colors.white),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          gListCourse[i],
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            CoursePage(title: gListCourse[i]),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
              Divider(
                height: 26,
                color: Colors.white.withOpacity(0.2),
              ),
              ListTile(
                title: Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  SharedPreferences.getInstance().then((value) {
                    value.setString('username', '');
                    value.setString('password', '');
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            LoginPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: hasError
          ? _buildTryAgainPage()
          : (isLoading ? _buildLoadingPage() : _buildSummaryPage()),
    );
  }

  Widget _buildSummaryPage() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 32,
          ),
          Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PieChart(
                            dataMap: {
                              "Attended": getTotalAttendanceAttended(),
                              "Abscent": getTotalAttendanceAbscent()
                            },
                            animationDuration: Duration(milliseconds: 800),
                            chartLegendSpacing: 32,
                            chartRadius: 250,
                            colorList: [Color(0xFF65E97B), Color(0xFFF97474)],
                            initialAngleInDegree: 0,
                            chartType: ChartType.disc,
                            ringStrokeWidth: 32,
                            legendOptions: LegendOptions(
                              showLegendsInRow: false,
                              legendPosition: LegendPosition.right,
                              showLegends: true,
                              legendTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            chartValuesOptions: ChartValuesOptions(
                              showChartValueBackground: true,
                              showChartValues: true,
                              showChartValuesInPercentage: true,
                              showChartValuesOutside: false,
                              decimalPlaces: 1,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFF65E97B),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline:
                                              TextBaseline.ideographic,
                                          children: [
                                            Text(
                                              (getTotalAttendanceAttended() *
                                                          100 /
                                                          getTotalAttendance())
                                                      .toStringAsFixed(1) +
                                                  "%",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              "(" +
                                                  getTotalAttendanceAttended()
                                                      .toInt()
                                                      .toString() +
                                                  ")",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Attended",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF97474),
                                      borderRadius: BorderRadius.circular(18)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline:
                                              TextBaseline.ideographic,
                                          children: [
                                            Text(
                                              (getTotalAttendanceAbscent() *
                                                          100 /
                                                          getTotalAttendance())
                                                      .toStringAsFixed(1) +
                                                  "%",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Text(
                                              "(" +
                                                  getTotalAttendanceAbscent()
                                                      .toInt()
                                                      .toString() +
                                                  ")",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Abscent",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTryAgainPage() {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.white,
          backgroundColor: Color(0xFFC4CC7C),
          minimumSize: Size(108, 36),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
        onPressed: () {
          refreshPage();
        },
        child: Text('Try Again'),
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  double getTotalAttendance() {
    return coursesAttendances.isNotEmpty
        ? coursesAttendances
            .map((element) => element.attendances.isNotEmpty
                ? element.attendances
                    .map((e) => (e.status == AttendanceStatus.ATTENDED ||
                            e.status == AttendanceStatus.ABSCENT)
                        ? 1
                        : 0)
                    .reduce((value, element) => value + element)
                : 0)
            .reduce((value, element) => value + element ?? 0)
            .toDouble()
        : 0;
  }

  double getTotalAttendanceAttended() {
    return coursesAttendances.isNotEmpty
        ? coursesAttendances
            .map((element) => element.attendances.isNotEmpty
                ? element.attendances
                    .map((e) => (e.status == AttendanceStatus.ATTENDED) ? 1 : 0)
                    .reduce((value, element) => value + element)
                : 0)
            .reduce((value, element) => value + element ?? 0)
            .toDouble()
        : 0;
  }

  double getTotalAttendanceAbscent() {
    return coursesAttendances.isNotEmpty
        ? coursesAttendances
            .map((element) => element.attendances.isNotEmpty
                ? element.attendances
                    .map((e) => (e.status == AttendanceStatus.ABSCENT) ? 1 : 0)
                    .reduce((value, element) => value + element)
                : 0)
            .reduce((value, element) => value + element ?? 0)
            .toDouble()
        : 0;
  }
}
