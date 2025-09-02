import '../../database_helper.dart';
import '../../formulas/cupdoard.dart';

const int boardThickness = 18;

class ItemHandler {
  const ItemHandler._();

  /// ✅ Safe parsers
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim()) ?? defaultValue;
    }
    return defaultValue;
  }

  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == "yes" || value.toLowerCase() == "true";
    }
    return false;
  }

  static Future<void> handleSave(
      String itemType, Map<String, dynamic> inputs, int fileId) async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> cupboardComponents = [];
    // print(inputs);

    if (itemType == 'Cupboard') {
      final length = parseInt(inputs['length']);
      final width = parseInt(inputs['width']);
      final depth = parseInt(inputs['depth']);

      // ✅ Base cupboard panels
      cupboardComponents.addAll([
        {
          'type': 'Cupboard',
          'length': length,
          'width': width,
          'depth': depth,
          'lengthSize': sideHeight(length, width, depth),
          'widthSize': sideWidht(length, width, depth),
          'qty': 2,
          'panel': 'Sides'
        },
        {
          'type': 'Cupboard',
          'length': length,
          'width': width,
          'depth': depth,
          'lengthSize': topBottomHieght(length, width, depth),
          'widthSize': topBottomWidth(length, width, depth),
          'qty': 2,
          'panel': 'Top/Bottom'
        },
        {
          'type': 'Cupboard',
          'length': length,
          'width': width,
          'depth': depth,
          'lengthSize': backHeight(length, width, depth),
          'widthSize': backWidth(length, width, depth),
          'qty': 1,
          'panel': 'Back'
        },
        {
          'type': 'Cupboard',
          'length': length,
          'width': width,
          'depth': depth,
          'lengthSize': doorHeight(length, width, depth),
          'widthSize': doorWidth(length, width, depth),
          'qty': 1,
          'panel': 'Door'
        },
      ]);

      // ✅ Step 1: Horizontal split
      List<Map<String, dynamic>> sections = [];
      if (parseBool(inputs['horizontalSplit'])) {
        final topH = parseInt(inputs['topSplitHeight']);
        final botH = parseInt(inputs['bottomSplitHeight']);

        if (inputs['horizontalSplitPosition'] == 'Top') {
          sections = [
            {'name': 'Top Section', 'height': topH},
            {'name': 'Bottom Section', 'height': length - topH}
          ];
        } else if (inputs['horizontalSplitPosition'] == 'Bottom') {
          sections = [
            {'name': 'Top Section', 'height': length - botH},
            {'name': 'Bottom Section', 'height': botH}
          ];
        } else if (inputs['horizontalSplitPosition'] == 'Both') {
          sections = [
            {'name': 'Top Section', 'height': topH},
            {'name': 'Middle Section', 'height': length - (topH + botH)},
            {'name': 'Bottom Section', 'height': botH}
          ];
        }

        // ✅ Add horizontal dividers
        for (int i = 0; i < sections.length - 1; i++) {
          cupboardComponents.add({
            'type': 'Cupboard',
            'length': boardThickness,
            'width': width,
            'depth': depth,
            'lengthSize': width.toString(),
            'widthSize': (depth - boardThickness).toString(),
            'qty': 1,
            'panel': 'Horizontal Divider'
          });
        }
      } else {
        sections = [
          {'name': 'Full Cupboard', 'height': length}
        ];
      }

      // ✅ Step 2: Vertical split
      for (int i = 0; i < sections.length; i++) {
        var sec = sections[i];
        int secHeight = sec['height'];
        int totalWidth = width;

        // ✅ Adjust vertical divider height for horizontal dividers
        int horizontalDivAbove = i > 0 ? boardThickness : 0;
        int horizontalDivBelow = i < sections.length - 1 ? boardThickness : 0;
        int verticalDividerHeight =
            secHeight - horizontalDivAbove - horizontalDivBelow;
        print(verticalDividerHeight);
        print(secHeight);

        if (inputs['verticalSplit'] == 'Custom Split') {
          int splitPos = parseInt(inputs['customSplitValue']);
          int leftWidth = totalWidth ~/ splitPos + (boardThickness ~/ 2);
          int rightWidth = totalWidth - leftWidth + (boardThickness ~/ 2);

          List customSections = inputs['customSections'] ?? [];

          if (customSections.isNotEmpty) {
            if (leftWidth > 0 && customSections.length > 0) {
              _addSlabsAndDrawers(cupboardComponents, customSections[0],
                  secHeight, leftWidth, depth);
            }
            if (rightWidth > 0 && customSections.length > 1) {
              _addSlabsAndDrawers(cupboardComponents, customSections[1],
                  secHeight, rightWidth, depth);
            }

            cupboardComponents.add({
              'type': 'Cupboard',
              'length': verticalDividerHeight,
              'width': boardThickness,
              'depth': depth,
              'lengthSize': verticalDividerHeight.toString(),
              'widthSize': boardThickness.toString(),
              'qty': 1,
              'panel': 'Vertical Divider'
            });
          }
        } else if (inputs['verticalSplit'] == 'Split Half') {
          int half = (totalWidth ~/ 2) + (boardThickness ~/ 2);
          List customSections = inputs['customSections'] ?? [];

          if (customSections.isNotEmpty) {
            if (customSections.length > 0) {
              _addSlabsAndDrawers(cupboardComponents, customSections[0],
                  secHeight, half, depth);
            }
            if (customSections.length > 1) {
              _addSlabsAndDrawers(cupboardComponents, customSections[1],
                  secHeight, half, depth);
            }
          }

          cupboardComponents.add({
            'type': 'Cupboard',
            'length': verticalDividerHeight,
            'width': boardThickness,
            'depth': depth,
            'lengthSize': splitHalfDividerHeight(secHeight),
            'widthSize': splitHalfDividerWidth(depth),
            'qty': 1,
            'panel': 'Vertical Divider'
          });
        } else {
          _addSlabsAndDrawers(
              cupboardComponents, inputs, secHeight, totalWidth, depth);
        }
      }

      // ✅ Save all components to DB
      for (var comp in cupboardComponents) {
        await dbHelper.insertCsvDataForFile(fileId, comp);
      }
    }
    // ✅ Table case
    else if (itemType == 'Table') {
      await dbHelper.insertCsvDataForFile(fileId, {
        'type': itemType,
        'length': parseInt(inputs['length']),
        'width': parseInt(inputs['width']),
        'depth': parseInt(inputs['depth']),
        'lengthSize': null,
        'widthSize': null,
        'qty': 1,
        'panel': null,
      });
    }
  }

  /// 🔹 Slabs + Drawers (per section, width-sensitive!)
  static void _addSlabsAndDrawers(
      List<Map<String, dynamic>> comps,
      Map<String, dynamic> sectionInputs,
      int secHeight,
      int secWidth,
      int depth) {
    int slabs = parseInt(sectionInputs['slabs'], defaultValue: 0);
    int drawers = parseInt(sectionInputs['drawers']);
    int drawerHeight = parseInt(sectionInputs['drawerHeights']);

    if (slabs > 0) {
      comps.add({
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': shelfHeight(secHeight, secWidth, depth),
        'widthSize': shelfWidth(secHeight, secWidth, depth),
        'qty': slabs,
        'panel': 'Shelves'
      });
    }

    if (drawers > 0) {
      comps.addAll(_drawerComponents(
          sectionInputs, drawers, drawerHeight, secHeight, secWidth, depth));
    }
  }

  /// 🔹 Drawer generator
  static List<Map<String, dynamic>> _drawerComponents(
      Map<String, dynamic> inputs,
      int drawers,
      int drawerHeight,
      int secHeight,
      int secWidth,
      int depth) {
    return [
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': drawerPackTopHeight(secHeight, secWidth, depth),
        'widthSize': drawerPackTopWidth(secHeight, secWidth, depth),
        'qty': 1,
        'panel': 'Drawer Pack Top'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize':
            drawerPackFillerHeight(secHeight, secWidth, depth, drawerHeight),
        'widthSize': drawerPackFillerWidth(secHeight, secWidth, depth),
        'qty': 2,
        'panel': 'Drawer Pack Filler'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize':
            drawerPacksidesHeight(secHeight, secWidth, depth, drawerHeight),
        'widthSize': drawerPacksidesWidth(secHeight, secWidth, depth),
        'qty': 2,
        'panel': 'Drawer Pack Sides'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': drawerPackTopBottomHeight(secHeight, secWidth, depth),
        'widthSize': drawerPackTopBottomWidth(secHeight, secWidth, depth),
        'qty': 2,
        'panel': 'Drawer Pack Top/Bottom'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': drawerBaseHeight(secHeight, secWidth, depth),
        'widthSize': drawerBaseWidth(secHeight, secWidth, depth),
        'qty': drawers,
        'panel': 'Drawer Bases'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': drawerFrontBackHeight(secHeight, secWidth, depth),
        'widthSize': drawerFrontBackWidth(drawerHeight, drawers),
        'qty': 2 * drawers,
        'panel': 'Drawer Front/Back'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': drawerSidesHeight(secHeight, secWidth, depth),
        'widthSize': drawerSidesWidth(drawerHeight, drawers),
        'qty': 2 * drawers,
        'panel': 'Drawer Sides'
      },
      {
        'type': 'Cupboard',
        'length': secHeight,
        'width': secWidth,
        'depth': depth,
        'lengthSize': DrawerFrontsHeight(drawerHeight, drawers, depth),
        'widthSize': DrawerFrontsWidth(secWidth),
        'qty': drawers,
        'panel': 'Drawer Fronts'
      },
    ];
  }
}
