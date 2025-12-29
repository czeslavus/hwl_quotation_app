import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/reject_causes_dictionary.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotations_list_viewmodel.dart';

class QuotationsListScreen extends StatelessWidget {
  const QuotationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<QuotationsListViewModel>()..init(),
      child: const _QuotationsListView(),
    );
  }
}

class _QuotationsListView extends StatelessWidget {
  const _QuotationsListView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuotationsListViewModel>();
    final t = AppLocalizations.of(context);

    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;

    return Scaffold(
      appBar: TopBarAppBar(
        customerName: vm.customerName,
        contractorName: vm.contractorName,
        onLogout: () {/* TODO */},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nagłówek + przycisk Nowa wycena
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: isPhone
                ? Row(
              children: [
                Expanded(
                  child: Text(
                    t.quotations_title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _NewQuotationCompactButton(
                  tooltip: t.action_new_quotation,
                  onPressed: () => context.push('/quote/new'),
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: Text(
                    t.quotations_title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                _NewQuotationButton(onPressed: () => context.push('/quote/new')),
              ],
            ),
          ),

          // Ogłoszenia
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AnnouncementsPanel(
              header: Text("${t.announcement_line} • ${t.overdue_info}"),
              body: Text("${t.announcement_line} • ${t.overdue_info}"),
            ),
          ),

          const Divider(height: 1),

          // Filtry (bez kraju nadania — zawsze PL)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _ResponsiveFiltersBar(vm: vm),
          ),

          const Divider(height: 1),

          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                ? Center(child: Text(t.error_generic(vm.error.toString())))
                : vm.items.isEmpty
                ? Center(child: Text(t.list_empty))
                : _QuotationsTable(vm: vm),
          ),

          const Divider(height: 1),
          _PaginationBar(vm: vm),
        ],
      ),
    );
  }
}

class _NewQuotationCompactButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  const _NewQuotationCompactButton({required this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(52, 52),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class _NewQuotationButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewQuotationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(t.action_new_quotation),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}

class _ResponsiveFiltersBar extends StatefulWidget {
  final QuotationsListViewModel vm;
  const _ResponsiveFiltersBar({required this.vm});

  @override
  State<_ResponsiveFiltersBar> createState() => _ResponsiveFiltersBarState();
}

class _ResponsiveFiltersBarState extends State<_ResponsiveFiltersBar> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.vm.dateFrom;
    _to = widget.vm.dateTo;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vm = widget.vm;

    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;

    final fields = <Widget>[
      Row(mainAxisSize: MainAxisSize.min, children: [
        _dateField(
          context: context,
          label: t.filter_date_from,
          value: _from,
          onPick: (d) => setState(() => _from = d),
        ),
        const SizedBox(width: 8),
        _dateField(
          context: context,
          label: t.filter_date_to,
          value: _to,
          onPick: (d) => setState(() => _to = d),
        ),
      ]),
      SizedBox(
        width: 240,
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: vm.destCountryId,
          decoration: InputDecoration(labelText: t.gen_dest_country),
          items: vm.countries
              .map((c) => DropdownMenuItem(
            value: c.countryId,
            child: Text(CountryLocalizer.localize(c.country, context)),
          ))
              .toList(),
          onChanged: (id) => setState(() => vm.destCountryId = id),
        ),
      ),
    ];

    void onApply() => vm.applyFilters(from: _from, to: _to, destId: vm.destCountryId);
    void onClear() {
      setState(() {
        _from = null;
        _to = null;
        vm.destCountryId = null;
      });
      vm.applyFilters(from: null, to: null, destId: null);
    }

    if (isPhone) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...fields,
          Tooltip(
            message: t.filter_apply,
            child: IconButton.filled(
              onPressed: onApply,
              icon: const Icon(Icons.filter_alt),
            ),
          ),
          Tooltip(
            message: t.filter_clear,
            child: IconButton.outlined(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: fields,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.filter_alt),
                  label: Text(t.filter_apply),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off),
                  label: Text(t.filter_clear),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) {
    return SizedBox(
      width: 190,
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: DateTime(now.year - 2),
            lastDate: DateTime(now.year + 1),
          );
          onPick(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(value != null ? "${value.toLocal()}".split(' ')[0] : "—"),
        ),
      ),
    );
  }
}

class _QuotationsTable extends StatelessWidget {
  final QuotationsListViewModel vm;
  const _QuotationsTable({required this.vm});

  @override
  Widget build(BuildContext context) {
    final hCtrl = ScrollController();
    final vCtrl = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: hCtrl,
          thumbVisibility: true,
          notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
          child: Scrollbar(
            controller: vCtrl,
            thumbVisibility: true,
            notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
            child: SingleChildScrollView(
              controller: hCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: SingleChildScrollView(
                  controller: vCtrl,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 48,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 72,

                    columns: const [
                      DataColumn(label: Text('Wycena')),
                      DataColumn(label: Text('Trasa')),
                      DataColumn(label: Text('Detale')),
                      DataColumn(label: Text('Cena')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Akcje')),
                    ],

                    rows: vm.items.map((q) {
                      final mp = (q.quotationPositions ?? [])
                          .fold<double>(0, (s, it) => s + (it.ldm ?? 0));

                      return DataRow(cells: [
                        DataCell(_twoLines(
                          q.createDate?.toLocal().toString().split(' ').first ?? '—',
                          q.quotationId?.toString() ?? '—',
                        )),
                        DataCell(_twoLines(
                          'PL ${q.receiptZipCode}',
                          '${vm.countryCodeForId(q.deliveryCountryId)} ${q.deliveryZipCode}',
                        )),
                        DataCell(_twoLines(
                          'MP: ${mp.toStringAsFixed(2)}',
                          'W: ${(q.weightChgw ?? 0).toStringAsFixed(0)}',
                        )),
                        DataCell(Text((q.allIn ?? q.shippingPrice ?? 0).toStringAsFixed(2))),
                        DataCell(Text(vm.statusLabel(q.status))),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: _ActionsCell(
                              quotationId: q.quotationId ?? 0,
                              statusId: q.status,
                              orderNrSl: q.orderNrSl,
                              vm: vm,
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _twoLines(String top, String bottom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(top, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          bottom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final int quotationId;
  final int? statusId;
  final String? orderNrSl;
  final QuotationsListViewModel vm;

  const _ActionsCell({
    required this.quotationId,
    required this.vm,
    required this.statusId,
    required this.orderNrSl,
  });

  bool get _isValidId => quotationId > 0;

  // wg Twoich ustaleń:
  bool get _isRejected => statusId == 4;
  bool get _isApproved => statusId == 3;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget slot({required bool visible, required Widget child}) {
      return Visibility(
        visible: visible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: child,
      );
    }

    final canOpenOrder = _isApproved && (orderNrSl != null) && orderNrSl!.trim().isNotEmpty;

    return SizedBox(
      width: 260, // trochę szerzej, bo doszła ikona ciężarówki
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // APPROVE (ukryte po Rejected; możesz też ukryć po Approved, jeśli nie ma sensu)
              slot(
                visible: !_isRejected && !_isApproved,
                child: IconButton(
                  tooltip: t.action_submit,
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _isValidId ? () => vm.approve(quotationId) : null,
                ),
              ),

              // EDIT
              slot(
                visible: !_isRejected && !_isApproved,
                child: IconButton(
                  tooltip: t.action_edit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _isValidId && !_isRejected
                      ? () => context.push('/quote/$quotationId')
                      : null,
                ),
              ),

              // COPY (zawsze)
              IconButton(
                tooltip: t.action_copy,
                icon: const Icon(Icons.copy_outlined),
                onPressed: _isValidId ? () => vm.copy(quotationId) : null,
              ),

              // REJECT
              slot(
                visible: !_isRejected && !_isApproved,
                child: IconButton(
                  tooltip: t.action_reject,
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: _isValidId
                      ? () async {
                    final res = await _showRejectDialog(
                      context: context,
                      quotationId: quotationId,
                    );
                    if (res == null) return;

                    await vm.reject(
                      quotationId,
                      rejectCauseId: res.rejectCauseId,
                      rejectCause: res.rejectCauseNote,
                    );
                  }
                      : null,
                ),
              ),

              // ✅ OPEN ORDER (tylko Approved)
              slot(
                visible: _isApproved,
                child: IconButton(
                  tooltip: t.action_open_order, // jeśli nie masz, możesz podmienić na 'Zamówienie'
                  icon: const Icon(Icons.local_shipping_outlined),
                  onPressed: canOpenOrder
                      ? () => context.go('/order/${orderNrSl!.trim()}')
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final QuotationsListViewModel vm;
  const _PaginationBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Text(t.pagination_page("${vm.page}")),
          const SizedBox(width: 16),
          IconButton(
            onPressed: vm.page > 1 ? vm.prevPage : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: vm.isLastPage ? null : vm.nextPage,
            icon: const Icon(Icons.chevron_right),
          ),
          const Spacer(),
          DropdownButton<int>(
            value: vm.pageSize,
            onChanged: (v) => v == null ? null : vm.setPageSize(v),
            items: vm.pageSizeOptions
                .map((s) => DropdownMenuItem(value: s, child: Text("${t.pagination_page_size}: $s")))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RejectDialogResult {
  final int rejectCauseId;
  final String? rejectCauseNote;
  const _RejectDialogResult({required this.rejectCauseId, this.rejectCauseNote});
}

Future<_RejectDialogResult?> _showRejectDialog({
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
    return await showDialog<_RejectDialogResult?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odrzucić wycenę?'),
        content: const Text('Brak listy powodów. Odrzucić z domyślnym powodem?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Anuluj')),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              const _RejectDialogResult(rejectCauseId: 1),
            ),
            child: const Text('Odrzuć'),
          ),
        ],
      ),
    );
  }

  final isWide = MediaQuery.sizeOf(context).width >= 700;

  if (isWide) {
    return showDialog<_RejectDialogResult?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RejectDialog(
        quotationId: quotationId,
        causes: causes,
      ),
    );
  }

  return showModalBottomSheet<_RejectDialogResult?>(
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

class _RejectDialog extends StatefulWidget {
  final int quotationId;
  final List<RejectCausesDictionary> causes;
  const _RejectDialog({required this.quotationId, required this.causes});

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
            _RejectDialogResult(
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
  const _RejectBottomSheet({required this.quotationId, required this.causes});

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
                    _RejectDialogResult(
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
