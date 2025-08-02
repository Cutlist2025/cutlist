// lib/widgets/add_item_dialog.dart
import 'package:flutter/material.dart';
import '../dialogs/common_inputs.dart';
import '../dialogs/cupboard_form.dart';
import '../dialogs/table_form.dart';

class AddItemDialog extends StatefulWidget {
  final Future<void> Function(String itemType, Map<String, dynamic> inputs)
      onSave;

  AddItemDialog({required this.onSave});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  String selectedItem = 'Default';

  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final depthController = TextEditingController();

  final cupboardFormKey = GlobalKey<CupboardFormState>();

  @override
  void dispose() {
    lengthController.dispose();
    widthController.dispose();
    depthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedItem,
              items: const [
                DropdownMenuItem(value: 'Default', child: Text('Select Item')),
                DropdownMenuItem(value: 'Cupboard', child: Text('Cupboard')),
                DropdownMenuItem(value: 'Table', child: Text('Table')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedItem = value!;
                });
              },
            ),
            if (selectedItem == 'Cupboard' || selectedItem == 'Table')
              CommonInputs(
                lengthController: lengthController,
                widthController: widthController,
                depthController: depthController,
              ),
            if (selectedItem == 'Cupboard') CupboardForm(key: cupboardFormKey),
            if (selectedItem == 'Table') TableForm(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final baseData = {
              'type': selectedItem,
              'length': lengthController.text,
              'width': widthController.text,
              'depth': depthController.text,
            };

            if (selectedItem == 'Cupboard') {
              final cupboardData =
                  cupboardFormKey.currentState?.collectData() ?? {};
              widget.onSave(selectedItem, {...baseData, ...cupboardData});
            } else {
              widget.onSave(selectedItem, baseData);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
