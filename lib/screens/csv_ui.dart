import 'package:cuttinglist/database_helper.dart';
import 'package:cuttinglist/formulas/cupdoard.dart';
import 'package:cuttinglist/screens/download_pdf.dart';
import 'package:cuttinglist/screens/side_panel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'add_item_dialog.dart'; // Import the AddItemDialog file

class CsvDisplayPage extends StatefulWidget {
  final int fileId; // Pass the fileId to load CSV for that specific file
  CsvDisplayPage({required this.fileId});

  @override
  _CsvDisplayPageState createState() => _CsvDisplayPageState();
}

class _CsvDisplayPageState extends State<CsvDisplayPage> {
  List<List<dynamic>> _csvRows = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showHeader = false; // To control header visibility

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase(); // Load data when page loads
  }

  // Load CSV data from the database for a specific file
  Future<void> _loadDataFromDatabase() async {
    final dbHelper = DatabaseHelper();
    final rows = await dbHelper.fetchCsvDataForFile(widget.fileId);

    // Map data to CSV format
    List<List<dynamic>> rowsList = [
      ["Panel", "Length", "Width", "Number"],
      ...rows.map((row) => [
            row['panel'],
            row['lengthSize'],
            row['widthSize'],
            row['qty'],
          ])
    ];

    setState(() {
      _csvRows = rowsList;
      _showHeader = _csvRows.isNotEmpty; // Show header only if there is data
    });
  }

  // Method to handle the Add Item button
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItemDialog(
          onSave: (itemType, inputs) async {
            final dbHelper = DatabaseHelper();
            print("itemType: $itemType");
            print("inputs: $inputs");
            // print("Drawer Hieght: ${inputs['drawerHeight']}");
            final splitValue = inputs['customSplitValue'] ?? 0;

            if (itemType == 'Cupboard') {
              // Insert multiple rows for Cupboard components
              final List<Map<String, dynamic>> cupboardComponents = [
                {
                  'type': 'Cupboard',
                  'length': inputs['length'],
                  'width': inputs['width'],
                  'depth': inputs['depth'],
                  'lengthSize': sideHeight(inputs['length'], inputs['width'],
                      inputs['depth']), // Add length and depth
                  'widthSize': sideWidht(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'qty': 2,
                  'panel': 'Sides'
                },
                {
                  'type': 'Cupboard',
                  'length': inputs['length'],
                  'width': inputs['width'],
                  'depth': inputs['depth'],
                  'lengthSize': topBottomHieght(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'widthSize': topBottomWidth(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'qty': 2,
                  'panel': 'Top/Bottom'
                },
                {
                  'type': 'Cupboard',
                  'length': inputs['length'],
                  'width': inputs['width'],
                  'depth': inputs['depth'],
                  'lengthSize': backHeight(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'widthSize': backWidth(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'qty': 1,
                  'panel': 'Back'
                },
                {
                  'type': 'Cupboard',
                  'length': inputs['length'],
                  'width': inputs['width'],
                  'depth': inputs['depth'],
                  'lengthSize': doorHeight(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'widthSize': doorWidth(
                      inputs['length'], inputs['width'], inputs['depth']),
                  'qty': 2,
                  'panel': 'Door'
                },
              ];
              if (inputs['horizontalSplit'] == 'Yes' &&
                  (inputs['horizontalSplitPosition'] == 'Top' ||
                      inputs['horizontalSplitPosition'] == 'Bottom')) {
                cupboardComponents.add({
                  'type': 'Cupboard',
                  'length': inputs['length'],
                  'width': inputs['width'],
                  'depth': inputs['depth'],
                  'lengthSize': inputs['depth'],
                  'widthSize': inputs['depth'],
                  'qty': 1,
                  'panel': 'Horizontal Split Slab'
                });
                if (inputs['horizontalSplit'] == 'Yes' &&
                    (inputs['horizontalSplitPosition'] == 'Both')) {
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': inputs['depth'],
                    'widthSize': inputs['depth'],
                    'qty': 2,
                    'panel': 'Horizontal Split Slab'
                  });
                }
              }

              // If vertical split is selected, add the vertical split slab
              if (inputs['verticalSplit'] == 'Custom Split' ||
                  inputs['verticalSplit'] == 'Split Half') {
                cupboardComponents.add({
                  'type': 'Cupboard',
                  'length': inputs['length'],
                  'width': inputs['width'],
                  'depth': inputs['depth'],
                  'lengthSize': inputs['depth'],
                  'widthSize': inputs['depth'],
                  'qty': 1,
                  'panel': 'Vertical Split Slab'
                });
                if (int.tryParse(inputs['slabs'].toString()) != null &&
                    int.parse(inputs['slabs'].toString()) > 0) {
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': shelfHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': shelfWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': inputs['slabs'],
                    'panel': 'Shelves'
                  });
                }

                if (int.tryParse(inputs['drawers'].toString()) != null &&
                    int.parse(inputs['drawers'].toString()) > 0) {
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPackTopHeight(
                        inputs['length'],
                        inputs['width'],
                        inputs['depth']), // Add length and depth
                    'widthSize': drawerPackTopWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 1,
                    'panel': 'Drawer Pack Top'
                  });
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPackFillerHeight(
                        inputs['length'],
                        inputs['width'],
                        inputs['depth'],
                        inputs['drawerHeight']),
                    'widthSize': drawerPackFillerWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 2,
                    'panel': 'Drawer Pack Filler'
                  });
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPacksidesHeight(
                        inputs['length'],
                        inputs['width'],
                        inputs['depth'],
                        inputs['drawerHeight']),
                    'widthSize': drawerPacksidesWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 2,
                    'panel': 'Drawer Pack Sides'
                  });

                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPackTopBottomHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerPackTopBottomWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 2,
                    'panel': 'Drawer Pack Top/Bottom'
                  });

                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerBaseHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerBaseWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': inputs['drawers'],
                    'panel': 'Drawer Bases'
                  });

                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerFrontBackHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerFrontBackWidth(
                        inputs['drawerHeight'], inputs['drawers']),
                    'qty': (2 * int.parse(inputs['drawers'])).toString(),
                    'panel': 'Drawer Front/Back'
                  });
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerSidesHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerSidesWidth(
                        inputs['drawerHeight'], inputs['drawers']),
                    'qty': (2 * int.parse(inputs['drawers'])).toString(),
                    'panel': 'Drawer Sides'
                  });
                }
              }

              // If no split, add shelves
              if (inputs['verticalSplit'] == 'No Split') {
                if (int.tryParse(inputs['slabs'].toString()) != null &&
                    int.parse(inputs['slabs'].toString()) > 0) {
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': shelfHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': shelfWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': inputs['slabs'],
                    'panel': 'Shelves'
                  });
                }

                if (int.tryParse(inputs['drawers'].toString()) != null &&
                    int.parse(inputs['drawers'].toString()) > 0) {
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPackTopHeight(
                        inputs['length'],
                        inputs['width'],
                        inputs['depth']), // Add length and depth
                    'widthSize': drawerPackTopWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 1,
                    'panel': 'Drawer Pack Top'
                  });
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPackFillerHeight(
                        inputs['length'],
                        inputs['width'],
                        inputs['depth'],
                        inputs['drawerHeight']),
                    'widthSize': drawerPackFillerWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 2,
                    'panel': 'Drawer Pack Filler'
                  });
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPacksidesHeight(
                        inputs['length'],
                        inputs['width'],
                        inputs['depth'],
                        inputs['drawerHeight']),
                    'widthSize': drawerPacksidesWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 2,
                    'panel': 'Drawer Pack Sides'
                  });

                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerPackTopBottomHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerPackTopBottomWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': 2,
                    'panel': 'Drawer Pack Top/Bottom'
                  });

                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerBaseHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerBaseWidth(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'qty': inputs['drawers'],
                    'panel': 'Drawer Bases'
                  });

                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerFrontBackHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerFrontBackWidth(
                        inputs['drawerHeight'], inputs['drawers']),
                    'qty': (2 * int.parse(inputs['drawers'])).toString(),
                    'panel': 'Drawer Front/Back'
                  });
                  cupboardComponents.add({
                    'type': 'Cupboard',
                    'length': inputs['length'],
                    'width': inputs['width'],
                    'depth': inputs['depth'],
                    'lengthSize': drawerSidesHeight(
                        inputs['length'], inputs['width'], inputs['depth']),
                    'widthSize': drawerSidesWidth(
                        inputs['drawerHeight'], inputs['drawers']),
                    'qty': (2 * int.parse(inputs['drawers'])).toString(),
                    'panel': 'Drawer Sides'
                  });
                }
              }

              // Drawer Pack Components

              //  data bases data push
              for (var component in cupboardComponents) {
                await dbHelper.insertCsvDataForFile(widget.fileId, component);
              }
            } else if (itemType == 'Table') {
              // Add Table data to the database
              await dbHelper.insertCsvDataForFile(widget.fileId, {
                'type': itemType,
                'length': inputs['length'],
                'width': inputs['width'],
                'depth': inputs['depth'],
                'lengthSize': null,
                'widthSize': null,
                'qty': 1,
                'panel': null,
              });
            }

            // Reload data
            await _loadDataFromDatabase();

            // Close the dialog
            // Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Cut List'),
      ),
      // drawer: SidePanel(), // Add the side panel here

      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          const double rowHeight = 40.0;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'CSV Data:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _csvRows.isEmpty
                      ? CircularProgressIndicator()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_showHeader) ...[
                              // CSV Data Box
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    // Sticky Header
                                    Container(
                                      color: Colors.grey[200],
                                      child: Row(
                                        children: _csvRows[0]
                                            .map((header) => Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      header.toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    // Scrollable Content
                                    SizedBox(
                                      height: (_csvRows.length - 1 <= 10
                                              ? (_csvRows.length - 1) *
                                                  rowHeight
                                              : 10 * rowHeight)
                                          .toDouble(),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: _csvRows
                                              .skip(1)
                                              .map(
                                                (row) => Row(
                                                  children: row
                                                      .map(
                                                        (data) => Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(data
                                                                .toString()),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            // Add Button Outside the Box
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left-aligned button
                                ElevatedButton(
                                  onPressed: () {
                                    _showAddItemDialog(); // Replace with your function
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: Text(
                                    "Add Items",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),

                                // Right-aligned button
                                ElevatedButton(
                                  onPressed: () async {
                                    await downloadPDF(_csvRows);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: Text(
                                    "Download",
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
