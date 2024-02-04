import 'dart:developer';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:soc/modelclass.dart';
import 'package:soc/pdfview.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String slot = "";
  String even = "";
  String sess = "SE-I";
  bool loading = false;
  late int studentindex;
  TextEditingController examdate = TextEditingController();
  TextEditingController examyear = TextEditingController();
  TextEditingController examtime = TextEditingController();
  List<ClassRoomDetails> classroomdata = [];
  List<StudentDetails> studentData = [];
  List<AttendanceSheet> attendancesheetData = [];

  HallFileDetails halldetails = HallFileDetails(
    filename: "",
    filepath: "",
  );

  StudentFileDetails studentdetails = StudentFileDetails(
    filename: "",
    filepath: "",
  );

  Future alertbox(BuildContext context, String title, String error) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(error),
        );
      },
    );
  }

  getGallaryFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        halldetails = HallFileDetails(
          filename: file.name.toString(),
          filepath: file.path.toString(),
        );
      });
      // log(file.name);
      // log(file.bytes.toString());
      // log(file.size.toString());
      // log(file.extension.toString());
      // log(file.path.toString());
    } else {
      // User canceled the picker
    }
  }

  getGallaryStudentFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        studentdetails = StudentFileDetails(
          filename: file.name.toString(),
          filepath: file.path.toString(),
        );
      });
    } else {
      // User canceled the picker
    }
  }

  gendratepdf() async {
    setState(() {
      loading = true;
    });
    if (examdate.text.isEmpty) {
      setState(() {
        loading = false;
      });
      alertbox(context, "Waring", "Exam Date is Must");
    } else if (examtime.text.isEmpty) {
      setState(() {
        loading = false;
      });
      alertbox(context, "Waring", "Exam Time is Must");
    } else if (slot.isEmpty) {
      setState(() {
        loading = false;
      });
      alertbox(context, "Waring", "Choose any One Slot is Must");
    } else if (sess.isEmpty) {
      setState(() {
        loading = false;
      });
      alertbox(context, "Waring", "Choose any One Exam is Must");
    } else if (halldetails.filepath.isEmpty || halldetails.filename.isEmpty) {
      setState(() {
        loading = false;
      });
      alertbox(context, "Waring", "Hall Details Excel File is Must");
    } else if (studentdetails.filepath.isEmpty ||
        studentdetails.filename.isEmpty) {
      setState(() {
        loading = false;
      });
      alertbox(context, "Waring", "Students Details Excel File is Must");
    } else {
      setState(() {
        loading = true;
      });
      var hallbytes = File(halldetails.filepath).readAsBytesSync();
      var hallexcel = Excel.decodeBytes(hallbytes);
      var studentbytes = File(studentdetails.filepath).readAsBytesSync();
      var studentexal = Excel.decodeBytes(studentbytes);
      classroomdata.clear();
      studentData.clear();
      int i = 0;
      for (var table in hallexcel.tables.keys) {
        for (var row in hallexcel.tables[table]!.rows) {
          if (i == 0) {
            i++;
            continue;
          } else {
            if (row[0] != null && row[1] != null) {
              setState(() {
                classroomdata.add(
                  ClassRoomDetails(
                    roomno: row[0]!.value.toString(),
                    noperson: row[1]!.value.toString(),
                    centreno: row[2]!.value.toString(),
                  ),
                );
              });
            }
          }
        }
      }
      i = 0;
      for (var table in studentexal.tables.keys) {
        for (var row in studentexal.tables[table]!.rows) {
          if (i == 0) {
            i++;
            continue;
          } else {
            if (row[0] != null &&
                row[1] != null &&
                row[2] != null &&
                row[3] != null &&
                row[4] != null) {
              setState(() {
                studentData.add(
                  StudentDetails(
                    regno: row[0]!.value.toString(),
                    name: row[1]!.value.toString(),
                    coursecode: row[2]!.value.toString(),
                    staffid: row[3]!.value.toString(),
                    sec: row[4]!.value.toString(),
                  ),
                );
              });
            }
          }
        }
      }

      log(studentData.length.toString());

      List<File> file = await attendancesheet();

      setState(() {
        loading = false;
      });

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfView(
            path: file[0],
            path1: file[1],
            path2: file[2],
          ),
        ),
      );
    }
  }

  attendancesheet() async {
    int studentno = 0;
    int tmpstd = 0;
    log(studentno.toString());
    attendancesheetData.clear();
    for (var classdata in classroomdata) {
      if (classdata.noperson == "45") {
        tmpstd = tmpstd + 30;
      }
      if (studentData.length <= studentno) {
        break;
      }
      attendancesheetData.add(
        AttendanceSheet(
          classroom: classdata.roomno.toString(),
          centre: classdata.centreno.toString(),
          totalPerson: classdata.noperson.toString(),
          classsub: [],
          staffcount: [],
          students: [
            for (studentno; studentno < tmpstd; studentno++)
              if (studentData.length > studentno)
                StudentDetails(
                  regno: studentData[studentno].regno.toString(),
                  name: studentData[studentno].name.toString(),
                  coursecode: studentData[studentno].coursecode.toString(),
                  staffid: studentData[studentno].staffid.toString(),
                  sec: studentData[studentno].sec.toString(),
                )
          ],
        ),
      );
    }
    for (var classdata in attendancesheetData) {
      if (classdata.totalPerson == "45") {
        tmpstd = tmpstd + 15;
      }
      if (studentData.length <= studentno) {
        break;
      }
      for (studentno; studentno < tmpstd; studentno++) {
        if (studentData.length > studentno) {
          classdata.students.insert(
            classdata.students.length,
            StudentDetails(
              regno: studentData[studentno].regno.toString(),
              name: studentData[studentno].name.toString(),
              coursecode: studentData[studentno].coursecode.toString(),
              staffid: studentData[studentno].staffid.toString(),
              sec: studentData[studentno].sec.toString(),
            ),
          );
        }
      }
    }

    // subcode count fun

    for (var calsssub in attendancesheetData) {
      for (var subfun in calsssub.students) {
        if (calsssub.classsub.isEmpty) {
          calsssub.classsub.insert(
            calsssub.classsub.length,
            SubHallcountdetails(
              subcode: subfun.coursecode,
              dubcount: 1,
            ),
          );
        } else if (subfun.coursecode == calsssub.classsub.last.subcode) {
          calsssub.classsub.last.dubcount += 1;
        } else if (subfun.coursecode != calsssub.classsub.last.subcode) {
          calsssub.classsub.insert(
            calsssub.classsub.length,
            SubHallcountdetails(
              subcode: subfun.coursecode,
              dubcount: 1,
            ),
          );
        }
      }
    }

    // staff sub count fun

    for (var calsssub in attendancesheetData) {
      for (var subfun in calsssub.students) {
        if (calsssub.staffcount.isEmpty) {
          calsssub.staffcount.insert(
            calsssub.staffcount.length,
            SubHallStaffcountdetails(
              staffid: subfun.staffid.toString(),
              subcode: subfun.coursecode.toString(),
              staffcount: 1,
            ),
          );
        } else {
          var contain = calsssub.staffcount.where(
            (element) => element.staffid == subfun.staffid,
          );
          if (contain.isNotEmpty) {
            calsssub
                .staffcount[calsssub.staffcount
                    .indexWhere((element) => element.staffid == subfun.staffid)]
                .staffcount += 1;
          } else {
            calsssub.staffcount.insert(
              calsssub.staffcount.length,
              SubHallStaffcountdetails(
                staffid: subfun.staffid.toString(),
                subcode: subfun.coursecode.toString(),
              
                staffcount: 1,
              ),
            );
          }
        }
      }
    }

    log(attendancesheetData[0].staffcount.length.toString());

    final pdf = pw.Document();
    for (var hallstudent in attendancesheetData) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Kalasalingam Academy of Research and Education"
                        .toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "(Deemed to be University)",
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "Anand Nagar, Krishnankoil - 626 126.",
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "School of Computing",
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text(
                    "Attendance Sheet".toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "${sess.toString()} - ${even.toString()}  SEMESTER - ${examyear.text.toString()}",
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.black,
                  ),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Exam Date: ${examdate.text}",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "Time: ${examtime.text.toString()}",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Room No: ${hallstudent.classroom}",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.black,
                  ),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Center(
                            child: pw.Text(
                              "S.No",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "Regno",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "Name",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Center(
                            child: pw.Text(
                              "Sec",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Center(
                            child: pw.Text(
                              "Staff ID",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Center(
                            child: pw.Text(
                              "Course Code",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "Answer Seet No",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "Signature",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (int j = 0; j < hallstudent.students.length; j++)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                (j + 1).toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                hallstudent.students[j].regno.toString(),
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              hallstudent.students[j].name.toString(),
                              textAlign: pw.TextAlign.left,
                              style: const pw.TextStyle(
                                fontSize: 7,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                hallstudent.students[j].sec.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                hallstudent.students[j].staffid.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                hallstudent.students[j].coursecode.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "",
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                "",
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.black,
                  ),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Total No of Answer Booklet Received",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Total No of Present",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Total No of Absent",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Hall Supervisors Sign",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "Technicians Sign",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              "",
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());

    final pdf1 = pw.Document();
    for (int c = 0; c < attendancesheetData.length; c++) {
      pdf1.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Kalasalingam Academy of Research and Education"
                        .toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "(Deemed to be University)",
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "Anand Nagar, Krishnankoil - 626 126.",
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "School of Computing",
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text(
                    "Attendance Sheet".toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "${sess.toString()} - ${even.toString()}  SEMESTER - ${examyear.text.toString()}",
                    //"SE-I/SE-II Odd/Even 20__ - 20__".toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "${attendancesheetData[c].classroom.toString()} - HAll"
                        .toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    "${examdate.text} - ${examtime.text}",
                    style: const pw.TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    for (var subdetails in attendancesheetData[c].classsub)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          "${subdetails.subcode} - ${subdetails.dubcount}"
                              .toString(),
                        ),
                      ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.black,
                  ),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C1",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C2",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C3",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C4",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C5",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C6",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C7",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C8",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(2.5),
                            child: pw.Center(
                              child: pw.Text(
                                "C9",
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (attendancesheetData[c].totalPerson == "45")
                      for (int z = 0; z < 5; z++)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  z < attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z].regno.toString()}\n${attendancesheetData[c].students[z].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 30) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 30].regno.toString()}\n${attendancesheetData[c].students[z + 30].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 5) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 5].regno.toString()}\n${attendancesheetData[c].students[z + 5].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 10) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 10].regno.toString()}\n${attendancesheetData[c].students[z + 10].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 35) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 35].regno.toString()}\n${attendancesheetData[c].students[z + 35].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 15) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 15].regno.toString()}\n${attendancesheetData[c].students[z + 15].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 20) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 20].regno.toString()}\n${attendancesheetData[c].students[z + 20].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 40) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 40].regno.toString()}\n${attendancesheetData[c].students[z + 40].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.5),
                              child: pw.Center(
                                child: pw.Text(
                                  (z + 25) <
                                          attendancesheetData[c].students.length
                                      ? "${attendancesheetData[c].students[z + 25].regno.toString()}\n${attendancesheetData[c].students[z + 25].name.toString()}"
                                      : "",
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
    final output1 = await getTemporaryDirectory();
    final file1 = File("${output1.path}/seating.pdf");
    await file1.writeAsBytes(await pdf1.save());

    final pdf2 = pw.Document();
    for (var attcls in attendancesheetData) {
      
      pdf2.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Kalasalingam Academy of Research and Education"
                        .toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "(Deemed to be University)",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "Anand Nagar, Krishnankoil - 626 126.",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "School of Computing",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Center(
                  child: pw.Text(
                    "${examdate.text} - ${examtime.text} - SLOT - $slot"
                        .toString(),
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                   
                  ],
                ),
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.black,
                  ),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Center(
                            child: pw.Text(
                              "Room No",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Center(
                            child: pw.Text(
                              "Centre no",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Center(
                            child: pw.Text(
                              "Staff ID",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Center(
                            child: pw.Text(
                              "Course Code",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1),
                          child: pw.Center(
                            child: pw.Text(
                              "Count",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var subcoude in attcls.staffcount)
                    
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Center(
                              child: pw.Text(
                                attcls.classroom.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                           pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Center(
                              child: pw.Text(
                                attcls.centre.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Center(
                              child: pw.Text(
                                subcoude.staffid.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Center(
                              child: pw.Text(
                                subcoude.subcode.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Center(
                              child: pw.Text(
                                subcoude.staffcount.toString(),
                                style: const pw.TextStyle(
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
    final output2 = await getTemporaryDirectory();
    final file2 = File("${output2.path}/ReportData.pdf");
    await file2.writeAsBytes(await pdf2.save());
    return [file, file1, file2];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        title: const Text("SOC Exam Hall Allotment"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Exam Hall Allotment",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Form(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: examdate,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: Color(0xffE2E2E2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Exam Date",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: examtime,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: Color(0xffE2E2E2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Exam time",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: examyear,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: Color(0xffE2E2E2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Academic Year",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      child: DropdownButtonFormField(
                        value: slot.isEmpty ? null : slot,
                        onChanged: (v) {
                          setState(() {
                            slot = v.toString();
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: "I",
                            child: Text(
                              "Slot - I",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "II",
                            child: Text(
                              "Slot - II",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "III",
                            child: Text(
                              "Slot - III",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "IV",
                            child: Text(
                              "Slot - IV",
                            ),
                          ),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: Color(0xffE2E2E2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Choose Slot",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      child: DropdownButtonFormField(
                        value: sess.isEmpty ? null : sess,
                        onChanged: (v) {
                          setState(() {
                            sess = v.toString();
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: "SE-I",
                            child: Text(
                              "SE - I",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "SE-II",
                            child: Text(
                              "SE - II",
                            ),
                          ),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: Color(0xffE2E2E2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "SE-I",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 40,
                      child: DropdownButtonFormField(
                        value: even.isEmpty ? null : even,
                        onChanged: (v) {
                          setState(() {
                            even = v.toString();
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: "EVEN",
                            child: Text(
                              "EVEN",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "ODD",
                            child: Text(
                              "ODD",
                            ),
                          ),
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: Color(0xffE2E2E2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "EVEN / ODD",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    halldetails.filename.isNotEmpty
                        ? SizedBox(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      halldetails.filename.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          halldetails.filename = "";
                                          halldetails.filepath = "";
                                        });
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          )
                        : const SizedBox(),
                    GestureDetector(
                      onTap: () {
                        getGallaryFile();
                      },
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Upload Hall Details",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    studentdetails.filename.isNotEmpty
                        ? SizedBox(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      studentdetails.filename.toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          studentdetails.filename = "";
                                          studentdetails.filepath = "";
                                        });
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          )
                        : const SizedBox(),
                    GestureDetector(
                      onTap: () {
                        getGallaryStudentFile();
                      },
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Upload Student Details",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        gendratepdf();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
