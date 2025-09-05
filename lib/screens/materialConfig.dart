import 'package:cuttinglist/models/material_config.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart';

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
      _resetToDefaults();
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
        SnackBar(
          content: Text('✅ Configuration saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildNumberField(
      String label, IconData icon, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: InputBorder.none,
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
      appBar: AppBar(
        title: Text('Material Configuration'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildNumberField('Board Thickness', Icons.layers,
                        _boardThicknessController),
                    _buildNumberField('Shelf Reduction',
                        Icons.dashboard_customize, _shelfReductionController),
                    _buildNumberField('Door Reduction Width',
                        Icons.width_normal, _doorReductionWidthController),
                    _buildNumberField('Door Reduction Height', Icons.height,
                        _doorReductionHeightController),
                    _buildNumberField('Drawer Filler Width', Icons.view_agenda,
                        _drawerFillerWidthController),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _saveConfig,
                      icon: Icon(Icons.save),
                      label: Text('Save Configuration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _resetToDefaults,
                      icon: Icon(Icons.refresh),
                      label: Text('Reset to Defaults'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.blueAccent),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
