import 'dart:convert';
import 'package:cuttinglist/screens/only_canva.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'folder_file.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE folders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            created_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE files(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER,
            name TEXT,
            content TEXT,
            created_at TEXT,
            FOREIGN KEY(folder_id) REFERENCES folders(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE drawings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER,
        page_number INTEGER,
        path_json TEXT,
        color TEXT,
        stroke_width REAL,
        blend_mode TEXT,
        FOREIGN KEY(file_id) REFERENCES files(id) ON DELETE CASCADE

      )
    ''');

        await db.execute('''
          CREATE TABLE csv_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            length TEXT,
            width TEXT,
            depth TEXT,
            lengthSize TEXT,
            widthSize TEXT,
            qty TEXT,
            panel TEXT,
            file_id INTEGER,
            FOREIGN KEY(file_id) REFERENCES files(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Future schema upgrades
        }
      },
    );
  }

  // ------------------ Folder & File Methods ------------------

  Future<void> insertFolder(String folderName) async {
    final db = await database;
    await db.insert(
      'folders',
      {
        'name': folderName,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await database;
    return await db.query('folders', orderBy: 'created_at DESC');
  }

  Future<void> insertFile(int folderId, String fileName, String content) async {
    final db = await database;
    await db.insert(
      'files',
      {
        'folder_id': folderId,
        'name': fileName,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFiles(int folderId) async {
    final db = await database;
    return await db.query(
      'files',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> updateFile(int fileId, String content) async {
    final db = await database;
    return await db.update(
      'files',
      {'content': content},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  Future<int> deleteFile(int fileId) async {
    final db = await database;
    return await db.delete(
      'files',
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  Future<int> deleteFolder(int folderId) async {
    final db = await database;
    await db.delete('files', where: 'folder_id = ?', whereArgs: [folderId]);
    return await db.delete('folders', where: 'id = ?', whereArgs: [folderId]);
  }

  Future<List<Map<String, dynamic>>> getFilesWithFolders() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT files.*, folders.name AS folder_name
      FROM files
      JOIN folders ON files.folder_id = folders.id
      ORDER BY files.created_at DESC
    ''');
  }

  // ------------------ CSV Data Methods ------------------

  Future<int> insertCsvDataForFile(
      int fileId, Map<String, dynamic> data) async {
    final db = await database;
    data['file_id'] = fileId;
    return await db.insert('csv_data', data);
  }

  Future<List<Map<String, dynamic>>> fetchCsvDataForFile(int fileId) async {
    final db = await database;
    return await db.query(
      'csv_data',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
  }

  // ------------------ Drawing Methods ------------------

  // Convert Offset list to JSON
  String encodePath(List<Offset> path) =>
      jsonEncode(path.map((e) => {'dx': e.dx, 'dy': e.dy}).toList());

  // Convert JSON to Offset list
  List<Offset> decodePath(String pathJson) {
    final List decoded = jsonDecode(pathJson);
    return decoded.map((e) => Offset(e['dx'], e['dy'])).toList();
  }

  // Save all lines
  Future<void> saveDrawingLines(int fileId, List<List<DrawnLine>> pages) async {
    final db = await database;
    await db.delete('drawings', where: 'file_id = ?', whereArgs: [fileId]);

    for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      for (DrawnLine line in pages[pageIndex]) {
        await db.insert('drawings', {
          'file_id': fileId,
          'page_number': pageIndex,
          'path_json': encodePath(line.path),
          'color': '#${line.color.value.toRadixString(16).padLeft(8, '0')}',
          'stroke_width': line.width,
          'blend_mode': line.blendMode.toString(),
        });
      }
    }
  }

  // Load drawing by fileId
  Future<List<List<DrawnLine>>> loadDrawingLines(int fileId) async {
    final db = await database;
    final result = await db.query(
      'drawings',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );

    // Group by page
    Map<int, List<DrawnLine>> pageMap = {};
    for (var row in result) {
      int page = row['page_number'] as int;
      pageMap.putIfAbsent(page, () => []);

      final color =
          Color(int.parse((row['color'] as String).substring(1), radix: 16));
      final path = decodePath(row['path_json'] as String);
      final strokeWidth = row['stroke_width'] as double;
      final blendModeStr = row['blend_mode'] as String;
      final blendMode = BlendMode.values.firstWhere(
        (e) => e.toString() == blendModeStr,
        orElse: () => BlendMode.srcOver,
      );

      pageMap[page]!.add(DrawnLine(path, color, strokeWidth, blendMode));
    }

    // Return sorted pages
    final pages = List<List<DrawnLine>>.generate(
      (pageMap.keys.isEmpty)
          ? 1
          : (pageMap.keys.reduce((a, b) => a > b ? a : b) + 1),
      (index) => pageMap[index] ?? [],
    );

    return pages;
  }
}
