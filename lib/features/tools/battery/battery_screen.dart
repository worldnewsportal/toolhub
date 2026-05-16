import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});
  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  final _battery = Battery();
  int _level = 0;
  BatteryState _state = BatteryState.unknown;
  AndroidDeviceInfo? _deviceInfo;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;
    setState(() { _level = level; _state = state; _deviceInfo = android; });
  }

  Color _batteryColor() {
    if (_level >= 60) return Colors.green;
    if (_level >= 30) return Colors.orange;
    return Colors.red;
  }

  IconData _batteryIcon() {
    if (_state == BatteryState.charging) return Icons.battery_charging_full;
    if (_level >= 90) return Icons.battery_full;
    if (_level >= 60) return Icons.battery_5_bar;
    if (_level >= 40) return Icons.battery_3_bar;
    if (_level >= 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final d = _deviceInfo;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.batteryInfo),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Icon(_batteryIcon(), size: 80, color: _batteryColor()),
                const SizedBox(height: 12),
                Text('$_level%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _batteryColor())),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: _batteryColor().withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _state == BatteryState.charging ? l10n.charging
                        : _state == BatteryState.full ? l10n.fullCharged
                        : l10n.notCharging,
                    style: TextStyle(color: _batteryColor(), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _level / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(_batteryColor()),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (d != null) Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _infoRow(Icons.phone_android, l10n.device, '${d.brand} ${d.model}'),
                _infoRow(Icons.android, 'Android', '${d.version.release} (API ${d.version.sdkInt})'),
                _infoRow(Icons.memory, 'Processor', d.hardware),
                _infoRow(Icons.perm_device_info, 'Board', d.board),
                _infoRow(Icons.build, 'Build', d.id),
                _infoRow(Icons.fingerprint, 'Serial', d.serialNumber),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
