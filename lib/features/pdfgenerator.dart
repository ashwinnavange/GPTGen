import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidget;
import 'package:printing/printing.dart';

class CreatePdf {
  Future<void> downloadReport(String descriptiontext) async {
    List<pdfWidget.Widget> widgetList = [];

    final listWidgets=getTextData(descriptiontext);
    for(var value in listWidgets){
      widgetList.add(value);
    }
    final pdf = pdfWidget.Document(pageMode: PdfPageMode.fullscreen);
    pdf.addPage(pdfWidget.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
            marginTop: 40, marginRight: 40, marginBottom: 40, marginLeft: 40),

        header: (pdfWidget.Context context) {
          return pdfWidget.Container();
        },
        footer: (pdfWidget.Context context) {
          return pdfWidget.Container();
        },
        build: (pdfWidget.Context context) {
          return widgetList;
        }
    ));
    final pdfSaved = await pdf.save();

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfSaved);
  }
  List<pdfWidget.Widget> getTextData(textData){
    return [
    pdfWidget.RichText(
        overflow: pdfWidget.TextOverflow.span,
        textAlign: pdfWidget.TextAlign.left,
        text: pdfWidget.TextSpan(
            text: "",
            children: [
            pdfWidget.TextSpan(
            text: textData, style: pdfWidget.TextStyle(fontSize: 14)),
        ],
    ),
    )
    ];
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// Future<void> downloadpdf(String text) async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) =>[
//           pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Paragraph(text: text, style: pw.TextStyle(fontSize: 30)),
//             ],
//           ),
//         ],
//       ),
//     );
//
//     final pdfSaved = await pdf.save();
//
//     // PRINT IT
//     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfSaved);
// }
