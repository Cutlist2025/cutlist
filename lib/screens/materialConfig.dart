import 'package:cuttinglist/models/material_config.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart';
// import '../models/material_config_model.dart';

class MaterialConfigScreen extends StatefulWidget {
  @override
  _MaterialConfigScreenState createState() => _MaterialConfigScreenState();
}

class _MaterialConfigScreenState extends State<MaterialConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boardThicknessController = TextEditingController();
  final _shelfReductionController = TextEditingController();
  final _doorReductionWidthController = TextEditingController();
  final _doorReductionHeightController = TextEditingController();
  final _drawerFillerWidthController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    final config = await DatabaseHelper().getMaterialConfig();
    if (config != null) {
      _boardThicknessController.text = config.boardThickness.toString();
      _shelfReductionController.text = config.shelfReduction.toString();
      _doorReductionWidthController.text = config.doorReductionWidth.toString();
      _doorReductionHeightController.text =
          config.doorReductionHeight.toString();
      _drawerFillerWidthController.text = config.drawerFillerWidth.toString();
    } else {
      // Set default values
      _boardThicknessController.text = '18';
      _shelfReductionController.text = '30';
      _doorReductionWidthController.text = '4';
      _doorReductionHeightController.text = '4';
      _drawerFillerWidthController.text = '35';
    }
    setState(() => _loading = false);
  }

  void _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      final config = MaterialConfig(
        boardThickness: int.parse(_boardThicknessController.text),
        shelfReduction: int.parse(_shelfReductionController.text),
        doorReductionWidth: int.parse(_doorReductionWidthController.text),
        doorReductionHeight: int.parse(_doorReductionHeightController.text),
        drawerFillerWidth: int.parse(_drawerFillerWidthController.text),
      );

      await DatabaseHelper().saveMaterialConfig(config);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configuration saved successfully!')),
      );
    }
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter $label';
          }
          if (int.tryParse(value) == null) {
            return 'Must be a valid number';
          }
          return null;
        },
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _boardThicknessController.text = '18';
      _shelfReductionController.text = '30';
      _doorReductionWidthController.text = '4';
      _doorReductionHeightController.text = '4';
      _drawerFillerWidthController.text = '35';
    });
  }

  @override
  void dispose() {
    _boardThicknessController.dispose();
    _shelfReductionController.dispose();
    _doorReductionWidthController.dispose();
    _doorReductionHeightController.dispose();
    _drawerFillerWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Material Configuration')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildNumberField(
                        'Board Thickness', _boardThicknessController),
                    _buildNumberField(
                        'Shelf Reduction', _shelfReductionController),
                    _buildNumberField(
                        'Door Reduction Width', _doorReductionWidthController),
                    _buildNumberField('Door Reduction Height',
                        _doorReductionHeightController),
                    _buildNumberField(
                        'Drawer Filler Width', _drawerFillerWidthController),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveConfig,
                      child: Text('Save Configuration'),
                    ),
                    TextButton(
                      onPressed: _resetToDefaults,
                      child: Text('Reset to Defaults'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
