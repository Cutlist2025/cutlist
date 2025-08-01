// side_panel.dart

import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Side Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Option 1'),
            onTap: () {
              // Handle the option
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: Text('Option 2'),
            onTap: () {
              // Handle the option
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: Text('Option 3'),
            onTap: () {
              // Handle the option
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
