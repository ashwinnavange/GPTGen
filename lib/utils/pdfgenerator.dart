import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidget;
import 'package:printing/printing.dart';

class CreatePdf {
  Future<void> downloadReport(String descriptiontext) async {
    List<pdfWidget.Widget> widgetList = [];

    final listWidgets = getTextData(descriptiontext);
    for (var value in listWidgets) {
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
        }));
    final pdfSaved = await pdf.save();

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfSaved);
  }

  List<pdfWidget.Widget> getTextData(textData) {
    return [
      pdfWidget.RichText(
        overflow: pdfWidget.TextOverflow.span,
        textAlign: pdfWidget.TextAlign.left,
        text: pdfWidget.TextSpan(
          text: "",
          children: [
            pdfWidget.TextSpan(
                text: textData, style: const pdfWidget.TextStyle(fontSize: 12)),
          ],
        ),
      )
    ];
  }
}
