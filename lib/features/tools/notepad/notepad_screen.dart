import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Note {
  String id, title, content;
  DateTime updatedAt;
  Note({required this.id, required this.title, required this.content, required this.updatedAt});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'content': content, 'updatedAt': updatedAt.toIso8601String()};
  factory Note.fromJson(Map<String, dynamic> j) => Note(id: j['id'], title: j['title'], content: j['content'], updatedAt: DateTime.parse(j['updatedAt']));
}

class NotepadScreen extends StatefulWidget {
  const NotepadScreen({super.key});
  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  List<Note> _notes = [];

  @override
  void initState() { super.initState(); _loadNotes(); }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes') ?? '[]';
    setState(() => _notes = (jsonDecode(data) as List).map((e) => Note.fromJson(e)).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(_notes.map((e) => e.toJson()).toList()));
  }

  void _addOrEdit([Note? note]) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(note == null ? AppLocalizations.of(context)!.addNote : AppLocalizations.of(context)!.editNote),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.noteTitle)),
          const SizedBox(height: 8),
          TextField(controller: contentCtrl, maxLines: 5, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.noteContent)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                if (note == null) {
                  _notes.insert(0, Note(id: DateTime.now().toString(), title: titleCtrl.text.trim(), content: contentCtrl.text.trim(), updatedAt: DateTime.now()));
                } else {
                  note.title = titleCtrl.text.trim();
                  note.content = contentCtrl.text.trim();
                  note.updatedAt = DateTime.now();
                }
              });
              _saveNotes();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notepad)),
      body: _notes.isEmpty
          ? Center(child: Text(l10n.noNotes))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notes.length,
              itemBuilder: (_, i) {
                final note = _notes[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.content.isEmpty ? '' : note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () { setState(() => _notes.removeAt(i)); _saveNotes(); },
                    ),
                    onTap: () => _addOrEdit(note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
