import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/playlist_service.dart';

class AddPlaylistScreen extends StatefulWidget {
  const AddPlaylistScreen({super.key});
  @override
  State<AddPlaylistScreen> createState() => _AddPlaylistScreenState();
}

class _AddPlaylistScreenState extends State<AddPlaylistScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _name = TextEditingController();
  final _m3u = TextEditingController();
  final _server = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); _name.dispose(); _m3u.dispose(); _server.dispose(); _user.dispose(); _pass.dispose(); super.dispose(); }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(controller: ctrl, obscureText: obscure, style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true, fillColor: const Color(0xFF0D0D18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1E2A))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E1E2A))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFC0392B), width: 1.5)),
          )),
      ]),
    );
  }

  Future<void> _connect() async {
    if (_name.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a name'), backgroundColor: Color(0xFFC0392B))); return; }
    setState(() => _loading = true);
    final ps = context.read<PlaylistService>();
    bool ok;
    if (_tab.index == 0) {
      ok = await ps.addM3U(_name.text.trim(), _m3u.text.trim());
    } else {
      ok = await ps.addXtream(_name.text.trim(), _server.text.trim(), _user.text.trim(), _pass.text.trim());
    }
    setState(() => _loading = false);
    if (ok && mounted) Navigator.pop(context);
    else if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ps.error ?? 'Failed'), backgroundColor: const Color(0xFFC0392B)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D18),
        title: const Text('Add Playlist', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        bottom: TabBar(controller: _tab, indicatorColor: const Color(0xFFC0392B), labelColor: const Color(0xFFC0392B), unselectedLabelColor: Colors.white54, tabs: const [Tab(text: 'M3U URL'), Tab(text: 'Xtream Codes')]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _field('Playlist Name', _name, Icons.label_rounded),
          Expanded(child: TabBarView(controller: _tab, children: [
            Column(children: [const SizedBox(height: 8), _field('M3U URL', _m3u, Icons.link_rounded)]),
            Column(children: [const SizedBox(height: 8), _field('Server URL', _server, Icons.dns_rounded), _field('Username', _user, Icons.person_rounded), _field('Password', _pass, Icons.lock_rounded, obscure: true)]),
          ])),
          SizedBox(width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _connect,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('CONNECT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2)),
            )),
        ]),
      ),
    );
  }
}
