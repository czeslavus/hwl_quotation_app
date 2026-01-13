import 'dart:io';
import 'package:flutter/material.dart';

import 'package:wyceny/features/logs/data/service/logger_service.dart';
import 'package:wyceny/features/common/language_flag_toggle.dart';

class LogsScreen extends StatefulWidget {
  final LogService logService;
  const LogsScreen({super.key, required this.logService});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<File> files = [];
  String content = '';
  File? selected;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final list = await widget.logService.listLogFiles();
    setState(() => files = list.whereType<File>().toList());
    if (files.isNotEmpty) {
      _open(files.first);
    }
  }

  Future<void> _open(File f) async {
    final text = await f.readAsString();
    setState(() {
      selected = f;
      content = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logi aplikacji'),
        actions: [
          IconButton(
            onPressed: () => _open(selected!),
            icon: const Icon(Icons.refresh),
          ),
          const LanguageFlagToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: ListView(
              children: files.map((f) {
                final name = f.path.split('/').last;
                return ListTile(
                  title: Text(name),
                  selected: f == selected,
                  onTap: () => _open(f),
                );
              }).toList(),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                content.isEmpty ? '(pusty plik)' : content,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}
