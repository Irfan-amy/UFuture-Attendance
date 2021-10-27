enum AttendanceStatus { AVAILABLE, ATTENDED, ABSCENT, COMING_SOON, NONE }

class Attendance {
  String date;
  String timeStart;
  String timeEnd;
  String title;
  String link;
  String postData;
  AttendanceStatus status;
  Attendance(
      {this.date,
      this.timeStart,
      this.timeEnd,
      this.link,
      this.title,
      this.status,
      this.postData});
}
