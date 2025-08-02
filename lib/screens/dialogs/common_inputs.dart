import 'package:flutter/material.dart';

class CommonInputs extends StatelessWidget {
  final TextEditingController lengthController;
  final TextEditingController widthController;
  final TextEditingController depthController;

  CommonInputs({
    required this.lengthController,
    required this.widthController,
    required this.depthController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: lengthController,
          decoration: InputDecoration(labelText: 'Length'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        TextField(
          controller: widthController,
          decoration: InputDecoration(labelText: 'Width'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        TextField(
          controller: depthController,
          decoration: InputDecoration(labelText: 'Depth'),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
