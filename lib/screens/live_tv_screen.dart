import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import '../models/models.dart';
import 'player_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});
  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  String? _cat;
  String _q = '';
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ps = context.watch<PlaylistService>();
    if (ps.loading) return const Scaffold(backgroundColor: Color(0xFF0A0A0F), body: Center(child: CircularProgressIndicator(color: Color(0xFFC0392B))));
    final cats = ps.categories.keys.toList();
    _cat ??= cats.isNotEmpty ? cats.first : null;
    final channels = _q.isNotEmpty ? ps.search(_q) : (_cat != null ? (ps.categories[_cat] ?? []) : ps.channels);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Row(
        children: [
          Container(
            width: 200, color: const Color(0xFF0D0D18),
            child: Column(children: [
              const Padding(padding: EdgeInsets.all(16), child: Text('CATEGORIES', style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2))),
              Expanded(child: ListView.builder(
                itemCount: cats.length,
                itemBuilder: (_, i) {
                  final c = cats[i];
                  final sel = c == _cat;
                  return GestureDetector(
                    onTap: () => setState(() { _cat = c; _q = ''; _ctrl.clear(); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF1A0808) : Colors.transparent,
                        border: Border(left: BorderSide(color: sel ? const Color(0xFFC0392B) : Colors.transparent, width: 3)),
                      ),
                      child: Text(c, style: TextStyle(color: sel ? const Color(0xFFC0392B) : Colors.white54, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  );
                },
              )),
            ]),
          ),
          Expanded(
            child: Column(children: [
              Container(
                color: const Color(0xFF0D0D18),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const Icon(Icons.live_tv_rounded, color: Color(0xFFC0392B), size: 20),
                  const SizedBox(width: 8),
                  const Text('Live TV', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(
                    controller: _ctrl,
                    onChanged: (v) => setState(() => _q = v),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search...', hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 18),
                      filled: true, fillColor: const Color(0xFF12121F),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  )),
                ]),
              ),
              Expanded(child: channels.isEmpty
                ? const Center(child: Text('No channels', style: TextStyle(color: Colors.white38)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: channels.length,
                    itemBuilder: (_, i) => _ChannelTile(ch: channels[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(title: channels[i].name, url: channels[i].streamUrl)))),
                  )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ChannelTile extends StatefulWidget {
  final Channel ch;
  final VoidCallback onTap;
  const _ChannelTile({required this.ch, required this.onTap});
  @override
  State<_ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _h ? const Color(0xFF1A0808) : const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _h ? const Color(0xFFC0392B) : const Color(0xFF1E1E2A)),
          ),
          child: Row(children: [
            Container(width: 44, height: 44, color: const Color(0xFF0D0D18), child: const Icon(Icons.tv_rounded, color: Colors.white24, size: 22)),
            const SizedBox(width: 14),
            Expanded(child: Text(widget.ch.name, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (_h) const Icon(Icons.play_arrow_rounded, color: Color(0xFFC0392B), size: 24),
          ]),
        ),
      ),
    );
  }
}
