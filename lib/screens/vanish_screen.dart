import 'package:flutter/material.dart';
import 'folder_screen.dart'; // Import your target main screen

class VanishScreen extends StatefulWidget {
  @override
  _VanishScreenState createState() => _VanishScreenState();
}

class _VanishScreenState extends State<VanishScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FolderListScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add your logo here if you have an asset
                Image.asset('assets/logo.png', height: 120),

                // Or use an animated icon
                // Container(
                //   padding: EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.white10,
                //     borderRadius: BorderRadius.circular(100),
                //   ),
                //   child: Icon(
                //     Icons.architecture_rounded,
                //     color: Colors.amberAccent,
                //     size: 80,
                //   ),
                // ),
                // SizedBox(height: 24),
                Text(
                  "Cut List",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Craft Your Designs Effortlessly",
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
