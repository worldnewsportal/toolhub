import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _query = OnAudioQuery();
  final _player = AudioPlayer();
  List<SongModel> _songs = [];
  SongModel? _current;
  bool _playing = false;
  Duration _position = Duration.zero, _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _player.positionStream.listen((p) => setState(() => _position = p));
    _player.durationStream.listen((d) => setState(() => _duration = d ?? Duration.zero));
    _player.playingStream.listen((p) => setState(() => _playing = p));
  }

  Future<void> _loadSongs() async {
    final perm = await _query.permissionsRequest();
    if (!perm) return;
    final songs = await _query.querySongs(sortType: SongSortType.TITLE, orderType: OrderType.ASC_OR_SMALLER, uriType: UriType.EXTERNAL, ignoreCase: true);
    setState(() => _songs = songs.where((s) => s.duration != null && s.duration! > 30000).toList());
  }

  Future<void> _play(SongModel song) async {
    setState(() => _current = song);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    await _player.play();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.musicPlayer)),
      body: Column(children: [
        if (_current != null) Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primaryContainer),
                child: Icon(Icons.music_note, size: 40, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(_current!.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              Text(_current!.artist ?? 'Unknown', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Slider(value: _position.inSeconds.toDouble(), max: _duration.inSeconds.toDouble().clamp(1, double.infinity), onChanged: (v) => _player.seek(Duration(seconds: v.toInt()))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_fmt(_position)), Text(_fmt(_duration))]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(icon: const Icon(Icons.skip_previous), onPressed: () { final i = _songs.indexOf(_current!); if (i > 0) _play(_songs[i - 1]); }),
                IconButton(iconSize: 48, icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle), onPressed: () => _playing ? _player.pause() : _player.play()),
                IconButton(icon: const Icon(Icons.skip_next), onPressed: () { final i = _songs.indexOf(_current!); if (i < _songs.length - 1) _play(_songs[i + 1]); }),
              ]),
            ]),
          ),
        ),
        Expanded(
          child: _songs.isEmpty
              ? Center(child: Text(l10n.noMusic))
              : ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(_songs[i].title, overflow: TextOverflow.ellipsis),
                    subtitle: Text(_songs[i].artist ?? 'Unknown'),
                    selected: _current?.id == _songs[i].id,
                    onTap: () => _play(_songs[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}
