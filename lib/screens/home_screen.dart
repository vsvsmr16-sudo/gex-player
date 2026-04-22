import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';
import 'live_tv_screen.dart';
import 'add_playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ps = context.watch<PlaylistService>();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _TopBar(expired: false),
              const SizedBox(height: 28),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _MainGrid(ps: ps)),
                    const SizedBox(width: 16),
                    _SideColumn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool expired;
  const _TopBar({required this.expired});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3),
            children: [
              TextSpan(text: 'GEX', style: TextStyle(color: Colors.white)),
              TextSpan(text: '▶', style: TextStyle(color: Color(0xFFC0392B), fontSize: 24)),
              TextSpan(text: 'PLAYER', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const Spacer(),
        if (expired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0808),
              border: Border.all(color: const Color(0xFFC0392B)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('⚠ Current Playlist Expired',
                style: TextStyle(color: Color(0xFFC0392B), fontSize: 12)),
          ),
      ],
    );
  }
}

class _MainGrid extends StatelessWidget {
  final PlaylistService ps;
  const _MainGrid({required this.ps});

  void _go(BuildContext context, int i) {
    if (!ps.hasPlaylist && i != 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlaylistScreen()));
      return;
    }
    switch (i) {
      case 0: Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTvScreen())); break;
      case 4: Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPlaylistScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      {'label': 'Live TV', 'icon': Icons.live_tv_rounded, 'featured': true},
      {'label': 'Movies', 'icon': Icons.movie_rounded, 'featured': false},
      {'label': 'Series', 'icon': Icons.video_library_rounded, 'featured': false},
      {'label': 'Account', 'icon': Icons.person_rounded, 'featured': false},
      {'label': 'Change Server', 'icon': Icons.swap_horiz_rounded, 'featured': false},
    ];
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _Tile(label: 'Live TV', icon: Icons.live_tv_rounded, featured: true, large: true, onTap: () => _go(context, 0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(children: [
                        Expanded(child: _Tile(label: 'Movies', icon: Icons.movie_rounded, featured: false, onTap: () => _go(context, 1))),
                        const SizedBox(width: 12),
                        Expanded(child: _Tile(label: 'Series', icon: Icons.video_library_rounded, featured: false, onTap: () => _go(context, 2))),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(children: [
                        Expanded(child: _Tile(label: 'Account', icon: Icons.person_rounded, featured: false, onTap: () => _go(context, 3))),
                        const SizedBox(width: 12),
                        Expanded(child: _Tile(label: 'Change Server', icon: Icons.swap_horiz_rounded, featured: false, onTap: () => _go(context, 4))),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool featured;
  final bool large;
  final VoidCallback onTap;
  const _Tile({required this.label, required this.icon, required this.featured, required this.onTap, this.large = false});
  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF1A0808) : (widget.featured ? const Color(0xFF1A0808) : const Color(0xFF12121F)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.featured || _hovered ? const Color(0xFFC0392B) : const Color(0xFF1E1E2A), width: widget.featured ? 2 : 1),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: widget.featured ? const Color(0xFFC0392B) : Colors.white54, size: widget.large ? 40 : 28),
              SizedBox(height: widget.large ? 16 : 8),
              Text(widget.label, style: TextStyle(color: widget.featured ? const Color(0xFFC0392B) : Colors.white, fontSize: widget.large ? 22 : 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideColumn extends StatelessWidget {
  const _SideColumn();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: _SideTile(label: 'Settings', icon: Icons.settings_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))))),
          Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: _SideTile(label: 'Reload', icon: Icons.refresh_rounded, onTap: () => context.read<PlaylistService>().reload()))),
          Expanded(child: _SideTile(label: 'EXIT', icon: Icons.exit_to_app_rounded, onTap: () => SystemNavigator.pop(), isExit: true)),
        ],
      ),
    );
  }
}

class _SideTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isExit;
  const _SideTile({required this.label, required this.icon, required this.onTap, this.isExit = false});
  @override
  State<_SideTile> createState() => _SideTileState();
}

class _SideTileState extends State<_SideTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF1A0808) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _hovered ? const Color(0xFFC0392B) : const Color(0xFF1E1E2A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.isExit ? const Color(0xFFC0392B) : Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(color: widget.isExit ? const Color(0xFFC0392B) : Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
