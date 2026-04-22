import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class PlaylistService extends ChangeNotifier {
  List<Playlist> _playlists = [];
  Playlist? _active;
  List<Channel> _channels = [];
  List<Movie> _movies = [];
  Map<String, List<Channel>> _categories = {};
  bool _loading = false;
  String? _error;

  List<Playlist> get playlists => _playlists;
  Playlist? get active => _active;
  List<Channel> get channels => _channels;
  List<Movie> get movies => _movies;
  Map<String, List<Channel>> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasPlaylist => _playlists.isNotEmpty;

  PlaylistService() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString('playlists');
    if (d != null) {
      _playlists = (jsonDecode(d) as List).map((e) => Playlist.fromJson(e)).toList();
      if (_playlists.isNotEmpty) await setActive(_playlists.first);
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('playlists', jsonEncode(_playlists.map((e) => e.toJson()).toList()));
  }

  Future<bool> addM3U(String name, String url) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (r.statusCode == 200) {
        final pl = Playlist(id: DateTime.now().toString(), name: name, type: PlaylistType.m3u, m3uUrl: url);
        _playlists.add(pl);
        await _save();
        await setActive(pl);
        _loading = false; notifyListeners(); return true;
      }
    } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners(); return false;
  }

  Future<bool> addXtream(String name, String server, String user, String pass) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final url = '${server.endsWith('/') ? server : '$server/'}player_api.php?username=$user&password=$pass';
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        final pl = Playlist(id: DateTime.now().toString(), name: name, type: PlaylistType.xtream, serverUrl: server, username: user, password: pass);
        _playlists.add(pl);
        await _save();
        await setActive(pl);
        _loading = false; notifyListeners(); return true;
      }
    } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners(); return false;
  }

  Future<void> setActive(Playlist pl) async {
    _active = pl; _loading = true; notifyListeners();
    try {
      if (pl.type == PlaylistType.m3u && pl.m3uUrl != null) {
        final r = await http.get(Uri.parse(pl.m3uUrl!)).timeout(const Duration(seconds: 30));
        if (r.statusCode == 200) _parseM3U(r.body);
      } else if (pl.type == PlaylistType.xtream) {
        await _loadXtream(pl);
      }
    } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }

  void _parseM3U(String content) {
    final all = <Channel>[];
    final lines = content.split('\n');
    String? name, logo, group;
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i].trim();
      if (l.startsWith('#EXTINF:')) {
        name = RegExp(r',(.+)$').firstMatch(l)?.group(1)?.trim();
        logo = RegExp(r'tvg-logo="([^"]*)"').firstMatch(l)?.group(1);
        group = RegExp(r'group-title="([^"]*)"').firstMatch(l)?.group(1);
      } else if (l.isNotEmpty && !l.startsWith('#') && name != null) {
        all.add(Channel(name: name, logo: logo, streamUrl: l, group: group));
        name = null;
      }
    }
    _channels = all;
    _categories = {};
    for (final ch in all) {
      final k = ch.group ?? 'All';
      _categories.putIfAbsent(k, () => []).add(ch);
    }
  }

  Future<void> _loadXtream(Playlist pl) async {
    final base = pl.serverUrl!.endsWith('/') ? pl.serverUrl! : '${pl.serverUrl}/';
    final u = pl.username!; final p = pl.password!;
    final r = await http.get(Uri.parse('${base}player_api.php?username=$u&password=$p&action=get_live_streams'));
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as List;
      _channels = data.map((item) => Channel(
        name: item['name'] ?? '',
        logo: item['stream_icon'],
        streamUrl: '${base}live/$u/$p/${item['stream_id']}.ts',
        group: item['category_name'],
      )).toList();
      _categories = {};
      for (final ch in _channels) {
        _categories.putIfAbsent(ch.group ?? 'All', () => []).add(ch);
      }
    }
  }

  Future<void> reload() async { if (_active != null) await setActive(_active!); }
  void remove(String id) { _playlists.removeWhere((p) => p.id == id); _save(); notifyListeners(); }
  List<Channel> search(String q) => q.isEmpty ? _channels : _channels.where((c) => c.name.toLowerCase().contains(q.toLowerCase())).toList();
}
