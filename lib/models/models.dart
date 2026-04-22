import 'dart:convert';

enum PlaylistType { m3u, xtream }

class Playlist {
  final String id;
  final String name;
  final PlaylistType type;
  final String? m3uUrl;
  final String? serverUrl;
  final String? username;
  final String? password;

  Playlist({
    required this.id,
    required this.name,
    required this.type,
    this.m3uUrl,
    this.serverUrl,
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type.index,
    'm3uUrl': m3uUrl, 'serverUrl': serverUrl,
    'username': username, 'password': password,
  };

  factory Playlist.fromJson(Map<String, dynamic> j) => Playlist(
    id: j['id'], name: j['name'],
    type: PlaylistType.values[j['type']],
    m3uUrl: j['m3uUrl'], serverUrl: j['serverUrl'],
    username: j['username'], password: j['password'],
  );
}

class Channel {
  final String name;
  final String? logo;
  final String streamUrl;
  final String? group;

  Channel({required this.name, this.logo, required this.streamUrl, this.group});
}

class Movie {
  final String name;
  final String? logo;
  final String streamUrl;
  final String? genre;

  Movie({required this.name, this.logo, required this.streamUrl, this.genre});
}
