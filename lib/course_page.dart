// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:ufuture_attendance/login_page.dart';

import 'package:ufuture_attendance/main.dart';
import 'package:ufuture_attendance/backend.dart';
import 'package:ufuture_attendance/CourseAttendances.dart';
import 'package:ufuture_attendance/Attendance.dart';
import 'dialog.dart';
import 'main_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String title;
  CourseAttendances courseAttendance;

  int totalAttended = 0;
  int totalAbscent = 0;

  bool isLoading = true;
  bool hasError = false;

  refreshPage() {
    setState(() {
      isLoading = true;
    });
    fetchAttendancesByCourse(widget.title).then((value) {
      setState(() {
        isLoading = false;
        courseAttendance = value;
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
    title = widget.title;

    refreshPage();
    // isLoading = gIsLoading;

    // if (gIsLoading) {
    //   fetchAttendancesAllCourses(gListCourse).then((value) {
    //     gIsLoading = false;
    //     setState(() {
    //       isLoading = false;
    //       courseAttendance = value[
    //           value.indexWhere((element) => element.title == widget.title)];
    //     });
    //   });
    // } else {
    //   fetchAttendancesAllCourses(listCourse).then((value) {
    //     setState(() {
    //       courseAttendance = value[
    //           value.indexWhere((element) => element.title == widget.title)];
    //     });
    //   });
    // }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
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
          : (isLoading ? _buildLoadingPage() : _buildCourseDetails()),
    );
  }

  Widget _buildCourseDetails() {
    return Container(
      child: SingleChildScrollView(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 32),
                            ),
                            SizedBox(
                              height: courseAttendance != null
                                  ? (courseAttendance.attendances.isNotEmpty
                                      ? 20
                                      : 0)
                                  : 0,
                            ),
                            if (courseAttendance != null
                                ? courseAttendance.attendances.isNotEmpty
                                : false)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xFF65E97B),
                                          borderRadius:
                                              BorderRadius.circular(18)),
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
                                                  (courseAttendance.attendances
                                                                  .map((element) =>
                                                                      element.status ==
                                                                              AttendanceStatus
                                                                                  .ATTENDED
                                                                          ? 1
                                                                          : 0)
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      element)
                                                                  .toDouble() *
                                                              100 /
                                                              courseAttendance
                                                                  .attendances
                                                                  .map((element) =>
                                                                      (element.status == AttendanceStatus.ATTENDED || element.status == AttendanceStatus.ABSCENT)
                                                                          ? 1
                                                                          : 0)
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      element)
                                                                  .toDouble())
                                                          .toStringAsFixed(1) +
                                                      "%",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  "(" +
                                                      courseAttendance
                                                          .attendances
                                                          .map((element) => element
                                                                      .status ==
                                                                  AttendanceStatus
                                                                      .ATTENDED
                                                              ? 1
                                                              : 0)
                                                          .reduce((value,
                                                                  element) =>
                                                              value + element)
                                                          .toString() +
                                                      ")",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                          borderRadius:
                                              BorderRadius.circular(18)),
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
                                                  (courseAttendance.attendances
                                                                  .map((element) =>
                                                                      element.status ==
                                                                              AttendanceStatus
                                                                                  .ABSCENT
                                                                          ? 1
                                                                          : 0)
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      element)
                                                                  .toDouble() *
                                                              100 /
                                                              courseAttendance
                                                                  .attendances
                                                                  .map((element) =>
                                                                      (element.status == AttendanceStatus.ATTENDED || element.status == AttendanceStatus.ABSCENT)
                                                                          ? 1
                                                                          : 0)
                                                                  .reduce((value,
                                                                          element) =>
                                                                      value +
                                                                      element)
                                                                  .toDouble())
                                                          .toStringAsFixed(1) +
                                                      "%",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  "(" +
                                                      courseAttendance
                                                          .attendances
                                                          .map((element) => element
                                                                      .status ==
                                                                  AttendanceStatus
                                                                      .ABSCENT
                                                              ? 1
                                                              : 0)
                                                          .reduce((value,
                                                                  element) =>
                                                              value + element)
                                                          .toString() +
                                                      ")",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
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
            SizedBox(height: 26),
            if (courseAttendance != null
                ? courseAttendance.attendances.isNotEmpty
                : false)
              _buildListAttandence(courseAttendance.attendances),
            if (courseAttendance != null
                ? courseAttendance.attendances.isEmpty
                : false)
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
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18.0, horizontal: 24.0),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color(0xFFC4CC7C),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Container(
                                    child: Text(
                                  "There is no class.",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF000000)),
                                )),
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
      ),
    );
  }

  Widget _buildListAttandence(List<Attendance> attendances) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (var attendance in attendances)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
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
                            vertical: 18.0, horizontal: 24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    attendance.title,
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xFF000000)),
                                  )),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                      child: Text(
                                    attendance.date +
                                        ' (' +
                                        attendance.timeStart +
                                        ' ~ ' +
                                        attendance.timeEnd +
                                        ') ',
                                    style: TextStyle(
                                        fontSize: 10, color: Color(0xFF737373)),
                                  )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            _buildButton(attendance.status, () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return WillPopScope(
                                    child: buildLoadingDialog(),
                                    onWillPop: () => Future.value(false),
                                  );
                                },
                              );
                              attend(attendance.link, attendance.postData)
                                  .then((value) {
                                Navigator.of(context).pop();
                                refreshPage();
                              });
                            })
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildButton(AttendanceStatus status, Function onPressed) {
    if (status == AttendanceStatus.ATTENDED) {
      return Container(
        width: 87,
        decoration: BoxDecoration(
          color: Color(0xFF72EF87).withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              "Attended",
              style: TextStyle(fontSize: 12, color: Color(0xFF4CAA5C)),
            ),
          ),
        ),
      );
    } else if (status == AttendanceStatus.ABSCENT) {
      return Container(
        width: 87,
        decoration: BoxDecoration(
          color: Color(0xFFF97474).withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              "Abscent",
              style: TextStyle(fontSize: 12, color: Color(0xFFCE5F5F)),
            ),
          ),
        ),
      );
    } else if (status == AttendanceStatus.COMING_SOON) {
      return Container(
        width: 87,
        decoration: BoxDecoration(
          color: Color(0xFFBCBCBC),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              "Soon",
              style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      );
    } else if (status == AttendanceStatus.AVAILABLE) {
      return Container(
        width: 87,
        decoration: BoxDecoration(
          color: Color(0xFFD1DC67),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Material(
          color: Color(0xFFD1DC67),
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  "Attend",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
          ),
        ),
      );
    }
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
          setState(() {
            hasError = false;
            refreshPage();
          });
        },
        child: Text('Refresh'),
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
