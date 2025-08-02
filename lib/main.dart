import 'package:cuttinglist/screens/materialConfig.dart';
import 'package:flutter/material.dart';
import 'package:cuttinglist/screens/only_canva.dart';
import 'package:cuttinglist/screens/drawingboard_screen.dart';
import 'package:cuttinglist/screens/folder_screen.dart';
import 'package:cuttinglist/screens/vanish_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Folder and File App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: VanishScreen(), // Set your initial screen here
      routes: {
        '/': (context) => VanishScreen(),
        '/material-config': (context) => MaterialConfigScreen(),
      },
    );
  }
}
