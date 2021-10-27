// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:ufuture_attendance/backend.dart';
import 'package:ufuture_attendance/CourseAttendances.dart';
import 'package:ufuture_attendance/Attendance.dart';

import 'course_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ufuture_attendance/main.dart';

import 'dialog.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _counter = "";
  int index = -1;

  String username;
  String password;

  bool isKeepMeSignedIn = false;

  List<String> listCourse = [];

  SharedPreferences prefs;

  bool isLoading = true;
  bool hasError = false;

  loginAndFetch() async {
    if (username != "" && password != "") {
      login(username, password).then((isSuccess) {
        if (isSuccess) {
          if (isKeepMeSignedIn) {
            prefs.setString('username', username);
            prefs.setString('password', password);
          }
          fetchListCourse().then((value) {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => MainPage(),
                transitionDuration: Duration.zero,
              ),
            );
          }, onError: (error) {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return buildErrorDialog2(context, error.toString(), () {
                  Navigator.of(context).pop();
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
                  loginAndFetch();
                });
              },
            );
          });
        } else {
          Navigator.of(context).pop();
          prefs.setString('username', '');
          prefs.setString('password', '');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return buildErrorDialog(
                  context, 'Invalid StudentID or Password!');
            },
          );
        }
      }, onError: (error) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return buildErrorDialog2(context, error.toString(), () {
              Navigator.of(context).pop();
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
              loginAndFetch();
            });
          },
        );
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    //listCourse = [...gListCourse];
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      SharedPreferences.getInstance().then((value) {
        prefs = value;
        username = prefs.getString('username') ?? "";
        password = prefs.getString('password') ?? "";

        loginAndFetch();
      });
    });
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
          "LOGIN",
          style:
              TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFC4CC7C)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 36.0, horizontal: 18.0),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 42,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Text(
                            'UFUTURE',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 42,
                              color: Color(0xFFC4CC7C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Text(
                            'ATTENDANCE',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 42,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 56,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Text(
                            'STUDENT ID',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Flexible(
                              fit: FlexFit.tight,
                              child: TextField(
                                onChanged: (value) {
                                  username = value;
                                },
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC4CC7C)),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Flexible(
                              fit: FlexFit.tight,
                              child: TextField(
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                onChanged: (value) {
                                  password = value;
                                },
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFC4CC7C)),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                      child: Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: isKeepMeSignedIn,
                            onChanged: (bool value) {
                              setState(() {
                                isKeepMeSignedIn = value;
                              });
                            },
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Keep me signed in",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
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
                                  onTap: () {
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
                                    loginAndFetch();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFFFFFFFF)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        onPressed: () {},
        child: Text('Try Again'),
      ),
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Color(0xFFC4CC7C);
    }
    return Color(0xFFC4CC7C);
  }
}
