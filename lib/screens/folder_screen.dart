import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cuttinglist/database_helper.dart';
import 'package:cuttinglist/screens/side_panel.dart';
import 'file_screen.dart';

class FolderListScreen extends StatefulWidget {
  @override
  _FolderListScreenState createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  final _folderController = TextEditingController();
  List<Map<String, dynamic>> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  _loadFolders() async {
    var folders = await DatabaseHelper().getFolders();
    setState(() {
      _folders = folders;
    });
  }

  _createFolder() async {
    if (_folderController.text.isNotEmpty) {
      await DatabaseHelper().insertFolder(_folderController.text);
      _folderController.clear();
      _loadFolders();
    }
  }

  _deleteFolder(int folderId) async {
    await DatabaseHelper().deleteFolder(folderId);
    _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Client Folders")),
      drawer: SidePanel(optionSet: [1, 2, 3, 4]),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount:
              _folders.length + 1, // Plus one for the "add new folder" button
          itemBuilder: (context, index) {
            if (index == 0) {
              // "Create +" button at the first position
              return GestureDetector(
                onTap: () {
                  _showFolderDialog();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              );
            } else {
              final folder = _folders[index - 1];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileScreen(folderId: folder['id']),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder, color: Colors.blue[700], size: 40),
                      SizedBox(height: 8),
                      Text(
                        folder['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue[900], fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(
                          DateTime.parse(folder['created_at']),
                        ),
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _showFolderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Insert Client Name'),
          content: TextField(
            controller: _folderController,
            decoration: InputDecoration(labelText: 'Client Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _createFolder();
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
