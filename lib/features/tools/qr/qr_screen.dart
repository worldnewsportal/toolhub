import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});
  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _genCtrl = TextEditingController();
  String _genText = '';
  String _scanResult = '';
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); _genCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrScanner),
        bottom: TabBar(controller: _tab, tabs: [
          Tab(icon: const Icon(Icons.qr_code_scanner), text: l10n.scan),
          Tab(icon: const Icon(Icons.qr_code), text: l10n.generate),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        _buildScanner(l10n),
        _buildGenerator(l10n),
      ]),
    );
  }

  Widget _buildScanner(AppLocalizations l10n) {
    return Column(children: [
      Expanded(
        child: Stack(children: [
          MobileScanner(
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue ?? '';
              if (code != _scanResult) setState(() => _scanResult = code);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ]),
      ),
      if (_scanResult.isNotEmpty) Container(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(_scanResult, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(l10n.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _scanResult));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.copied)));
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.reset),
              onPressed: () => setState(() => _scanResult = ''),
            ),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildGenerator(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        TextField(
          controller: _genCtrl,
          decoration: InputDecoration(
            hintText: l10n.enterQRText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { _genCtrl.clear(); setState(() => _genText = ''); }),
          ),
          onChanged: (v) => setState(() => _genText = v),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        if (_genText.isNotEmpty) QrImageView(
          data: _genText,
          version: QrVersions.auto,
          size: 260,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
        if (_genText.isEmpty) Container(
          width: 260, height: 260,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.qr_code, size: 100, color: Colors.grey),
        ),
      ]),
    );
  }
}
