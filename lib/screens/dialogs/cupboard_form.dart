// lib/widgets/forms/cupboard_form.dart
import 'package:flutter/material.dart';

class CupboardForm extends StatefulWidget {
  CupboardForm({Key? key}) : super(key: key);

  @override
  CupboardFormState createState() => CupboardFormState();
}

class CupboardFormState extends State<CupboardForm> {
  final TextEditingController slabsController = TextEditingController();
  final TextEditingController drawersController = TextEditingController();
  final TextEditingController sameSizeDrawerHeightController =
      TextEditingController();
  final Map<int, TextEditingController> drawerHeightControllers = {};
  final TextEditingController leftSlabsController = TextEditingController();
  final TextEditingController rightSlabsController = TextEditingController();
  final TextEditingController topSplitHeightController =
      TextEditingController();
  final TextEditingController bottomSplitHeightController =
      TextEditingController();

  String hasHorizontalSplit = 'No';
  String horizontalSplitPosition = 'Top';
  String cupboardSplitOption = 'No Split';
  String? drawerSizeOption = 'Same Size';
  int? customSplitValue;

  final Map<int, TextEditingController> customSlabsControllers = {};
  final Map<int, TextEditingController> customDrawersControllers = {};
  final Map<int, String> customDrawerSizeOptions = {};
  final Map<int, TextEditingController> customSameHeightControllers = {};
  final Map<int, Map<int, TextEditingController>>
      customIndividualHeightControllers = {};

  Map<String, dynamic> collectData() {
    return {
      'horizontalSplit': hasHorizontalSplit,
      'horizontalSplitPosition': horizontalSplitPosition,
      'topSplitHeight': topSplitHeightController.text,
      'bottomSplitHeight': bottomSplitHeightController.text,
      'verticalSplit': cupboardSplitOption,
      'slabs': slabsController.text,
      'drawers': drawersController.text,
      'drawerSizeOption': drawerSizeOption,
      'drawerHeights': drawerSizeOption == 'Different Size'
          ? drawerHeightControllers.map((i, c) => MapEntry(i, c.text))
          : sameSizeDrawerHeightController.text,
      'customSplitValue': customSplitValue?.toString() ?? '',
      'customSections': List.generate(
          2,
          (i) => {
                'slabs': customSlabsControllers[i]?.text ?? '',
                'drawers': customDrawersControllers[i]?.text ?? '',
                'drawerSizeOption': customDrawerSizeOptions[i] ?? '',
                'drawerHeights': customDrawerSizeOptions[i] == 'Different Size'
                    ? customIndividualHeightControllers[i]
                            ?.map((j, c) => MapEntry(j, c.text)) ??
                        {}
                    : customSameHeightControllers[i]?.text ?? '',
              }),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Text('Horizontal Split?'),
        Radio(
            value: 'No',
            groupValue: hasHorizontalSplit,
            onChanged: (val) => setState(() => hasHorizontalSplit = val!)),
        Text('No'),
        Radio(
            value: 'Yes',
            groupValue: hasHorizontalSplit,
            onChanged: (val) => setState(() => hasHorizontalSplit = val!)),
        Text('Yes')
      ]),
      if (hasHorizontalSplit == 'Yes') ...[
        Row(children: [
          Radio(
              value: 'Top',
              groupValue: horizontalSplitPosition,
              onChanged: (val) =>
                  setState(() => horizontalSplitPosition = val!)),
          Text('Top'),
          Radio(
              value: 'Bottom',
              groupValue: horizontalSplitPosition,
              onChanged: (val) =>
                  setState(() => horizontalSplitPosition = val!)),
          Text('Bottom'),
          Radio(
              value: 'Both',
              groupValue: horizontalSplitPosition,
              onChanged: (val) =>
                  setState(() => horizontalSplitPosition = val!)),
          Text('Both')
        ]),
        if (horizontalSplitPosition == 'Top')
          TextField(
              controller: topSplitHeightController,
              decoration: InputDecoration(labelText: 'Height from Top'),
              keyboardType: TextInputType.number),
        if (horizontalSplitPosition == 'Bottom')
          TextField(
              controller: bottomSplitHeightController,
              decoration: InputDecoration(labelText: 'Height from Bottom'),
              keyboardType: TextInputType.number),
        if (horizontalSplitPosition == 'Both') ...[
          TextField(
              controller: topSplitHeightController,
              decoration: InputDecoration(labelText: 'Top Height'),
              keyboardType: TextInputType.number),
          TextField(
              controller: bottomSplitHeightController,
              decoration: InputDecoration(labelText: 'Bottom Height'),
              keyboardType: TextInputType.number),
        ],
      ],
      Row(children: [
        Text('Vertical Split?'),
        Radio(
            value: 'No Split',
            groupValue: cupboardSplitOption,
            onChanged: (val) => setState(() => cupboardSplitOption = val!)),
        Text('No Split'),
        Radio(
            value: 'Split Half',
            groupValue: cupboardSplitOption,
            onChanged: (val) => setState(() => cupboardSplitOption = val!)),
        Text('Split Half'),
        Radio(
            value: 'Custom Split',
            groupValue: cupboardSplitOption,
            onChanged: (val) => setState(() => cupboardSplitOption = val!)),
        Text('Custom Split')
      ]),
      if (cupboardSplitOption == 'No Split') ...[
        TextField(
            controller: slabsController,
            decoration: InputDecoration(labelText: 'Number of Slabs'),
            keyboardType: TextInputType.number),
        TextField(
            controller: drawersController,
            decoration: InputDecoration(labelText: 'Number of Drawers'),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {
                drawerHeightControllers.clear();
                final num = int.tryParse(val) ?? 0;
                for (int i = 0; i < num; i++) {
                  drawerHeightControllers[i] = TextEditingController();
                }
              });
            }),
        Row(children: [
          Radio(
              value: 'Same Size',
              groupValue: drawerSizeOption,
              onChanged: (val) => setState(() => drawerSizeOption = val!)),
          Text('Same Size'),
          Radio(
              value: 'Different Size',
              groupValue: drawerSizeOption,
              onChanged: (val) => setState(() => drawerSizeOption = val!)),
          Text('Different Size')
        ]),
        if (drawerSizeOption == 'Same Size')
          TextField(
              controller: sameSizeDrawerHeightController,
              decoration: InputDecoration(labelText: 'Drawer Pack Height'),
              keyboardType: TextInputType.number),
        if (drawerSizeOption == 'Different Size')
          ...drawerHeightControllers.entries.map((entry) => TextField(
              controller: entry.value,
              decoration:
                  InputDecoration(labelText: 'Drawer ${entry.key + 1} Height'),
              keyboardType: TextInputType.number))
      ],
      if (cupboardSplitOption == 'Split Half') ...[
        ...List.generate(
          2,
          (i) => Column(children: [
            Text(i == 0 ? 'Left Section (5/10)' : 'Right Section (5/10)'),
            TextField(
                controller: customSlabsControllers.putIfAbsent(
                    i, () => TextEditingController()),
                decoration: InputDecoration(labelText: 'Slabs'),
                keyboardType: TextInputType.number),
            TextField(
                controller: customDrawersControllers.putIfAbsent(
                    i, () => TextEditingController()),
                decoration: InputDecoration(labelText: 'Drawers'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {
                    final num = int.tryParse(val) ?? 0;
                    customIndividualHeightControllers[i] = {};
                    for (int j = 0; j < num; j++) {
                      customIndividualHeightControllers[i]![j] =
                          TextEditingController();
                    }
                  });
                }),
            Row(children: [
              Radio(
                  value: 'Same Size',
                  groupValue: customDrawerSizeOptions[i],
                  onChanged: (val) =>
                      setState(() => customDrawerSizeOptions[i] = val!)),
              Text('Same Size'),
              Radio(
                  value: 'Different Size',
                  groupValue: customDrawerSizeOptions[i],
                  onChanged: (val) =>
                      setState(() => customDrawerSizeOptions[i] = val!)),
              Text('Different Size'),
            ]),
            if (customDrawerSizeOptions[i] == 'Same Size')
              TextField(
                  controller: customSameHeightControllers.putIfAbsent(
                      i, () => TextEditingController()),
                  decoration: InputDecoration(labelText: 'Drawer Pack Height'),
                  keyboardType: TextInputType.number),
            if (customDrawerSizeOptions[i] == 'Different Size')
              ...customIndividualHeightControllers[i]!.entries.map(
                    (e) => TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                            labelText: 'Drawer ${e.key + 1} Height'),
                        keyboardType: TextInputType.number),
                  )
          ]),
        )
      ],
      if (cupboardSplitOption == 'Custom Split') ...[
        DropdownButton<int>(
          value: customSplitValue,
          hint: Text('Select Custom Split (e.g. 3/10)'),
          items: List.generate(
              9,
              (i) =>
                  DropdownMenuItem(value: i + 1, child: Text('${i + 1}/10'))),
          onChanged: (val) {
            setState(() {
              customSplitValue = val;
              for (int i = 0; i < 2; i++) {
                customSlabsControllers[i] = TextEditingController();
                customDrawersControllers[i] = TextEditingController();
                customDrawerSizeOptions[i] = 'Same Size';
                customSameHeightControllers[i] = TextEditingController();
                customIndividualHeightControllers[i] = {};
              }
            });
          },
        ),
        if (customSplitValue != null)
          ...List.generate(
              2,
              (i) => Column(children: [
                    Text(i == 0
                        ? 'Left Section (${customSplitValue}/10)'
                        : 'Right Section (${10 - customSplitValue!}/10)'),
                    TextField(
                        controller: customSlabsControllers[i],
                        decoration: InputDecoration(labelText: 'Slabs'),
                        keyboardType: TextInputType.number),
                    TextField(
                        controller: customDrawersControllers[i],
                        decoration: InputDecoration(labelText: 'Drawers'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            final num = int.tryParse(val) ?? 0;
                            customIndividualHeightControllers[i]!.clear();
                            for (int j = 0; j < num; j++) {
                              customIndividualHeightControllers[i]![j] =
                                  TextEditingController();
                            }
                          });
                        }),
                    Row(children: [
                      Radio(
                          value: 'Same Size',
                          groupValue: customDrawerSizeOptions[i],
                          onChanged: (val) => setState(
                              () => customDrawerSizeOptions[i] = val!)),
                      Text('Same Size'),
                      Radio(
                          value: 'Different Size',
                          groupValue: customDrawerSizeOptions[i],
                          onChanged: (val) => setState(
                              () => customDrawerSizeOptions[i] = val!)),
                      Text('Different Size')
                    ]),
                    if (customDrawerSizeOptions[i] == 'Same Size')
                      TextField(
                          controller: customSameHeightControllers[i],
                          decoration:
                              InputDecoration(labelText: 'Drawer Pack Height'),
                          keyboardType: TextInputType.number),
                    if (customDrawerSizeOptions[i] == 'Different Size')
                      ...customIndividualHeightControllers[i]!.entries.map(
                          (e) => TextField(
                              controller: e.value,
                              decoration: InputDecoration(
                                  labelText: 'Drawer ${e.key + 1} Height'),
                              keyboardType: TextInputType.number))
                  ])),
      ]
    ]);
  }

  @override
  void dispose() {
    slabsController.dispose();
    drawersController.dispose();
    sameSizeDrawerHeightController.dispose();
    leftSlabsController.dispose();
    rightSlabsController.dispose();
    topSplitHeightController.dispose();
    bottomSplitHeightController.dispose();
    super.dispose();
  }
}
