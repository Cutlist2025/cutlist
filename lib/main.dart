import 'package:cuttinglist/screens/materialConfig.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:cuttinglist/screens/only_canva.dart';
import 'package:cuttinglist/screens/drawingboard_screen.dart';
import 'package:cuttinglist/screens/folder_screen.dart';
import 'package:cuttinglist/screens/vanish_screen.dart';

void main() {
  runApp(
    DevicePreview(
      // enabled: !bool.fromEnvironment('dart.vm.product'), // Enables only in debug
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Folder and File App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // home: VanishScreen(), // Initial screen
      locale: DevicePreview.locale(context), // Adds locale support
      builder: DevicePreview.appBuilder, // Enables screen preview
      routes: {
        '/': (context) => VanishScreen(),
        '/material-config': (context) => MaterialConfigScreen(),
      },
    );
  }
}
