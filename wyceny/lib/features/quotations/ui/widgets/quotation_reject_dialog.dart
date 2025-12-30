import 'package:flutter/material.dart';

import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/reject_causes_dictionary.dart';

class RejectDialogResult {
  final int rejectCauseId;
  final String? rejectCauseNote;
  const RejectDialogResult({
    required this.rejectCauseId,
    this.rejectCauseNote,
  });
}

/// Główny punkt wejścia: pokazuje dialog (wide) albo bottom sheet (narrow)
Future<RejectDialogResult?> showRejectDialog({
  required BuildContext context,
  required int quotationId,
}) async {
  final dictRepo = getIt<DictionariesRepository>();

  // Zakładamy preload po starcie, ale na wszelki wypadek:
  if (!dictRepo.isLoaded) {
    await dictRepo.preload();
  }

  final causes = dictRepo.rejectCauses;
  if (causes.isEmpty) {
    // awaryjnie: brak słownika => prosty confirm z "1"
    return showDialog<RejectDialogResult?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odrzucić wycenę?'),
        content: const Text('Brak listy powodów. Odrzucić z domyślnym powodem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              const RejectDialogResult(rejectCauseId: 1),
            ),
            child: const Text('Odrzuć'),
          ),
        ],
      ),
    );
  }

  final isWide = MediaQuery.sizeOf(context).width >= 700;

  if (isWide) {
    return showDialog<RejectDialogResult?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RejectDialog(
        quotationId: quotationId,
        causes: causes,
      ),
    );
  }

  return showModalBottomSheet<RejectDialogResult?>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _RejectBottomSheet(
          quotationId: quotationId,
          causes: causes,
        ),
      ),
    ),
  );
}

// ------------------ Internal widgets ------------------

class _RejectDialog extends StatefulWidget {
  final int quotationId;
  final List<RejectCausesDictionary> causes;
  const _RejectDialog({
    required this.quotationId,
    required this.causes,
  });

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  late int _selectedId;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedId = widget.causes.first.rejectCauseId ?? 1;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Odrzucenie wyceny #${widget.quotationId}'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.causes.length,
                itemBuilder: (context, i) {
                  final c = widget.causes[i];
                  final id = c.rejectCauseId ?? 0;
                  final name = c.rejectCauseName ?? '—';
                  return RadioListTile<int>(
                    value: id,
                    groupValue: _selectedId,
                    onChanged: (v) => setState(() => _selectedId = v ?? _selectedId),
                    title: Text(name),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Dodatkowy opis (opcjonalnie)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            RejectDialogResult(
              rejectCauseId: _selectedId,
              rejectCauseNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            ),
          ),
          child: const Text('Odrzuć'),
        ),
      ],
    );
  }
}

class _RejectBottomSheet extends StatefulWidget {
  final int quotationId;
  final List<RejectCausesDictionary> causes;
  const _RejectBottomSheet({
    required this.quotationId,
    required this.causes,
  });

  @override
  State<_RejectBottomSheet> createState() => _RejectBottomSheetState();
}

class _RejectBottomSheetState extends State<_RejectBottomSheet> {
  late int _selectedId;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedId = widget.causes.first.rejectCauseId ?? 1;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Odrzucenie wyceny #${widget.quotationId}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.causes.length,
              itemBuilder: (context, i) {
                final c = widget.causes[i];
                final id = c.rejectCauseId ?? 0;
                final name = c.rejectCauseName ?? '—';
                return RadioListTile<int>(
                  value: id,
                  groupValue: _selectedId,
                  onChanged: (v) => setState(() => _selectedId = v ?? _selectedId),
                  title: Text(name),
                  dense: true,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Dodatkowy opis (opcjonalnie)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Anuluj'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    RejectDialogResult(
                      rejectCauseId: _selectedId,
                      rejectCauseNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                    ),
                  ),
                  child: const Text('Odrzuć'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
