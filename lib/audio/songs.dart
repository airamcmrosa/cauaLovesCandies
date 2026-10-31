const List<Song> songs = [
  Song('caua_loves_candies_song.mp3', 'Caua Loves Candies', artist: 'Gemini'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
