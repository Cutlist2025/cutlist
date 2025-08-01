import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final Future<void> Function(String itemType, Map<String, dynamic> inputs)
      onSave;

  AddItemDialog({required this.onSave});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController depthController = TextEditingController();
  final TextEditingController slabsController = TextEditingController();
  final TextEditingController drawersController = TextEditingController();
  final TextEditingController sameSizeDrawerHeightController =
      TextEditingController();
  final Map<int, TextEditingController> drawerHeightControllers = {};

  final TextEditingController leftSlabsController = TextEditingController();
  final TextEditingController rightSlabsController = TextEditingController();

  String selectedItem = 'Default';
  String cupboardSplitOption = 'No Split';
  String? drawerSizeOption = 'Same Size';
  // int? customSplitValue = 0;
  int? customSplitValue = 0;

  String hasHorizontalSplit = 'No';
  String horizontalSplitPosition = 'Top';

  final TextEditingController topSplitHeightController =
      TextEditingController();
  final TextEditingController bottomSplitHeightController =
      TextEditingController();

  final Map<int, TextEditingController> customSlabsControllers = {};
  final Map<int, TextEditingController> customDrawersControllers = {};
  final Map<int, String> customDrawerSizeOptions = {};
  final Map<int, TextEditingController> customSameHeightControllers = {};
  final Map<int, Map<int, TextEditingController>>
      customIndividualHeightControllers = {};

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
              items: [
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
            SizedBox(height: 8),
            if (selectedItem == 'Cupboard' || selectedItem == 'Table') ...[
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
            if (selectedItem == 'Cupboard') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Horizontal Split?'),
                  Radio<String>(
                    value: 'No',
                    groupValue: hasHorizontalSplit,
                    onChanged: (value) {
                      setState(() {
                        hasHorizontalSplit = value!;
                      });
                    },
                  ),
                  Text('No'),
                  Radio<String>(
                    value: 'Yes',
                    groupValue: hasHorizontalSplit,
                    onChanged: (value) {
                      setState(() {
                        hasHorizontalSplit = value!;
                      });
                    },
                  ),
                  Text('Yes'),
                ],
              ),
              if (hasHorizontalSplit == 'Yes') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Radio<String>(
                      value: 'Top',
                      groupValue: horizontalSplitPosition,
                      onChanged: (value) {
                        setState(() {
                          horizontalSplitPosition = value!;
                        });
                      },
                    ),
                    Text('Top'),
                    Radio<String>(
                      value: 'Bottom',
                      groupValue: horizontalSplitPosition,
                      onChanged: (value) {
                        setState(() {
                          horizontalSplitPosition = value!;
                        });
                      },
                    ),
                    Text('Bottom'),
                    Radio<String>(
                      value: 'Both',
                      groupValue: horizontalSplitPosition,
                      onChanged: (value) {
                        setState(() {
                          horizontalSplitPosition = value!;
                        });
                      },
                    ),
                    Text('Both'),
                  ],
                ),
                if (horizontalSplitPosition == 'Top')
                  TextField(
                    controller: topSplitHeightController,
                    decoration: InputDecoration(labelText: 'Height from Top'),
                    keyboardType: TextInputType.number,
                  ),
                if (horizontalSplitPosition == 'Bottom')
                  TextField(
                    controller: bottomSplitHeightController,
                    decoration:
                        InputDecoration(labelText: 'Height from Bottom'),
                    keyboardType: TextInputType.number,
                  ),
                if (horizontalSplitPosition == 'Both') ...[
                  TextField(
                    controller: topSplitHeightController,
                    decoration: InputDecoration(labelText: 'Top Height'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: bottomSplitHeightController,
                    decoration: InputDecoration(labelText: 'Bottom Height'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Vertical Split?'),
                  Radio<String>(
                    value: 'No Split',
                    groupValue: cupboardSplitOption,
                    onChanged: (value) {
                      setState(() {
                        cupboardSplitOption = value!;
                      });
                    },
                  ),
                  Text('No Split'),
                  Radio<String>(
                    value: 'Split Half',
                    groupValue: cupboardSplitOption,
                    onChanged: (value) {
                      setState(() {
                        cupboardSplitOption = value!;
                      });
                    },
                  ),
                  Text('Split Half'),
                  Radio<String>(
                    value: 'Custom Split',
                    groupValue: cupboardSplitOption,
                    onChanged: (value) {
                      setState(() {
                        cupboardSplitOption = value!;
                      });
                    },
                  ),
                  Text('Custom Split'),
                ],
              ),
              if (cupboardSplitOption == 'No Split') ...[
                TextField(
                  controller: slabsController,
                  decoration: InputDecoration(labelText: 'Number of Slabs'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: drawersController,
                  decoration: InputDecoration(labelText: 'Number of Drawers'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      drawerHeightControllers.clear();
                      final numDrawers = int.tryParse(value) ?? 0;
                      for (int i = 0; i < numDrawers; i++) {
                        drawerHeightControllers[i] = TextEditingController();
                      }
                    });
                  },
                ),
                if ((int.tryParse(drawersController.text) ?? 0) > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Radio<String>(
                        value: 'Same Size',
                        groupValue: drawerSizeOption,
                        onChanged: (value) {
                          setState(() {
                            drawerSizeOption = value!;
                          });
                        },
                      ),
                      Text('Same Size'),
                      Radio<String>(
                        value: 'Different Size',
                        groupValue: drawerSizeOption,
                        onChanged: (value) {
                          setState(() {
                            drawerSizeOption = value!;
                          });
                        },
                      ),
                      Text('Different Size'),
                    ],
                  ),
                  if (drawerSizeOption == 'Same Size')
                    TextField(
                      controller: sameSizeDrawerHeightController,
                      decoration:
                          InputDecoration(labelText: 'Drawer Pack Height'),
                      keyboardType: TextInputType.number,
                    ),
                  if (drawerSizeOption == 'Different Size')
                    ...List.generate(
                      drawerHeightControllers.length,
                      (index) => TextField(
                        controller: drawerHeightControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Height of Drawer ${index + 1}'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ],
              if (cupboardSplitOption == 'Split Half') ...[
                Text("Left Side"),
                TextField(
                  controller: leftSlabsController,
                  decoration: InputDecoration(labelText: 'Left Side Slabs'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: drawersController,
                  decoration: InputDecoration(labelText: 'Left Side Drawers'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                Text("Right Side"),
                TextField(
                  controller: rightSlabsController,
                  decoration: InputDecoration(labelText: 'Right Side Slabs'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Right Side Drawers'),
                  keyboardType: TextInputType.number,
                ),
              ],
              if (cupboardSplitOption == 'Custom Split') ...[
                DropdownButton<int>(
                  value: customSplitValue,
                  hint: Text('Select Custom Split (e.g., 3/10 from left)'),
                  items: List.generate(
                    9,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}/10 from left'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      customSplitValue = value;
                      for (int i = 0; i < 2; i++) {
                        customSlabsControllers[i] = TextEditingController();
                        customDrawersControllers[i] = TextEditingController();
                        customDrawerSizeOptions[i] = 'Same Size';
                        customSameHeightControllers[i] =
                            TextEditingController();
                        customIndividualHeightControllers[i] = {};
                      }
                    });
                  },
                ),
                if (customSplitValue != null)
                  ...List.generate(2, (index) {
                    String label = index == 0
                        ? 'Left Section (${customSplitValue}/10)'
                        : 'Right Section (${10 - customSplitValue!}/10)';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label),
                        TextField(
                          controller: customSlabsControllers[index],
                          decoration: InputDecoration(labelText: 'Slabs'),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: customDrawersControllers[index],
                          decoration: InputDecoration(labelText: 'Drawers'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              final numDrawers = int.tryParse(value) ?? 0;
                              customIndividualHeightControllers[index]!.clear();
                              for (int i = 0; i < numDrawers; i++) {
                                customIndividualHeightControllers[index]![i] =
                                    TextEditingController();
                              }
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Radio<String>(
                              value: 'Same Size',
                              groupValue: customDrawerSizeOptions[index],
                              onChanged: (value) {
                                setState(() {
                                  customDrawerSizeOptions[index] = value!;
                                });
                              },
                            ),
                            Text('Same Size'),
                            Radio<String>(
                              value: 'Different Size',
                              groupValue: customDrawerSizeOptions[index],
                              onChanged: (value) {
                                setState(() {
                                  customDrawerSizeOptions[index] = value!;
                                });
                              },
                            ),
                            Text('Different Size'),
                          ],
                        ),
                        if (customDrawerSizeOptions[index] == 'Same Size' &&
                            (int.tryParse(customDrawersControllers[index]!
                                        .text) ??
                                    0) >
                                0)
                          TextField(
                            controller: customSameHeightControllers[index],
                            decoration: InputDecoration(
                                labelText: 'Drawer Pack Height'),
                            keyboardType: TextInputType.number,
                          ),
                        if (customDrawerSizeOptions[index] == 'Different Size')
                          ...List.generate(
                            customIndividualHeightControllers[index]!.length,
                            (i) => TextField(
                              controller:
                                  customIndividualHeightControllers[index]![i],
                              decoration: InputDecoration(
                                  labelText: 'Height of Drawer ${i + 1}'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                      ],
                    );
                  }),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final Map<String, dynamic> data = {
              'type': selectedItem,
              'length':
                  lengthController.text.isNotEmpty ? lengthController.text : '',
              'width':
                  widthController.text.isNotEmpty ? widthController.text : '',
              'depth':
                  depthController.text.isNotEmpty ? depthController.text : '',
              'horizontalSplit': hasHorizontalSplit,
              'horizontalSplitPosition': horizontalSplitPosition,
              'topSplitHeight': topSplitHeightController.text.isNotEmpty
                  ? topSplitHeightController.text
                  : '',
              'bottomSplitHeight': bottomSplitHeightController.text.isNotEmpty
                  ? bottomSplitHeightController.text
                  : '',
              'verticalSplit': cupboardSplitOption,
              'slabs':
                  slabsController.text.isNotEmpty ? slabsController.text : '',
              'drawers': drawersController.text.isNotEmpty
                  ? drawersController.text
                  : '',
              'drawerSizeOption': drawerSizeOption,
              'drawerHeights': drawerSizeOption == 'Different Size'
                  ? drawerHeightControllers.map(
                      (i, c) => MapEntry(i, c.text.isNotEmpty ? c.text : ''))
                  : (sameSizeDrawerHeightController.text.isNotEmpty
                      ? sameSizeDrawerHeightController.text
                      : ''),
              'customSplitValue': customSplitValue?.toString() ?? '',
              'customSections': List.generate(
                  2,
                  (i) => {
                        'slabs':
                            customSlabsControllers[i]?.text.isNotEmpty == true
                                ? customSlabsControllers[i]!.text
                                : '',
                        'drawers':
                            customDrawersControllers[i]?.text.isNotEmpty == true
                                ? customDrawersControllers[i]!.text
                                : '',
                        'drawerSizeOption': customDrawerSizeOptions[i] ?? '',
                        'drawerHeights': customDrawerSizeOptions[i] ==
                                'Different Size'
                            ? customIndividualHeightControllers[i]!.map((j,
                                    c) =>
                                MapEntry(j, c.text.isNotEmpty ? c.text : ''))
                            : (customSameHeightControllers[i]
                                        ?.text
                                        .isNotEmpty ==
                                    true
                                ? customSameHeightControllers[i]!.text
                                : ''),
                      }),
            };

            widget.onSave(selectedItem, data);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    lengthController.dispose();
    widthController.dispose();
    depthController.dispose();
    slabsController.dispose();
    drawersController.dispose();
    sameSizeDrawerHeightController.dispose();
    leftSlabsController.dispose();
    rightSlabsController.dispose();
    super.dispose();
  }
}
