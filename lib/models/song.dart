class Song {
  final String title;
  final String author;
  final String url;
  final String duration;

  Song({
    required this.title,
    required this.author,
    required this.url,
    required this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      author: json['author'],
      url: json['url'],
      duration: json['duration'],
    );
  }
}
