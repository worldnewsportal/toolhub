import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key});
  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  List<WiFiAccessPoint> _networks = [];
  String _currentSSID = '', _currentIP = '', _currentBSSID = '';
  bool _scanning = false;

  @override
  void initState() { super.initState(); _scan(); }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await Permission.location.request();
    final info = NetworkInfo();
    _currentSSID = await info.getWifiName() ?? '';
    _currentIP = await info.getWifiIP() ?? '';
    _currentBSSID = await info.getWifiBSSID() ?? '';
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      setState(() { _networks = results..sort((a, b) => b.level.compareTo(a.level)); _scanning = false; });
    } else {
      setState(() => _scanning = false);
    }
  }

  IconData _signalIcon(int level) {
    if (level >= -50) return Icons.signal_wifi_4_bar;
    if (level >= -60) return Icons.network_wifi_3_bar;
    if (level >= -70) return Icons.network_wifi_2_bar;
    return Icons.network_wifi_1_bar;
  }

  Color _signalColor(int level) {
    if (level >= -50) return Colors.green;
    if (level >= -60) return Colors.lightGreen;
    if (level >= -70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wifiAnalyzer),
        actions: [
          IconButton(icon: _scanning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh), onPressed: _scanning ? null : _scan),
        ],
      ),
      body: Column(children: [
        if (_currentSSID.isNotEmpty) Card(
          margin: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Icon(Icons.wifi, size: 40),
              const SizedBox(height: 8),
              Text(_currentSSID.replaceAll('"', ''), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('IP: $_currentIP'),
              Text('BSSID: $_currentBSSID'),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('${l10n.networks}: ${_networks.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _networks.length,
            itemBuilder: (_, i) {
              final n = _networks[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: Icon(_signalIcon(n.level), color: _signalColor(n.level), size: 32),
                  title: Text(n.ssid.isEmpty ? 'Hidden Network' : n.ssid, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${n.level} dBm  •  ${n.frequency} MHz  •  Ch ${(n.frequency - 2407) ~/ 5}'),
                  trailing: n.capabilities.contains('WPA') ? const Icon(Icons.lock, size: 18) : const Icon(Icons.lock_open, size: 18, color: Colors.orange),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
