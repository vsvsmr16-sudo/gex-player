import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ps = context.watch<PlaylistService>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(backgroundColor: const Color(0xFF0D0D18), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)), title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('MY PLAYLISTS', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 12),
        ...ps.playlists.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0D0D18), borderRadius: BorderRadius.circular(10), border: Border.all(color: ps.active?.id == p.id ? const Color(0xFFC0392B) : const Color(0xFF1E1E2A))),
          child: Row(children: [
            Icon(p.type.index == 0 ? Icons.link_rounded : Icons.dns_rounded, color: ps.active?.id == p.id ? const Color(0xFFC0392B) : Colors.white38),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: TextStyle(color: ps.active?.id == p.id ? const Color(0xFFC0392B) : Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              Text(p.type.index == 0 ? 'M3U Playlist' : 'Xtream Codes', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ])),
            if (ps.active?.id != p.id) TextButton(onPressed: () => ps.setActive(p), child: const Text('Activate', style: TextStyle(color: Color(0xFFC0392B)))),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38), onPressed: () => ps.remove(p.id)),
          ]),
        )),
        const SizedBox(height: 24),
        const Text('ABOUT', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF0D0D18), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1E1E2A))),
          child: const Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('App', style: TextStyle(color: Colors.white54)), Text('Gex Player', style: TextStyle(color: Colors.white))]),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Version', style: TextStyle(color: Colors.white54)), Text('1.0.0', style: TextStyle(color: Colors.white))]),
            SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Website', style: TextStyle(color: Colors.white54)), Text('gexplayer.com', style: TextStyle(color: Color(0xFFC0392B)))]),
          ]),
        ),
      ]),
    );
  }
}
