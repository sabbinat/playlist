import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SongService {
  static const String jsonUrl = 'https://www.rafaelamorim.com.br/mobile2/musicas/list.json';

  static Future<List<Song>> fetchPlaylist() async {
    final response = await http.get(Uri.parse(jsonUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Song.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar playlist');
    }
  }
}
