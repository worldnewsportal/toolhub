import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});
  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final List<File> _images = [];
  bool _converting = false;
  String? _pdfPath;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() { _images.addAll(picked.map((e) => File(e.path))); _pdfPath = null; });
    }
  }

  Future<void> _convert() async {
    if (_images.isEmpty) return;
    setState(() => _converting = true);
    try {
      final pdf = pw.Document();
      for (final img in _images) {
        final bytes = await img.readAsBytes();
        final image = pw.MemoryImage(bytes);
        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ));
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/toolhub_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      setState(() { _pdfPath = path; _converting = false; });
    } catch (e) {
      setState(() => _converting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.imagePdf)),
      body: Column(children: [
        Expanded(
          child: _images.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.image, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(icon: const Icon(Icons.add_photo_alternate), label: Text(l10n.selectFiles), onPressed: _pickImages),
                ]))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${_images.length} images selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(children: [
                        TextButton.icon(icon: const Icon(Icons.add), label: const Text('Add'), onPressed: _pickImages),
                        TextButton.icon(icon: const Icon(Icons.clear), label: Text(l10n.clear), onPressed: () => setState(() { _images.clear(); _pdfPath = null; })),
                      ]),
                    ]),
                  ),
                  Expanded(child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _images.length,
                    itemBuilder: (_, i) => Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_images[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
                      Positioned(top: 4, right: 4, child: GestureDetector(
                        onTap: () => setState(() { _images.removeAt(i); _pdfPath = null; }),
                        child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Colors.white)),
                      )),
                    ]),
                  )),
                ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            if (_pdfPath != null) Row(children: [
              Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.open_in_new), label: const Text('Open PDF'), onPressed: () => OpenFile.open(_pdfPath!))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.share), label: Text(l10n.share), onPressed: () => Share.shareXFiles([XFile(_pdfPath!)]))),
            ]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              icon: _converting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.picture_as_pdf),
              label: Text(l10n.convertToPDF),
              onPressed: _images.isEmpty || _converting ? null : _convert,
            )),
          ]),
        ),
      ]),
    );
  }
}
