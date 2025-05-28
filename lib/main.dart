import 'package:flutter/material.dart';
import 'package:playlist/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';
import 'views/home_page.dart';
import 'viewmodels/song_viewmodel.dart';

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SongViewmodel(),
      child: MaterialApp(
        title: 'MP3 Player',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const HomePage(),
      ),
    );
  }
}
