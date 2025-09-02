import 'package:cuttinglist/screens/side_panel.dart';
import 'package:flutter/material.dart';
import 'csv_header.dart';
import 'csv_row_list.dart';
import 'csv_action_buttons.dart';
import 'csv_data_loader.dart';

class CsvDisplayPage extends StatefulWidget {
  final int fileId;

  CsvDisplayPage({required this.fileId});

  @override
  _CsvDisplayPageState createState() => _CsvDisplayPageState();
}

class _CsvDisplayPageState extends State<CsvDisplayPage> {
  List<List<dynamic>> _csvRows = [];
  bool _showHeader = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rows = await CsvDataLoader.load(widget.fileId);
    setState(() {
      _csvRows = rows;
      _showHeader = rows.isNotEmpty;
    });
  }

  void _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 40.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Cut List")),
      drawer: SidePanel(optionSet: [1, 2, 3, 4]),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            Text("CSV Data:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _csvRows.isEmpty
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      if (_showHeader) ...[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              CsvHeader(headers: _csvRows[0]),
                              CsvRowList(
                                  rows: _csvRows.skip(1).toList(),
                                  rowHeight: rowHeight),
                            ],
                          ),
                        ),
                      ],
                      CsvActionButtons(
                          onRefresh: _refreshData,
                          csvRows: _csvRows,
                          fileId: widget.fileId),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
