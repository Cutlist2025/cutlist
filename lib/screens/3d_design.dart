import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class CupboardScreen extends StatefulWidget {
  @override
  _CupboardScreenState createState() => _CupboardScreenState();
}

class _CupboardScreenState extends State<CupboardScreen> {
  late double _angleX;
  late double _angleY;
  double _length = 180; // Default length
  double _width = 100; // Default width
  double _height = 50; // Default height

  @override
  void initState() {
    super.initState();
    _angleX = 0;
    _angleY = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("3D Cupboard Design")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Input fields for dimensions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Length"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _length = double.tryParse(value) ?? 180;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Width"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _width = double.tryParse(value) ?? 100;
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Height"),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _height = double.tryParse(value) ?? 50;
                      });
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildViewButton("Front", 0, 0),
                _buildViewButton("Side", 90, 0),
                _buildViewButton("Top", 0, 90),
              ],
            ),
            SizedBox(height: 20),
            // Display 3D views in a grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  child: CustomPaint(
                    size: Size(150, 150),
                    painter: CupboardPainter(_getViewAngles(index)[0],
                        _getViewAngles(index)[1], _length, _width, _height),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<double> _getViewAngles(int index) {
    switch (index) {
      case 0:
        return [0, 0]; // Front View
      case 1:
        return [90, 0]; // Side View
      case 2:
        return [0, 90]; // Top View
      case 3:
        return [0, 180]; // Back View
      case 4:
        return [180, 0]; // Bottom View
      case 5:
        return [45, 45]; // Rotated view
      default:
        return [0, 0];
    }
  }

  Widget _buildViewButton(String label, double angleX, double angleY) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _angleX = angleX;
          _angleY = angleY;
        });
      },
      child: Text(label),
    );
  }
}

class CupboardPainter extends CustomPainter {
  final double angleX;
  final double angleY;
  final double length;
  final double width;
  final double height;

  CupboardPainter(
      this.angleX, this.angleY, this.length, this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Define cupboard edges in 3D space based on user input dimensions
    final List<vector.Vector3> points = [
      vector.Vector3(-width / 2, -height / 2, 0),
      vector.Vector3(width / 2, -height / 2, 0),
      vector.Vector3(width / 2, height / 2, 0),
      vector.Vector3(-width / 2, height / 2, 0),
      vector.Vector3(-width / 2, -height / 2, 0),
      vector.Vector3(-width / 2, -height / 2, -length),
      vector.Vector3(width / 2, -height / 2, -length),
      vector.Vector3(width / 2, height / 2, -length),
      vector.Vector3(-width / 2, height / 2, -length),
      vector.Vector3(-width / 2, -height / 2, -length),
    ];

    // Apply 3D rotation transformations
    final matrix = _getRotationMatrix(angleX, angleY);
    for (int i = 0; i < points.length; i++) {
      points[i] = matrix.transform3(points[i]);
    }

    // Define face paints
    final frontFacePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final sideFacePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    final topFacePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    final backFacePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    final bottomFacePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    // Draw faces
    _drawFace(canvas, frontFacePaint, points, [0, 1, 2, 3]);
    _drawFace(canvas, sideFacePaint, points, [3, 2, 7, 8]);
    _drawFace(canvas, topFacePaint, points, [0, 3, 8, 5]);
    _drawFace(canvas, backFacePaint, points, [5, 6, 7, 8]);
    _drawFace(canvas, bottomFacePaint, points, [0, 1, 6, 5]);

    // Draw connecting edges
    for (int i = 0; i < 4; i++) {
      _drawLine(canvas, paint, points[i], points[i + 5]);
    }
  }

  vector.Matrix4 _getRotationMatrix(double angleX, double angleY) {
    final rotX = vector.Matrix4.rotationX(angleX);
    final rotY = vector.Matrix4.rotationY(angleY);
    return rotX * rotY;
  }

  void _drawFace(Canvas canvas, Paint paint, List<vector.Vector3> points,
      List<int> indices) {
    canvas.drawLine(
        Offset(points[indices[0]].x + 150, points[indices[0]].y + 150),
        Offset(points[indices[1]].x + 150, points[indices[1]].y + 150),
        paint);
    canvas.drawLine(
        Offset(points[indices[1]].x + 150, points[indices[1]].y + 150),
        Offset(points[indices[2]].x + 150, points[indices[2]].y + 150),
        paint);
    canvas.drawLine(
        Offset(points[indices[2]].x + 150, points[indices[2]].y + 150),
        Offset(points[indices[3]].x + 150, points[indices[3]].y + 150),
        paint);
    canvas.drawLine(
        Offset(points[indices[3]].x + 150, points[indices[3]].y + 150),
        Offset(points[indices[0]].x + 150, points[indices[0]].y + 150),
        paint);
  }

  void _drawLine(
      Canvas canvas, Paint paint, vector.Vector3 p1, vector.Vector3 p2) {
    canvas.drawLine(
        Offset(p1.x + 150, p1.y + 150), Offset(p2.x + 150, p2.y + 150), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
