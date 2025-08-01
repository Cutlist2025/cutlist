import 'dart:io';
import 'package:cuttinglist/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class DrawingBoard extends StatefulWidget {
  final int fileId;
  DrawingBoard({required this.fileId});

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  List<List<DrawnLine>> pages = [[]];
  int currentPage = 0;
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
    loadFromDatabase(widget.fileId);
  }

  Future<void> loadFromDatabase(int fileId) async {
    List<List<DrawnLine>> loadedPages =
        await DatabaseHelper().loadDrawingLines(fileId);
    debugPrint('Loaded ${loadedPages.length} pages from database');

    setState(() {
      pages = loadedPages.isEmpty ? [[]] : loadedPages;
    });
  }

  Future<bool> _onWillPop() async {
    bool shouldLeave = await _showSaveConfirmationDialog();
    return shouldLeave;
  }

  Future<bool> _showSaveConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save Drawing?'),
            content:
                const Text('Do you want to save your changes before exiting?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // don't exit
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await DatabaseHelper().saveDrawingLines(widget.fileId, pages);
                  Navigator.of(context).pop(true); // exit
                },
                child: const Text('Save & Exit'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // discard and exit
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> saveToGallery() async {
    if (await Permission.storage.request().isGranted) {
      final image = await screenshotController.capture();
      final directory = (await getExternalStorageDirectory())!;
      final file = File(
        '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(image!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved to ${file.path}")),
      );
    }
  }

  void startDrawing(Offset position, int pageIndex) {
    final paintColor = isEraser ? Colors.transparent : selectedColor;
    final blendMode = isEraser ? BlendMode.clear : BlendMode.srcOver;
    final width = isEraser ? eraserStrokeWidth : penStrokeWidth;

    setState(() {
      pages[pageIndex].add(DrawnLine(
        [position],
        paintColor,
        width,
        blendMode,
      ));
    });
  }

  void drawing(Offset position, int pageIndex) {
    setState(() {
      if (pages[pageIndex].isNotEmpty) {
        pages[pageIndex].last.path.add(position);
      }
    });

    // Auto-save after each stroke update (optional but heavy on DB)
    // DatabaseHelper().saveDrawingLines(widget.fileId, pages);
  }

  void undo() {
    if (pages[currentPage].isNotEmpty) {
      setState(() {
        undoneLines.add(pages[currentPage].removeLast());
      });
    }
  }

  void redo() {
    if (undoneLines.isNotEmpty) {
      setState(() {
        pages[currentPage].add(undoneLines.removeLast());
      });
    }
  }

  void clearCanvas() {
    setState(() {
      pages[currentPage].clear();
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
              onPressed: () => Navigator.of(context).pop()),
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
              onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  void addNewPage() {
    setState(() {
      pages.add([]);
      currentPage = pages.length - 1;
      pageController.jumpToPage(currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (didPop) return;

        bool shouldExit = await _showSaveConfirmationDialog();
        if (shouldExit) {
          DatabaseHelper().saveDrawingLines(widget.fileId, pages);
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Drawing Board"),
          actions: [
            IconButton(icon: const Icon(Icons.undo), onPressed: undo),
            IconButton(icon: const Icon(Icons.redo), onPressed: redo),
            IconButton(icon: const Icon(Icons.delete), onPressed: clearCanvas),
            IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => saveToDatabase(widget.fileId)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Screenshot(
                controller: screenshotController,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                      undoneLines.clear();
                    });
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onPanStart: (details) {
                        startDrawing(details.localPosition, index);
                      },
                      onPanUpdate: (details) {
                        drawing(details.localPosition, index);
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                        child: CustomPaint(
                          painter: DrawingPainter(lines: pages[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
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
                    tooltip: 'Add Page',
                    onPressed: addNewPage,
                  ),
                  Text("Page ${currentPage + 1} / ${pages.length}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveToDatabase(int fileId) async {
    await DatabaseHelper().saveDrawingLines(fileId, pages);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Drawing saved successfully.")),
      );
    }
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  DrawingPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBounds = Offset.zero & size;
    canvas.saveLayer(paintBounds, Paint());

    for (var line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..blendMode = line.blendMode;

      for (int i = 0; i < line.path.length - 1; i++) {
        canvas.drawLine(line.path[i], line.path[i + 1], paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawnLine {
  List<Offset> path;
  Color color;
  double width;
  BlendMode blendMode;

  DrawnLine(this.path, this.color, this.width, this.blendMode);
}
