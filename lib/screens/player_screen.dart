import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String url;
  const PlayerScreen({super.key, required this.title, required this.url});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _ctrl;
  bool _showControls = true;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _init();
  }

  Future<void> _init() async {
    try {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _ctrl!.initialize();
      _ctrl!.play();
      setState(() { _loading = false; });
      Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _showControls = false); });
    } catch (e) { setState(() { _loading = false; _error = true; }); }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () { setState(() => _showControls = !_showControls); if (_showControls) Future.delayed(const Duration(seconds: 4), () { if (mounted) setState(() => _showControls = false); }); },
        child: Stack(children: [
          Center(child: _loading
            ? const CircularProgressIndicator(color: Color(0xFFC0392B))
            : _error
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFC0392B), size: 60),
                  const SizedBox(height: 16),
                  const Text('Cannot load stream', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () { setState(() { _loading = true; _error = false; }); _ctrl?.dispose(); _init(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B)), child: const Text('Retry')),
                ])
              : _ctrl != null && _ctrl!.value.isInitialized
                ? AspectRatio(aspectRatio: _ctrl!.value.aspectRatio, child: VideoPlayer(_ctrl!))
                : const CircularProgressIndicator(color: Color(0xFFC0392B))),
          if (_showControls) ...[
            Positioned(top: 0, left: 0, right: 0, child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.transparent])),
              child: SafeArea(child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24), onPressed: () => Navigator.pop(context)),
                Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                RichText(text: const TextSpan(style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2), children: [
                  TextSpan(text: 'GEX', style: TextStyle(color: Colors.white)),
                  TextSpan(text: '▶', style: TextStyle(color: Color(0xFFC0392B))),
                ])),
              ])),
            )),
            if (!_error && !_loading && _ctrl != null && _ctrl!.value.isInitialized)
              Positioned(bottom: 0, left: 0, right: 0, child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent])),
                child: SafeArea(child: Row(children: [
                  IconButton(icon: Icon(_ctrl!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32), onPressed: () => setState(() => _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play())),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFC0392B), borderRadius: BorderRadius.circular(4)), child: const Text('● LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22), onPressed: () {}),
                ])),
              )),
          ],
        ]),
      ),
    );
  }
}
