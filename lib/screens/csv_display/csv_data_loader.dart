import '../../database_helper.dart';

class CsvDataLoader {
  static Future<List<List<dynamic>>> load(int fileId) async {
    final dbHelper = DatabaseHelper();
    final rows = await dbHelper.fetchCsvDataForFile(fileId);

    return [
      ["Panel", "Length", "Width", "Number"],
      ...rows.map((row) => [
            row['panel'],
            row['lengthSize'],
            row['widthSize'],
            row['qty'],
          ])
    ];
  }
}
