import 'package:flutter/material.dart';
import 'package:playlist/views/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          //logo
          Padding(
            padding: const EdgeInsets.only(left: 23.0, top: 50),
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 40,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          const SizedBox(height: 50),
          // home title
          Padding(
            padding: const EdgeInsets.only(left: 23.0, top: 25),
            child: ListTile(
              title: const Text(
                "I N I C I O"),
              leading: const Icon(Icons.home),
              onTap: () => Navigator.pop(context),
            ),
          ),

          // settings tile
          Padding(
            padding: const EdgeInsets.only(left: 23.0, top: 0),
            child: ListTile(
              title: const Text(
                "C O N F I G U R A C I Ó N"),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);

                //navigate to settings
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
