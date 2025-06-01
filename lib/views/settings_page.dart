import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playlist/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "C O N F I G U R A C I Ó N",
          style: TextStyle(
              fontSize: 16,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12)
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(25),
        child: Row(
          children: [
            //dark mode
            Text(
              "Modo oscuro",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            //switch
            CupertinoSwitch(
              value: 
                Provider.of<ThemeProvider>(context, listen: false).isDarkMode, 
              onChanged: (value) => 
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme()
            ),
          ],
        ),
      ),
    );
  }
}
