class HallFileDetails {
  String filename;
  String filepath;
  HallFileDetails({
    required this.filename,
    required this.filepath,
  });
}

class StudentFileDetails {
  String filename;
  String filepath;
  StudentFileDetails({
    required this.filename,
    required this.filepath,
  });
}

class Attendance {
  final String sno;
  final String regno;
  final String name;
  final String sec;
  final String coursecode;
  Attendance({
    required this.sno,
    required this.regno,
    required this.name,
    required this.sec,
    required this.coursecode,
  });
}

class ClassRoomDetails {
  final String roomno;
  final String noperson;
  final String centreno;
  ClassRoomDetails({
    required this.roomno,
    required this.noperson,
    required this.centreno,
  });
}

class StudentDetails {
  final String regno;
  final String name;
  final String coursecode;
  final String staffid;
  final String sec;
  StudentDetails({
    required this.regno,
    required this.name,
    required this.coursecode,
    required this.staffid,
    required this.sec,
  });
}

class SheetingDetails {
  final List<StudentDetails> c1;
  final List<StudentDetails> c2;
  final List<StudentDetails> c3;
  final List<StudentDetails> c4;
  final List<StudentDetails> c5;
  final List<StudentDetails> c6;
  final List<StudentDetails> c7;
  final List<StudentDetails> c8;
  final List<StudentDetails> c9;
  SheetingDetails({
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
    required this.c5,
    required this.c6,
    required this.c7,
    required this.c8,
    required this.c9,
  });
}

class SubHallcountdetails {
  final String subcode;
  int dubcount;
  SubHallcountdetails({required this.subcode, required this.dubcount});
}

class SubHallStaffcountdetails {
  final String staffid;
 
  final String subcode;
  int staffcount;
  SubHallStaffcountdetails(
      {required this.staffid, required this.subcode, required this.staffcount,});
}

class AttendanceSheet {
  final String classroom;
  final String centre;
  final String totalPerson;
  final List<SubHallcountdetails> classsub;
  final List<SubHallStaffcountdetails> staffcount;
  final List<StudentDetails> students;
  AttendanceSheet({
    required this.classroom,
    required this.centre,
    required this.totalPerson,
    required this.classsub,
    required this.staffcount,
    required this.students,
  });
}
