import 'package:flutter/material.dart';
import 'package:playlist/viewmodels/song_viewmodel.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final musicProvider = Provider.of<SongViewmodel>(context, listen: false);
    musicProvider.loadPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist MP3')),
      body: Consumer<SongViewmodel>(
        builder: (context, musicProvider, _) {
          if (musicProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (musicProvider.error != null) {
            return Center(child: Text('Error: ${musicProvider.error}'));
          }
          final musics = musicProvider.playlist;
          if (musics.isEmpty) {
            return const Center(child: Text('No hay canciones'));
          }
          return ListView.builder(
            itemCount: musics.length,
            itemBuilder: (context, index) {
              final music = musics[index];
              return ListTile(
                title: Text(music.title),
                subtitle: Text('${music.author} • ${music.duration}'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => musicProvider.playMusic(index),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<SongViewmodel>(
        builder: (context, musicProvider, child) {
          final current = musicProvider.currentMusic;
          if (current == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(current.title),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: musicProvider.pauseMusic,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
