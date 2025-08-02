import 'package:cuttinglist/screens/folder_screen.dart';
import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  final List<int> optionSet;

  const SidePanel({
    Key? key,
    required this.optionSet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define all available items and their internal onTap logic
    final Map<int, List<_SidePanelItem>> optionGroups = {
      1: [
        _SidePanelItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            debugPrint('Navigating to Dashboard');
            // Navigator.pushNamed(context, '/dashboard');
          },
        ),
        _SidePanelItem(
          icon: Icons.folder,
          title: 'Projects',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FolderListScreen()),
            );
          },
        ),
      ],
      2: [
        _SidePanelItem(
          icon: Icons.view_quilt,
          title: 'Material Config',
          onTap: () {
            debugPrint('Opening Material Config');
            Navigator.pushNamed(context, '/material-config');
          },
        ),
        _SidePanelItem(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            debugPrint('Opening Settings');
            // Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
      3: [
        _SidePanelItem(
          icon: Icons.palette,
          title: 'Appearance',
          onTap: () {
            debugPrint('Opening Appearance');
            // Navigator.pushNamed(context, '/appearance');
          },
        ),
        _SidePanelItem(
          icon: Icons.info_outline,
          title: 'About App',
          onTap: () {
            debugPrint('Opening About App');
            // Navigator.pushNamed(context, '/about');
          },
        ),
      ],
      4: [
        _SidePanelItem(
          icon: Icons.design_services,
          title: 'Available Designs',
          onTap: () {
            debugPrint('Opening Available Designs');
            // Navigator.pushNamed(context, '/designs');
          },
        ),
        _SidePanelItem(
          icon: Icons.threed_rotation,
          title: '3D Layout Config',
          onTap: () {
            debugPrint('Opening 3D Layout');
            // Navigator.pushNamed(context, '/layout');
          },
        ),
      ],
    };

    // Merge selected option groups into a flat list
    List<_SidePanelItem> items = [];
    for (int id in optionSet) {
      if (optionGroups.containsKey(id)) {
        items.addAll(optionGroups[id]!);
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Row(
              children: [
                Icon(Icons.architecture, color: Colors.white, size: 40),
                SizedBox(width: 10),
                Text('Cutlist App',
                    style: TextStyle(color: Colors.white, fontSize: 22)),
              ],
            ),
          ),
          for (var item in items)
            ListTile(
              leading: Icon(item.icon, color: Colors.grey[700]),
              title: Text(item.title),
              onTap: () {
                Navigator.pop(context);
                item.onTap();
              },
            ),
        ],
      ),
    );
  }
}

class _SidePanelItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _SidePanelItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
