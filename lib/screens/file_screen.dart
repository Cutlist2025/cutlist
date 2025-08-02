import 'package:cuttinglist/screens/only_canva.dart';
import 'package:cuttinglist/screens/side_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cuttinglist/database_helper.dart';
import 'package:cuttinglist/screens/csv_ui.dart';
import 'package:cuttinglist/screens/drawingboard_screen.dart'; // Ensure this file exists

// ... (imports remain the same)

class FileScreen extends StatefulWidget {
  final int folderId;

  FileScreen({required this.folderId});

  @override
  _FileScreenState createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  final _fileController = TextEditingController();
  final _contentController = TextEditingController();
  List<Map<String, dynamic>> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      var files = await DatabaseHelper().getFiles(widget.folderId);
      setState(() {
        _files = files;
      });
    } catch (e) {
      print("Error loading files: $e");
    }
  }

  Future<void> _createFile() async {
    if (_fileController.text.isNotEmpty) {
      try {
        await DatabaseHelper().insertFile(
          widget.folderId,
          _fileController.text,
          _contentController.text,
        );
        _fileController.clear();
        _contentController.clear();
        _loadFiles();
      } catch (e) {
        print("Error creating file: $e");
      }
    }
  }

  void _showFileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Object'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fileController,
                decoration:
                    InputDecoration(labelText: 'Location Name (eg: Room)'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Any Comments'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _createFile();
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Project List")),
      drawer: SidePanel(optionSet: [1, 2, 3, 4]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _files.length,
          itemBuilder: (context, index) {
            final file = _files[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                leading:
                    Icon(Icons.insert_drive_file, color: Colors.blue, size: 40),
                title: Text(
                  file['name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Created: ${DateFormat('dd MMM yyyy').format(
                    DateTime.parse(file['created_at'] ?? ''),
                  )}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CsvDisplayPage(fileId: file['id']),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showFileDialog,
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
              heroTag: 'addFile',
              tooltip: 'Add File',
            ),
          ),
          Positioned(
            bottom: 16,
            left: 525,
            child: FloatingActionButton(
              onPressed: () {
                if (_files.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DrawingBoard(fileId: _files.first['id']),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please add a file first.')),
                  );
                }
              },
              child: Icon(Icons.brush),
              backgroundColor: Colors.green,
              heroTag: 'openCanva',
              tooltip: 'Open Canva for first file',
            ),
          ),
        ],
      ),
    );
  }
}
