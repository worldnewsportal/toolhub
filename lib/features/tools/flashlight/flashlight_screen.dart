import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});
  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  static const _channel = MethodChannel('toolhub/flashlight');
  bool _on = false;

  Future<void> _toggle() async {
    try {
      _on = !_on;
      await _channel.invokeMethod(_on ? 'turnOn' : 'turnOff');
      if (_on) WakelockPlus.enable(); else WakelockPlus.disable();
      setState(() {});
    } catch (_) { setState(() {}); }
  }

  @override
  void dispose() { if (_on) _channel.invokeMethod('turnOff'); WakelockPlus.disable(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _on ? Colors.white : null,
      appBar: AppBar(title: Text(l10n.flashlight), backgroundColor: _on ? Colors.white : null),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _on ? Colors.yellow : Colors.grey[800],
              boxShadow: _on ? [BoxShadow(color: Colors.yellow.withOpacity(0.6), blurRadius: 60, spreadRadius: 20)] : [],
            ),
            child: Icon(Icons.flashlight_on, size: 100, color: _on ? Colors.orange : Colors.white54),
          ),
        ),
        const SizedBox(height: 40),
        Text(_on ? l10n.on : l10n.off, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _on ? Colors.orange : null)),
        const SizedBox(height: 16),
        Text(_on ? 'Tap to turn off' : 'Tap to turn on', style: TextStyle(color: Colors.grey[600])),
      ])),
    );
  }
}
