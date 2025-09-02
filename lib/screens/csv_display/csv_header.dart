import 'package:flutter/material.dart';

class CsvHeader extends StatelessWidget {
  final List<dynamic> headers;

  CsvHeader({required this.headers});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: headers
            .map((header) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(header.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
