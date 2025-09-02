import 'dart:convert';
import 'dart:io';
import 'package:cuttinglist/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../database_helper.dart';

import 'only_canva.dart';

/// === CsvDataLoader ===
class CsvDataLoader {
  static Future<List<List<dynamic>>> load(int fileId) async {
    final dbHelper = DatabaseHelper();
    final rows = await dbHelper.fetchCsvDataForFile(fileId);

    return [
      ["Panel", "Length", "Width", "Number"], // headers
      ...rows.map((row) => [
            row['panel'],
            row['lengthSize'],
            row['widthSize'],
            row['qty'],
          ])
    ];
  }
}

/// === FolderDrawingBoard ===
class FolderDrawingBoard extends StatefulWidget {
  final int folderId;
  const FolderDrawingBoard({super.key, required this.folderId});

  @override
  State<FolderDrawingBoard> createState() => _FolderDrawingBoardState();
}

class _FolderDrawingBoardState extends State<FolderDrawingBoard> {
  List<Map<String, dynamic>> files = [];
  Map<int, List<List<dynamic>>> csvDataPerFile = {}; // fileId -> csv rows
  List<List<DrawnLine>> folderPages = []; // all pages stored in folder_drawings
  int currentIndex = 0;

  bool isLoading = true;
  List<DrawnLine> undoneLines = [];
  Color selectedColor = Colors.black;
  double penStrokeWidth = 5.0;
  double eraserStrokeWidth = 20.0;
  bool isEraser = false;

  final ScreenshotController screenshotController = ScreenshotController();
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadFolderData();
  }

  Future<void> _loadFolderData() async {
    final dbHelper = DatabaseHelper();

    // load files for this folder
    final loadedFiles = await dbHelper.getFiles(widget.folderId);

    // load CSV previews
    for (var file in loadedFiles) {
      final fileId = file['id'] as int;
      final rows = await CsvDataLoader.load(fileId);
      csvDataPerFile[fileId] = rows;
    }

    // load saved folder drawings
    folderPages.clear();
    int page = 0;
    while (true) {
      final savedLines =
          await dbHelper.getFolderDrawingLines(widget.folderId, page);
      if (savedLines.isEmpty && page >= loadedFiles.length) break;

      if (savedLines.isEmpty) {
        folderPages.add([]);
      } else {
        folderPages.add(savedLines.map((row) {
          final color = Color(
              int.parse((row['color'] as String).substring(1), radix: 16));
          final path = decodePath(row['path_json'] as String);
          final strokeWidth = (row['stroke_width'] as num).toDouble();
          final blendMode = BlendMode.values.firstWhere(
            (e) => e.toString() == row['blend_mode'],
            orElse: () => BlendMode.srcOver,
          );
          return DrawnLine(path, color, strokeWidth, blendMode);
        }).toList());
      }
      page++;
    }

    // if no pages at all, create defaults
    if (folderPages.isEmpty) {
      for (int i = 0; i < loadedFiles.length; i++) {
        folderPages.add([]);
      }
    }

    setState(() {
      files = loadedFiles;
      isLoading = false;
    });
  }

  Future<void> saveToGallery() async {
    if (await Permission.storage.request().isGranted) {
      final image = await screenshotController.capture();
      final directory = (await getExternalStorageDirectory())!;
      final file = File(
        '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(image!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saved to ${file.path}")),
        );
      }
    }
  }

  void startDrawing(Offset position) {
    final paintColor = isEraser ? Colors.transparent : selectedColor;
    final blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver;
    final width = isEraser ? eraserStrokeWidth : penStrokeWidth;

    setState(() {
      folderPages[currentIndex].add(
        DrawnLine([position], paintColor, width, blendMode),
      );
    });
  }

  void drawing(Offset position) {
    setState(() {
      if (folderPages[currentIndex].isNotEmpty) {
        folderPages[currentIndex].last.path.add(position);
      }
    });
  }

  void undo() {
    if (folderPages[currentIndex].isNotEmpty) {
      setState(() {
        undoneLines.add(folderPages[currentIndex].removeLast());
      });
    }
  }

  void redo() {
    if (undoneLines.isNotEmpty) {
      setState(() {
        folderPages[currentIndex].add(undoneLines.removeLast());
      });
    }
  }

  void clearCanvas() {
    setState(() {
      folderPages[currentIndex].clear();
      undoneLines.clear();
    });
  }

  void pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => setState(() => selectedColor = color),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void setBrushSize() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEraser ? 'Eraser Size' : 'Brush Size'),
        content: Slider(
          value: isEraser ? eraserStrokeWidth : penStrokeWidth,
          min: 1.0,
          max: 50.0,
          onChanged: (value) => setState(() {
            if (isEraser) {
              eraserStrokeWidth = value;
            } else {
              penStrokeWidth = value;
            }
          }),
        ),
        actions: [
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildCsvPreview(int index) {
    if (index >= files.length) return const SizedBox();
    final fileId = files[index]['id'] as int;
    final csvData = csvDataPerFile[fileId] ?? [];
    if (csvData.isEmpty || csvData.length < 2) return const SizedBox();

    final headers = csvData[0];
    final rows = csvData.sublist(1);

    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                children: headers
                    .map((h) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            h.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ))
                    .toList(),
              ),
              ...rows.map(
                (row) => TableRow(
                  children: row
                      .map((cell) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              cell.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Drawing?"),
        content:
            const Text("Do you want to save your drawings before exiting?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop("cancel"),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () => Navigator.of(context).pop("save"),
          ),
          TextButton(
            child: const Text("Save & Exit"),
            onPressed: () => Navigator.of(context).pop("save_exit"),
          ),
        ],
      ),
    );

    if (result == "cancel" || result == null) return false;

    if (result == "save" || result == "save_exit") {
      final dbHelper = DatabaseHelper();

      // save all pages
      for (int i = 0; i < folderPages.length; i++) {
        final lines = folderPages[i]
            .map((line) => {
                  'path_json': encodePath(line.path),
                  'color':
                      '#${line.color.value.toRadixString(16).padLeft(8, '0')}',
                  'stroke_width': line.width,
                  'blend_mode': line.blendMode.toString(),
                })
            .toList();

        await dbHelper.saveFolderDrawingLines(widget.folderId, i, lines);
      }
    }

    return result == "save_exit";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Drawing Folder")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalPages = folderPages.length;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Folder Drawing"),
          actions: [
            IconButton(icon: const Icon(Icons.undo), onPressed: undo),
            IconButton(icon: const Icon(Icons.redo), onPressed: redo),
            IconButton(icon: const Icon(Icons.delete), onPressed: clearCanvas),
            IconButton(
                icon: const Icon(Icons.download), onPressed: saveToGallery),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Screenshot(
                controller: screenshotController,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: totalPages,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                      undoneLines.clear();
                    });
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onPanStart: (details) =>
                          startDrawing(details.localPosition),
                      onPanUpdate: (details) => drawing(details.localPosition),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.white,
                            child: CustomPaint(
                                painter:
                                    DrawingPainter(lines: folderPages[index])),
                          ),
                          _buildCsvPreview(index),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildBottomToolbar(totalPages),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(int totalPages) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.color_lens,
                color: isEraser ? Colors.grey : selectedColor),
            tooltip: 'Pick Color',
            onPressed: isEraser ? null : pickColor,
          ),
          IconButton(
            icon: Icon(Icons.brush,
                color: !isEraser ? Colors.blue : Colors.black),
            tooltip: 'Brush',
            onPressed: () => setState(() => isEraser = false),
          ),
          IconButton(
            icon: Icon(Icons.cleaning_services,
                color: isEraser ? Colors.red : Colors.black),
            tooltip: 'Eraser',
            onPressed: () => setState(() => isEraser = true),
          ),
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'Brush/Eraser Size',
            onPressed: setBrushSize,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Blank Page',
            onPressed: () {
              setState(() {
                folderPages.add([]);
                currentIndex = folderPages.length - 1;
                pageController.jumpToPage(currentIndex);
              });
            },
          ),
          Text("Page ${currentIndex + 1} / $totalPages"),
        ],
      ),
    );
  }

  encodePath(List<Offset> path) =>
      jsonEncode(path.map((e) => {'dx': e.dx, 'dy': e.dy}).toList());

  // Convert JSON to Offset list
  //
  List<Offset> decodePath(String pathJson) {
    final List decoded = jsonDecode(pathJson);
    return decoded.map((e) => Offset(e['dx'], e['dy'])).toList();
  }
}
