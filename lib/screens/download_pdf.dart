import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

Future<void> downloadPDF(List<List<dynamic>> csvRows) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        children: [
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Woodland Kitchen and Bedrooms',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Cutting List',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: csvRows[0]
                    .map((header) => pw.Text(
                          header.toString(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ))
                    .toList(),
              ),
              ...csvRows.skip(1).map(
                    (row) => pw.TableRow(
                      children:
                          row.map((data) => pw.Text(data.toString())).toList(),
                    ),
                  ),
            ],
          ),
        ],
      ),
    ),
  );

  // Use temporary directory for iOS/iPad
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/csv_data.pdf';
  final file = File(filePath);

  // Save PDF
  await file.writeAsBytes(await pdf.save());

  // Share using Share Sheet (works on iPad)
  await Share.shareXFiles([XFile(filePath)], text: 'CSV Data PDF');
}


// iF above code does not work on iPad, use below code instead


// Future<void> downloadPDF(List<List<dynamic>> csvRows) async {
//   final pdf = pw.Document();

//   // Add a page to the PDF
//   pdf.addPage(
//     pw.Page(
//       build: (pw.Context context) {
//         return pw.Column(
//           children: [
//             // Organization Name Heading
//             pw.Align(
//               alignment: pw.Alignment.center,
//               child: pw.Text(
//                 'Woodland Kitchen and Bedrooms', // Replace with actual organization name
//                 style: pw.TextStyle(
//                   fontSize: 20,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Cutting List Heading
//             pw.Align(
//               alignment: pw.Alignment.center,
//               child: pw.Text(
//                 'Cutting List', // Replace with actual cutting list name or title
//                 style: pw.TextStyle(
//                   fontSize: 18,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Add some space between headings and table
//             pw.SizedBox(height: 20),
//             // Table containing CSV data
//             pw.Table(
//               border: pw.TableBorder.all(),
//               children: [
//                 // Header Row
//                 pw.TableRow(
//                   children: csvRows[0]
//                       .map((header) => pw.Text(
//                             header.toString(),
//                             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                           ))
//                       .toList(),
//                 ),
//                 // Data Rows
//                 ...csvRows
//                     .skip(1)
//                     .map(
//                       (row) => pw.TableRow(
//                         children: row
//                             .map((data) => pw.Text(data.toString()))
//                             .toList(),
//                       ),
//                     )
//                     .toList(),
//               ],
//             ),
//           ],
//         );
//       },
//     ),
//   );

//   // Get the directory where the file will be saved
//   final directory = await getApplicationDocumentsDirectory();
//   final filePath = '${directory.path}/csv_data.pdf';
//   final file = File(filePath);

//   // Save the PDF file to the directory
//   await file.writeAsBytes(await pdf.save());

//   // Share the PDF using the share_plus package
//   await Share.shareXFiles([XFile(filePath)], text: 'CSV Data PDF');
// }
