import 'package:flutter/material.dart';
import 'package:playlist/components/neu_box.dart';
import 'package:provider/provider.dart';
import '../components/my_drawer.dart';
import '../models/song.dart';
import '../viewmodels/song_viewmodel.dart';

class SongPage extends StatefulWidget {
  final Song song;

  const SongPage({super.key, required this.song});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  double? _dragValue; // Para manejar el valor mientras el usuario mueve el slider

  // Formatea la duración para mostrar en mm:ss
  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    final songVM = Provider.of<SongViewmodel>(context, listen: false);
    final songIndex = songVM.playlist.indexOf(widget.song);
    if (songIndex != -1) {
      songVM.play(songIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SongViewmodel>(
      builder: (context, value, _) {
        final song = value.currentMusic ?? widget.song;
        final isCurrent = value.currentMusic == song;
        final isPlaying = value.audioPlayer.playing && isCurrent;

        final maxDuration = value.totalDuration.inSeconds > 0
            ? value.totalDuration.inSeconds.toDouble()
            : 1.0;

        // Usa _dragValue mientras el usuario mueve el slider, sino el valor real
        final currentValue = (_dragValue ??
            value.currentDuration.inSeconds.toDouble())
            .clamp(0, maxDuration)
            .toDouble();

        return Scaffold(
          key: _scaffoldKey, // necesario para controlar el drawer
          drawer: const MyDrawer(), // Drawer disponible
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25, bottom: 25, top: 30),
              child: Column(
                children: [
                  // App bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text("P L A Y L I S T"),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          _scaffoldKey.currentState!.openDrawer(); // esto abre el drawer
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Imagen, título y autor + botón descarga
                  NeuBox(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 310,
                            height: 310,
                            color: Theme.of(context).colorScheme.secondary,
                            child: Icon(
                              Icons.music_note,
                              size: 150,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título y autor
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //título de la canción
                                    Text(
                                      song.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    //autor
                                    Tooltip(
                                      message: song.author,
                                      child: Text(
                                        song.author,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Botón de descarga y progreso
                              if (song.isDownloaded)
                                const Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent)
                              else
                                if (song.downloadProgress > 0 && song.downloadProgress < 1)
                                  SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      value: song.downloadProgress,
                                      color: Colors.greenAccent,
                                      strokeWidth: 3,
                                    ),
                                  )
                                else
                                  IconButton(
                                    icon: Icon(
                                      Icons.download,
                                      color: Theme.of(context).colorScheme.inversePrimary,
                                    ),
                                    onPressed: () {
                                      Provider.of<SongViewmodel>(context, listen: false).downloadSong(song);
                                    },
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Duración y slider
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //posición de la canción
                            Text(_formatTime(Duration(seconds: currentValue.toInt()))),
                            const Icon(Icons.shuffle),
                            const Icon(Icons.repeat),
                            //duración total de la canción
                            Text(_formatTime(value.totalDuration)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          activeTrackColor: Colors.green,
                          inactiveTrackColor: Theme.of(context).colorScheme.secondary,
                          thumbColor: Colors.green,
                        ),
                        child: Slider(
                          min: 0,
                          max: maxDuration,
                          value: currentValue,
                          onChanged: (double newValue) {
                            setState(() {
                              _dragValue = newValue;
                            });
                          },
                          onChangeEnd: (double newValue) {
                            value.seek(Duration(seconds: newValue.toInt()));
                            setState(() {
                              _dragValue = null;
                            });
                          },
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 35),

                  // Controles de reproducción
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => value.playPrevious(),
                          child: const NeuBox(child: Icon(Icons.skip_previous)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            value.togglePlayPause();
                          },
                          child: NeuBox(
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => value.playNext(),
                          child: const NeuBox(child: Icon(Icons.skip_next)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}