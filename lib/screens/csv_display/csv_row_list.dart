import 'package:flutter/material.dart';

class CsvRowList extends StatelessWidget {
  final List<List<dynamic>> rows;
  final double rowHeight;

  CsvRowList({required this.rows, required this.rowHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (rows.length <= 10 ? rows.length * rowHeight : 10 * rowHeight)
          .toDouble(),
      child: SingleChildScrollView(
        child: Column(
          children: rows
              .map(
                (row) => Row(
                  children: row
                      .map((data) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(data.toString()),
                            ),
                          ))
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
