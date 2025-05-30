class Song {
  final String title;
  final String author;
  final String url;
  final String duration;

  bool isDownloaded;
  double downloadProgress;

  Song({
    required this.title,
    required this.author,
    required this.url,
    required this.duration,
    this.isDownloaded = false,
    this.downloadProgress = 0,
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
