import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});
  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<FileSystemEntity> _files = [];
  String _currentPath = '/storage/emulated/0';

  @override
  void initState() { super.initState(); _loadFiles(); }

  void _loadFiles() {
    try {
      final dir = Directory(_currentPath);
      setState(() => _files = dir.listSync()..sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;
        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;
        return a.path.compareTo(b.path);
      }));
    } catch (_) {}
  }

  IconData _icon(FileSystemEntity e) {
    if (e is Directory) return Icons.folder_rounded;
    final ext = e.path.split('.').last.toLowerCase();
    if (['jpg','jpeg','png','gif','webp'].contains(ext)) return Icons.image_rounded;
    if (['mp3','wav','aac','m4a'].contains(ext)) return Icons.music_note_rounded;
    if (['mp4','mkv','avi'].contains(ext)) return Icons.video_file_rounded;
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc','docx'].contains(ext)) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _iconColor(FileSystemEntity e) {
    if (e is Directory) return Colors.amber;
    final ext = e.path.split('.').last.toLowerCase();
    if (['jpg','jpeg','png','gif'].contains(ext)) return Colors.green;
    if (['mp3','wav','aac'].contains(ext)) return Colors.purple;
    if (ext == 'pdf') return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fileManager),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final parent = Directory(_currentPath).parent.path;
            if (parent != _currentPath) { setState(() => _currentPath = parent); _loadFiles(); }
            else Navigator.pop(context);
          },
        ),
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceVariant,
          width: double.infinity,
          child: Text(_currentPath, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: _files.isEmpty
              ? const Center(child: Text('Empty folder'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (_, i) {
                    final e = _files[i];
                    final name = e.path.split('/').last;
                    return ListTile(
                      leading: Icon(_icon(e), color: _iconColor(e), size: 32),
                      title: Text(name, overflow: TextOverflow.ellipsis),
                      subtitle: e is File ? Text('${(e.lengthSync() / 1024).toStringAsFixed(1)} KB') : null,
                      onTap: () {
                        if (e is Directory) { setState(() => _currentPath = e.path); _loadFiles(); }
                        else OpenFile.open(e.path);
                      },
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
