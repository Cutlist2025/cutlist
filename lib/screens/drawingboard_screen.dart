import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MaterialApp(home: DrawingScreen()));

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<List<DrawnLine>> _pages = [
    [],
    [],
    [],
  ]; // Pre-load 3 pages (with data for the first 3)
  int _currentPageIndex = 0;

  // Example of variable-sized matrices
  List<List<String>> _data1Matrix = [
    ['ID', 'Name', 'Age'],
    ['1', 'Alice', '30'],
    ['2', 'Bob', '25'],
    ['3', 'Charlie', '35'],
  ];

  List<List<String>> _data2Matrix = [
    ['Product', 'Price', 'Stock'],
    ['Laptop', '800', '50'],
    ['Phone', '600', '100'],
    ['Tablet', '400', '200'],
  ];

  List<List<String>> _data3Matrix = [
    ['Country', 'Capital', 'Population'],
    ['USA', 'Washington D.C.', '331M'],
    ['India', 'New Delhi', '1.3B'],
    ['China', 'Beijing', '1.4B'],
  ];

  Color _currentColor = Colors.black;
  double _penStrokeWidth = 4.0;
  double _highlighterStrokeWidth = 10.0;
  double _eraserSize = 20.0;
  String _activeTool = 'pen';

  double _a4Width = 8.27 * 96;
  double _a4Height = 11.69 * 96;

  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drawing Tool (Page ${_currentPageIndex + 1})"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(icon: Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: Icon(Icons.color_lens), onPressed: _pickColor),
          IconButton(icon: Icon(Icons.refresh), onPressed: _clearCanvas),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: RepaintBoundary(
            key: _repaintKey,
            child: Container(
              width: _a4Width,
              height: _a4Height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onPanStart: (details) => _startLine(details.localPosition),
                onPanUpdate: (details) => _updateLine(details.localPosition),
                onPanEnd: (_) => _endLine(),
                onHorizontalDragEnd: (details) =>
                    _handleSwipe(details.primaryVelocity),
                child: CustomPaint(
                  painter: DrawingPainter(
                    lines: _pages[_currentPageIndex],
                    pageText: _getCSVData(),
                  ),
                  size: Size(_a4Width, _a4Height),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.brush),
              onPressed: () => _setTool('pen'),
            ),
            IconButton(
              icon: Icon(Icons.highlight),
              onPressed: () => _setTool('highlighter'),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _setTool('eraser'),
            ), 
            IconButton(
              icon: Icon(Icons.color_lens),
              onPressed: _pickColor,
            ),
          ],
        ),
      ),
    );
  }

  // Get CSV data from the relevant matrix
  String _getCSVData() {
    if (_currentPageIndex == 0) {
      return _convertToCSV(_data1Matrix);
    } else if (_currentPageIndex == 1) {
      return _convertToCSV(_data2Matrix);
    } else if (_currentPageIndex == 2) {
      return _convertToCSV(_data3Matrix);
    } else {
      return 'Blank Page'; // For new blank pages
    }
  }

  // Convert matrix data to CSV string
  String _convertToCSV(List<List<String>> matrix) {
    String csv = '';
    for (var row in matrix) {
      csv += row.join(', ') + '\n';
    }
    return csv;
  }

  void _startLine(Offset startPoint) {
    final paint = Paint()
      ..color = _activeTool == 'eraser'
          ? Colors.transparent
          : (_activeTool == 'highlighter'
              ? _currentColor.withOpacity(0.3)
              : _currentColor)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _activeTool == 'pen'
          ? _penStrokeWidth
          : _activeTool == 'highlighter'
              ? _highlighterStrokeWidth
              : _eraserSize
      ..blendMode =
          _activeTool == 'eraser' ? BlendMode.clear : BlendMode.srcOver;

    setState(() {
      _pages[_currentPageIndex].add(DrawnLine([startPoint], paint));
    });
  }

  void _updateLine(Offset updatePoint) {
    setState(() {
      _pages[_currentPageIndex].last.points.add(updatePoint);
    });
  }

  void _endLine() {
    setState(() {
      _pages[_currentPageIndex].last.points.add(null);
    });
  }

  void _undo() {
    setState(() {
      if (_pages[_currentPageIndex].isNotEmpty) {
        _pages[_currentPageIndex].removeLast();
      }
    });
  }

  void _clearCanvas() {
    setState(() {
      _pages[_currentPageIndex].clear();
    });
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Color"),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() {
                _currentColor = color;
              });
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  void _setTool(String tool) {
    setState(() {
      _activeTool = tool;
    });
  }

  void _handleSwipe(double? velocity) {
    setState(() {
      if (velocity != null && velocity < 0) {
        if (_currentPageIndex == _pages.length - 1) {
          _pages.add([]); // Add new blank page when swiped right
        }
        _currentPageIndex++;
      } else if (velocity != null && velocity > 0) {
        if (_currentPageIndex > 0) {
          _currentPageIndex--;
        }
      }
    });
  }
}

class DrawnLine {
  List<Offset?> points;
  Paint paint;

  DrawnLine(this.points, this.paint);
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final String pageText;

  DrawingPainter({required this.lines, required this.pageText});

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: pageText,
      style: TextStyle(color: Colors.black, fontSize: 20),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, Offset(20, 20));

    final paintHeader = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintText = TextStyle(color: Colors.black, fontSize: 16);

    // Define the quarter-page region
    var startX = 20.0;
    var startY = 60.0;
    double rowHeight = 40.0;
    double columnWidth = 200.0;

    // Draw the table in a quarter of the page
    var headers = ['ID', 'Name', 'Age'];

    for (int i = 0; i < headers.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
            startX + (i * columnWidth), startY, columnWidth, rowHeight),
        paintHeader,
      );
      TextPainter(
        text: TextSpan(text: headers[i], style: paintText),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: columnWidth)
        ..paint(canvas, Offset(startX + (i * columnWidth) + 5, startY + 10));
    }

    var dataMatrix = [
      ['1', 'Alice', '30'],
      ['2', 'Bob', '25'],
      ['3', 'Charlie', '35'],
    ];

    for (int row = 0; row < dataMatrix.length; row++) {
      for (int col = 0; col < dataMatrix[row].length; col++) {
        var color = row % 2 == 0 ? Colors.green : Colors.orange;
        canvas.drawRect(
          Rect.fromLTWH(startX + (col * columnWidth),
              startY + (row + 1) * rowHeight, columnWidth, rowHeight),
          Paint()..color = color,
        );
        TextPainter(
          text: TextSpan(text: dataMatrix[row][col], style: paintText),
          textDirection: TextDirection.ltr,
        )
          ..layout(minWidth: 0, maxWidth: columnWidth)
          ..paint(
              canvas,
              Offset(startX + (col * columnWidth) + 5,
                  startY + (row + 1) * rowHeight + 10));
      }
    }

    // Draw the lines
    for (var line in lines) {
      for (int i = 0; i < line.points.length - 1; i++) {
        if (line.points[i] != null && line.points[i + 1] != null) {
          canvas.drawLine(line.points[i]!, line.points[i + 1]!, line.paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
