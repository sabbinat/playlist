import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SongService {
  static const String jsonUrl = 'https://www.rafaelamorim.com.br/mobile2/musicas/list.json';

  // Función para parsear JSON en isolate
  static Future<List<Song>> fetchPlaylist() async {
    final response = await http.get(Uri.parse(jsonUrl));
    if (response.statusCode == 200) {
      // Aquí lanzamos isolate para parsear el JSON sin bloquear UI
      final List<dynamic> data = await computeParse(response.body);
      return data.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar la playlist');
    }
  }

  // Función que se ejecuta en isolate para decodificar JSON
  static Future<List<dynamic>> computeParse(String responseBody) async {
    final p = ReceivePort();
    await Isolate.spawn(_parseJson, [p.sendPort, responseBody]);
    return await p.first;
  }

  // Isolate entry point
  static void _parseJson(List<dynamic> args) {
    SendPort sendPort = args[0];
    String responseBody = args[1];

    final parsed = json.decode(responseBody) as List<dynamic>;
    sendPort.send(parsed);
  }
}
