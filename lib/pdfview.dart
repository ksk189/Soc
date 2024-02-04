// ignore_for_file: no_logic_in_create_state, unnecessary_null_comparison

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfView extends StatefulWidget {
  final File path;
  final File path1;
  final File path2;
  const PdfView(
      {super.key,
      required this.path,
      required this.path1,
      required this.path2});

  @override
  State<PdfView> createState() => _PdfViewState(
        path: path,
        path1: path1,
        path2: path2,
      );
}

class _PdfViewState extends State<PdfView> {
  final File path;
  final File path1;
  final File path2;
  _PdfViewState({
    required this.path,
    required this.path1,
    required this.path2,
  });

  int crttab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        title: const Text("SOC Exam Hall Allotment"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: crttab == 0
                    ? Colors.black.withOpacity(0.1)
                    : Colors.transparent,
              ),
              onPressed: () {
                setState(() {
                  crttab = 0;
                });
              },
              child: const Text(
                "Attendance Sheet",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: crttab == 1
                    ? Colors.black.withOpacity(0.1)
                    : Colors.transparent,
              ),
              onPressed: () {
                setState(() {
                  crttab = 1;
                });
              },
              child: const Text(
                "Hall Sheet",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: crttab == 2
                    ? Colors.black.withOpacity(0.1)
                    : Colors.transparent,
              ),
              onPressed: () {
                setState(() {
                  crttab = 2;
                });
              },
              child: const Text(
                "Report",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          log(path.uri.toString());
          if (crttab == 0) {
            await Printing.sharePdf(
              bytes: path.readAsBytesSync(),
              filename: 'Attendance-sheet.pdf',
            );
          } else if (crttab == 1) {
            await Printing.sharePdf(
              bytes: path1.readAsBytesSync(),
              filename: 'Hall-Seating.pdf',
            );
          } else {
            await Printing.sharePdf(
              bytes: path2.readAsBytesSync(),
              filename: 'Report.pdf',
            );
          }
        },
        child: const Icon(
          Icons.print,
        ),
      ),
      body: crttab == 0
          ? path.path.isNotEmpty
              ? SizedBox(
                  child: SfPdfViewer.file(
                    path,
                    initialScrollOffset: const Offset(10, 10),
                  ),
                )
              : const SizedBox()
          : crttab == 1
              ? path1.path.isNotEmpty
                  ? SizedBox(
                      child: SfPdfViewer.file(
                        path1,
                        initialScrollOffset: const Offset(10, 10),
                      ),
                    )
                  : const SizedBox()
              : path2.path.isNotEmpty
                  ? SizedBox(
                      child: SfPdfViewer.file(
                        path2,
                        initialScrollOffset: const Offset(10, 10),
                      ),
                    )
                  : const SizedBox(),
    );
  }
}
