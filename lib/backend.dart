import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:ufuture_attendance/main.dart';
import 'package:ufuture_attendance/CourseAttendances.dart';
import 'package:ufuture_attendance/Attendance.dart';

List<String> gListCourse = [];

List<dynamic> gdata = [];

List<CourseAttendances> gCoursesAttendances = [];

bool gIsLoading = false;

NetworkService ns = NetworkService();

Future<bool> login(String studentId, String password) async {
  ns = NetworkService();
  ns.updateCookieWithKey('dtCookie',
      'v_4_srv_13_sn_850647F8D0956F721B29E8C0CB2E3789_perc_100000_ol_0_mul_1_app-3A186f32c692604778_1');
  try {
    var res_login = await ns.post("https://ufuture.uitm.edu.my/login", body: {
      "data[User][role]": "1",
      "data[User][username]": studentId,
      "data[User][password]": password,
    });

    print(res_login);

    var document = parse(res_login);

    return document.getElementById('uitmUserForm') == null;
  } catch (e) {
    return Future.error(e);
  }
}

Future<bool> attend(String link, String postData) async {
  try {
    print(link);
    print(postData);
    var res_attend = await ns.post(link,
        body: {"submit_type": "register", "data[attendance]": postData});

    print(res_attend);

    var document = parse(res_attend);
    if (document.getElementById('uitmUserForm') != null)
      return Future.error('Error occured. Please restart the app');
    return true;
  } catch (e) {
    return Future.error(e);
  }
}

Future<List<String>> fetchListCourse() async {
  ns.updateCookieWithKey('dtCookie',
      'v_4_srv_13_sn_850647F8D0956F721B29E8C0CB2E3789_perc_100000_ol_0_mul_1_app-3A186f32c692604778_1');
  try {
    var res_list_course =
        await ns.get('https://ufuture.uitm.edu.my/courses/list_course');
    var document = parse(res_list_course);

    if (document.getElementById('uitmUserForm') != null)
      return Future.error('Error occured. Please restart the app');

    print(document.getElementsByClassName('title')[0].text);

    List<String> listCourse = [];

    for (var course in document.getElementsByClassName('title')) {
      listCourse.add(course.text.trim().split('-')[0].trim());
    }
    gListCourse = [...listCourse];
    return listCourse;
  } catch (e) {
    return Future.error(e);
  }
}

Future<List<CourseAttendances>> fetchAttendancesAllCourses(
    List<String> courses) async {
  // var res_list_course =
  //     await ns.get('https://ufuture.uitm.edu.my/courses/list_course');
  // var document = parse(res_list_course);
  // print(document.getElementsByClassName('title')[0].text);

  // List<CourseAttendances> listCourse = [];

  // for (var course in document.getElementsByClassName('title')) {
  //   listCourse.add(course.text.trim().split('-')[0].trim());
  // }
  // gListCourse = [...listCourse];
  // return listCourse;

  try {
    List<CourseAttendances> coursesAttendances = [];
    for (int i = 0; i < courses.length; i++) {
      List<Attendance> attendances = [];
      String url =
          'https://ufuture.uitm.edu.my/OnlineClasses/index/' + courses[i];
      var res_list_attendance = await ns.get(url);
      var document = parse(res_list_attendance);

      if (document.getElementById('uitmUserForm') != null)
        return Future.error('Error occured. Please restart the app');

      var table = document.getElementById('onlineclassTbl');
      if (table != null) {
        if (table.getElementsByTagName('tbody').isNotEmpty) {
          var table_body = table.getElementsByTagName('tbody')[0];
          var rows = table_body.getElementsByTagName('tr');

          for (var row in rows) {
            var columns = row.getElementsByTagName('td');

            var title = columns[1].text;
            var date = columns[2].text;
            var timeStart = columns[3].text;
            var timeEnd = columns[4].text;
            var link = 'https://ufuture.uitm.edu.my' +
                columns[9].getElementsByTagName('a')[0].attributes['href'];
            AttendanceStatus statusAttendance = AttendanceStatus.NONE;
            String postData;

            var res_attendance = await ns.get(link);

            var doc_att = parse(res_attendance);

            var att_inner_table = doc_att.getElementById('listAttendance');
            var att_checkbox = doc_att.getElementById('hadir');
            if (att_checkbox != null) {
              if (att_checkbox.attributes['disabled'] != null) {
                postData = att_checkbox.attributes['value'];
                if (columns[10].text == 'Coming Soon') {
                  statusAttendance = AttendanceStatus.COMING_SOON;
                } else {
                  statusAttendance = AttendanceStatus.ABSCENT;
                }
              } else {
                statusAttendance = AttendanceStatus.AVAILABLE;
              }
            } else {
              if (att_inner_table
                      .getElementsByClassName('text-success')
                      .length >
                  0) {
                statusAttendance = AttendanceStatus.ATTENDED;
              } else if (att_inner_table
                      .getElementsByClassName('text-danger')
                      .length >
                  0) {
                statusAttendance = AttendanceStatus.ABSCENT;
              }
            }

            attendances.add(Attendance(
                title: title,
                timeStart: timeStart,
                timeEnd: timeEnd,
                date: date,
                link: link,
                status: statusAttendance,
                postData: postData));
          }
          coursesAttendances.add(
              CourseAttendances(title: courses[i], attendances: attendances));
        } else {
          coursesAttendances
              .add(CourseAttendances(title: courses[i], attendances: []));
        }
      } else {
        return Future.error("Can't find table for (" +
            courses[i] +
            "). Try reload or check if you need to fill SUFO or accept pledge for all subject.");
      }
    }
    gCoursesAttendances = [...coursesAttendances];
    return coursesAttendances;
  } catch (e) {
    return Future.error(e);
  }
}

Future<CourseAttendances> fetchAttendancesByCourse(String course) async {
  try {
    List<Attendance> attendances = [];
    String url = 'https://ufuture.uitm.edu.my/OnlineClasses/index/' + course;

    var res_list_attendance = await ns.get(url);
    var document = parse(res_list_attendance);

    if (document.getElementById('uitmUserForm') != null)
      return Future.error('Error occured. Please restart the app');

    var table = document.getElementById('onlineclassTbl');
    if (table != null) {
      if (table.getElementsByTagName('tbody').isNotEmpty) {
        var table_body = table.getElementsByTagName('tbody')[0];
        var rows = table_body.getElementsByTagName('tr');

        for (var row in rows) {
          var columns = row.getElementsByTagName('td');

          var title = columns[1].text.trim();
          var date = columns[2].text;
          var timeStart = columns[3].text;
          var timeEnd = columns[4].text;
          var link = 'https://ufuture.uitm.edu.my' +
              columns[9].getElementsByTagName('a')[0].attributes['href'];
          AttendanceStatus statusAttendance = AttendanceStatus.NONE;
          String postData;
          var res_attendance = await ns.get(link);

          var doc_att = parse(res_attendance);

          var att_inner_table = doc_att.getElementById('listAttendance');
          var att_checkbox = doc_att.getElementById('hadir');
          if (att_checkbox != null) {
            if (att_checkbox.attributes['disabled'] != null) {
              if (columns[10].text == 'Coming Soon') {
                statusAttendance = AttendanceStatus.COMING_SOON;
              } else {
                statusAttendance = AttendanceStatus.ABSCENT;
              }
            } else {
              var att = att_checkbox.attributes;
              postData = att_checkbox.attributes['value'];
              statusAttendance = AttendanceStatus.AVAILABLE;
            }
          } else {
            if (att_inner_table.getElementsByClassName('text-success').length >
                0) {
              statusAttendance = AttendanceStatus.ATTENDED;
            } else if (att_inner_table
                    .getElementsByClassName('text-danger')
                    .length >
                0) {
              statusAttendance = AttendanceStatus.ABSCENT;
            }
          }

          attendances.add(Attendance(
              title: title,
              timeStart: timeStart,
              timeEnd: timeEnd,
              date: date,
              link: link,
              status: statusAttendance,
              postData: postData));
        }
        return CourseAttendances(title: course, attendances: attendances);
      } else {
        return CourseAttendances(title: course, attendances: []);
      }
    } else {
      return Future.error("Can't find table for (" +
          course +
          "). Try reload or check if you need to fill SUFO or accept pledge for all subject.");
    }
  } catch (e) {
    return Future.error(e);
  }
}

class NetworkService {
  final JsonDecoder _decoder = new JsonDecoder();
  final JsonEncoder _encoder = new JsonEncoder();

  Map<String, String> headers = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.81 Safari/537.36",
  };
  Map<String, String> cookies = {};

  void _updateCookie(http.Response response) {
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['cookie'] = _generateCookieHeader();
    }
  }

  void updateCookieWithKey(String key, String value) {
    this.cookies[key] = value;
    headers['cookie'] = _generateCookieHeader();
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key];
    }

    return cookie;
  }

  Future<String> get(String url) {
    return http.get(url, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw Exception(
            "Error while fetching data (Error $statusCode). Try reload or restart the app.");
      }
      return res;
    });
  }

  Future<String> post(String url, {body, encoding}) {
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw Exception(
            "Error while fetching data (Error $statusCode). Try reload or restart the app.");
      }
      return res;
    });
  }
}
