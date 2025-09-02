import 'dart:convert';
import 'models/material_config.dart';
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

        await db.execute('''
  CREATE TABLE IF NOT EXISTS material_config (
    id INTEGER PRIMARY KEY,
    boardThickness INTEGER,
    shelfReduction INTEGER,
    doorReductionWidth INTEGER,
    doorReductionHeight INTEGER,
    drawerFillerWidth INTEGER
  )
''');

        // Insert default config on first launch
        await db.insert('material_config', {
          'id': 1,
          'boardThickness': 18,
          'shelfReduction': 30,
          'doorReductionWidth': 4,
          'doorReductionHeight': 4,
          'drawerFillerWidth': 35,
        });
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

  Future<int> updateCsvData(int id, Map<String, dynamic> newData) async {
    final db = await database;
    return await db.update(
      'csv_data',
      newData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ Delete a record by its id
  Future<int> deleteCsvData(int id) async {
    final db = await database;
    return await db.delete(
      'csv_data',
      where: 'id = ?',
      whereArgs: [id],
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

//  Material Config Methods

  Future<void> saveMaterialConfig(MaterialConfig config) async {
    final db = await database;
    await db.insert(
      'material_config',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MaterialConfig?> getMaterialConfig() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'material_config',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return MaterialConfig.fromMap(maps.first);
    }
    return null;
  }

  // Save extra pages (all extra pages together)
  Future<void> saveExtraPages(List<List<DrawnLine>> extraPages) async {
    final db = await database;

    // Convert all lines to JSON
    final pagesJson = jsonEncode(extraPages
        .map((page) => page.map((line) {
              return {
                'path': line.path.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
                'color':
                    '#${line.color.value.toRadixString(16).padLeft(8, '0')}',
                'width': line.width,
                'blendMode': line.blendMode.toString(),
              };
            }).toList())
        .toList());

    // Create table if not exists
    await db.execute('''
    CREATE TABLE IF NOT EXISTS extra_pages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pages_json TEXT
    )
  ''');

    // Clear previous extra pages
    await db.delete('extra_pages');

    // Insert new extra pages
    await db.insert('extra_pages', {'pages_json': pagesJson});
  }

// Load extra pages
  Future<List<List<DrawnLine>>> loadExtraPages() async {
    final db = await database;
    final result = await db.query('extra_pages', orderBy: 'id DESC', limit: 1);

    if (result.isEmpty) return [];

    final pagesJson = result.first['pages_json'] as String;
    final decoded = jsonDecode(pagesJson) as List<dynamic>;

    // Convert JSON back to DrawnLine
    final pages = decoded.map<List<DrawnLine>>((page) {
      final linesList = page as List<dynamic>;
      return linesList.map<DrawnLine>((lineMap) {
        final pathList = (lineMap['path'] as List<dynamic>)
            .map((p) => Offset(
                (p['dx'] as num).toDouble(), (p['dy'] as num).toDouble()))
            .toList();

        final color = Color(
            int.parse((lineMap['color'] as String).substring(1), radix: 16));
        final width = (lineMap['width'] as num).toDouble();
        final blendMode = BlendMode.values.firstWhere(
            (e) => e.toString() == (lineMap['blendMode'] as String),
            orElse: () => BlendMode.srcOver);

        return DrawnLine(pathList, color, width, blendMode);
      }).toList();
    }).toList();

    return pages;
  }
}
