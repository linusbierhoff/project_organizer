import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:project_organizer/firebase/database.dart';
import 'package:project_organizer/firebase/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  final Project project;
  PdfService({this.project});

  Future<File> createPDFFromSources() async {
    List<ResearchModel> reserches =
        await DatabaseService(projectID: project.projectID).information.first;

    List<String> sources = [];

    reserches.forEach((e) {
      if (!sources.contains(e.source)) sources.add(e.source);
    });

    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
        build: (context) =>[
              pw.Header(child: pw.Text("Information:")),

              for (int i = 0; i < reserches.length; i++)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                  pw.Text("${reserches[i].title}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Paragraph(
                      text:
                          ("${reserches[i].text}")),
                  pw.Text("[${sources.indexOf(reserches[i].source) + 1}]"),
                  pw.Divider(thickness: 0.1, color: PdfColors.grey)
                ]),
              pw.Header(child: pw.Text("Sources:")),
              for (int i = 0; i < sources.length; i++)
                pw.Paragraph(text: ("[${i + 1}]: ${sources[i]}"))
            ]));

    return PdfService().saveDocument(name: "${project.title}-sources", pdf: pdf);
  }

  Future<File> saveDocument({String name, pw.Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name.pdf');
    await file.writeAsBytes(bytes);

    return file;
  }

  void openFile(File pdfFile) async {
    final url = pdfFile.path;

    await OpenFile.open(url);
  }
}
