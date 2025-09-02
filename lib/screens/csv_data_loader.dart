import 'package:path/path.dart';
import 'package:path/path.dart' as csvString;

import '../database_helper.dart';

class CsvDataLoader {
  /// Loads CSV rows for a given fileId
  static Future<List<List<dynamic>>> load(int fileId) async {
    try {
      // Fetch raw CSV string from database
      final csvString = await DatabaseHelper().fetchCsvDataForFile(fileId);

      if (csvString.trim().isEmpty) {
        return [];
      }

      // Split into rows
      final lines = csvString.csvString.split('\n');

      // Split each row into cells
      final rows = lines.map((line) => line.split(',')).toList();

      return rows;
    } catch (e) {
      print("Error loading CSV for fileId=$fileId: $e");
      return [];
    }
  }
}

extension on List<Map<String, dynamic>> {
  get csvString => null;

  trim() {}
}
