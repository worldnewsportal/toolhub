import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late TabController _tab;
  // Stopwatch
  final _stopwatch = Stopwatch();
  Timer? _swTimer;
  List<Duration> _laps = [];
  // Countdown
  int _hours = 0, _mins = 0, _secs = 0;
  Duration _remaining = Duration.zero;
  Timer? _cdTimer;
  bool _cdRunning = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _swTimer?.cancel();
    _cdTimer?.cancel();
    _tab.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$h:$m:$s.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timer),
        bottom: TabBar(controller: _tab, tabs: [
          Tab(text: l10n.stopwatch),
          Tab(text: l10n.countdown),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [_buildStopwatch(l10n), _buildCountdown(l10n)]),
    );
  }

  Widget _buildStopwatch(AppLocalizations l10n) {
    return Column(children: [
      const SizedBox(height: 40),
      Container(
        width: 220, height: 220,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.primary, width: 4)),
        alignment: Alignment.center,
        child: Text(_fmt(_stopwatch.elapsed), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton(
          heroTag: 'lap',
          mini: true,
          onPressed: _stopwatch.isRunning ? () => setState(() => _laps.insert(0, _stopwatch.elapsed)) : null,
          child: const Icon(Icons.flag),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'sw',
          onPressed: () {
            if (_stopwatch.isRunning) {
              _stopwatch.stop(); _swTimer?.cancel();
            } else {
              _stopwatch.start();
              _swTimer = Timer.periodic(const Duration(milliseconds: 30), (_) => setState(() {}));
            }
            setState(() {});
          },
          label: Text(_stopwatch.isRunning ? l10n.pause : l10n.start),
          icon: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'rst',
          mini: true,
          onPressed: () { _stopwatch.reset(); _swTimer?.cancel(); _laps.clear(); setState(() {}); },
          child: const Icon(Icons.refresh),
        ),
      ]),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _laps.length,
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(_fmt(_laps[i])),
          ),
        ),
      ),
    ]);
  }

  Widget _buildCountdown(AppLocalizations l10n) {
    return Column(children: [
      const SizedBox(height: 40),
      Container(
        width: 220, height: 220,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(
          color: _remaining.inSeconds > 10 ? Theme.of(context).colorScheme.primary : Colors.red,
          width: 4,
        )),
        alignment: Alignment.center,
        child: Text(_fmt(_remaining), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ),
      const SizedBox(height: 24),
      if (!_cdRunning) Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(children: [
          _picker(l10n.hours, _hours, (v) => setState(() => _hours = v), 23),
          const Text(':', style: TextStyle(fontSize: 24)),
          _picker(l10n.minutes, _mins, (v) => setState(() => _mins = v), 59),
          const Text(':', style: TextStyle(fontSize: 24)),
          _picker(l10n.seconds, _secs, (v) => setState(() => _secs = v), 59),
        ]),
      ),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FloatingActionButton.extended(
          heroTag: 'cd',
          onPressed: () {
            if (_cdRunning) {
              _cdTimer?.cancel(); setState(() => _cdRunning = false);
            } else {
              if (_remaining == Duration.zero) {
                _remaining = Duration(hours: _hours, minutes: _mins, seconds: _secs);
              }
              _cdRunning = true;
              _cdTimer = Timer.periodic(const Duration(seconds: 1), (_) {
                if (_remaining.inSeconds <= 0) {
                  _cdTimer?.cancel(); setState(() => _cdRunning = false);
                } else {
                  setState(() => _remaining -= const Duration(seconds: 1));
                }
              });
            }
            setState(() {});
          },
          label: Text(_cdRunning ? l10n.pause : l10n.start),
          icon: Icon(_cdRunning ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'cdrst',
          onPressed: () { _cdTimer?.cancel(); setState(() { _cdRunning = false; _remaining = Duration.zero; }); },
          child: const Icon(Icons.refresh),
        ),
      ]),
    ]);
  }

  Widget _picker(String label, int val, Function(int) onChanged, int max) {
    return Expanded(child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 12)),
      DropdownButton<int>(
        value: val,
        items: List.generate(max + 1, (i) => DropdownMenuItem(value: i, child: Text(i.toString().padLeft(2, '0')))),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]));
  }
}
