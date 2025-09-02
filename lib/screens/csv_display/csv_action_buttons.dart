import 'package:cuttinglist/screens/only_canva.dart';
import 'package:flutter/material.dart';
import '../dialogs/add_item_dialog.dart';
import '../../database_helper.dart';
import '../download_pdf.dart';
import 'item_handler.dart';

class CsvActionButtons extends StatelessWidget {
  final VoidCallback onRefresh;
  final List<List<dynamic>> csvRows;
  final int fileId;

  CsvActionButtons(
      {required this.onRefresh, required this.csvRows, required this.fileId});

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AddItemDialog(
          onSave: (itemType, inputs) async {
            await ItemHandler.handleSave(itemType, inputs, fileId);
            onRefresh();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => _showAddItemDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          child: Text("+ Add Items",
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DrawingBoard(fileId: fileId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          child: Text("Canva",
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () async {
            await downloadPDF(csvRows);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          child: Text("Download",
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
