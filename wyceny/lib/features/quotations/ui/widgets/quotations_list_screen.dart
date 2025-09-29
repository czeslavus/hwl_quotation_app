import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: TopBarAppBar(
        customerName: vm.customerName,
        contractorName: vm.contractorName,
        onLogout: () {/* TODO: logout */},
      ),
      body: Column(
        children: [
          // Nagłówek + informacje
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.quotations_title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text("${t.announcement_line} • ${t.overdue_info}"),
              ],
            ),
          ),
          // Filtry
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _FiltersBar(vm: vm),
          ),
          const Divider(height: 1),

          // Lista
          Expanded(
            child: vm.loading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                ? Center(child: Text(t.error_generic(vm.error.toString())))
                : vm.items.isEmpty
                ? Center(child: Text(t.list_empty))
                : _QuotationsTable(vm: vm),
          ),

          // Paginacja na dole
          const Divider(height: 1),
          _PaginationBar(vm: vm),
        ],
      ),
    );
  }
}

class _FiltersBar extends StatefulWidget {
  final QuotationsListViewModel vm;
  const _FiltersBar({required this.vm});

  @override
  State<_FiltersBar> createState() => _FiltersBarState();
}

class _FiltersBarState extends State<_FiltersBar> {
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
    final t = AppLocalizations.of(context)!;
    final vm = widget.vm;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Zakres dat
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
        // Kraj nadania
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: vm.originCountryId,
            decoration: InputDecoration(labelText: t.gen_origin_country),
            items: vm.countries.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text(CountryLocalizer.localize(c.country, context)),
            )).toList(),
            onChanged: (id) => setState(() => vm.originCountryId = id),
          ),
        ),
        // Kraj dostawy
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: vm.destCountryId,
            decoration: InputDecoration(labelText: t.gen_dest_country),
            items: vm.countries.map((c) => DropdownMenuItem(
              value: c.id,
              child: Text(CountryLocalizer.localize(c.country, context)),
            )).toList(),
            onChanged: (id) => setState(() => vm.destCountryId = id),
          ),
        ),

        // Zastosuj
        FilledButton.icon(
          onPressed: () => vm.applyFilters(
            from: _from, to: _to,
            originId: vm.originCountryId,
            destId: vm.destCountryId,
          ),
          icon: const Icon(Icons.filter_alt),
          label: Text(t.filter_apply),
        ),
        // Wyczyść
        TextButton(
          onPressed: () {
            setState(() { _from = null; _to = null; });
            vm.applyFilters(from: null, to: null, originId: null, destId: null);
          },
          child: Text(t.filter_clear),
        ),
      ],
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
          final first = DateTime(now.year - 2);
          final last = DateTime(now.year + 1);
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? now,
            firstDate: first,
            lastDate: last,
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
    final t = AppLocalizations.of(context)!;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1200),
          child: DataTable(
            columns: [
              DataColumn(label: Text(t.col_qnr)),
              DataColumn(label: Text(t.col_order_nr)),
              DataColumn(label: Text(t.col_status)),
              DataColumn(label: Text(t.col_created)),
              DataColumn(label: Text(t.col_valid_to)),
              DataColumn(label: Text(t.col_decision_date)),
              DataColumn(label: Text(t.col_origin_country)),
              DataColumn(label: Text(t.col_origin_zip)),
              DataColumn(label: Text(t.col_dest_country)),
              DataColumn(label: Text(t.col_dest_zip)),
              DataColumn(label: Text(t.col_mp_sum)),
              DataColumn(label: Text(t.col_weight)),
              DataColumn(label: Text(t.col_price)),
              DataColumn(label: Text(t.col_actions)),
            ],
            rows: vm.items.map((q) {
              final mp = (q.quotationItems ?? const [])
                  .fold<double>(0.0, (s, it) => s + (it.ldm ?? 0));
              return DataRow(cells: [
                DataCell(Text(q.id?.toString() ?? q.guid ?? "-")),
                DataCell(Text(q.orderNrSl ?? "—")),
                DataCell(Text(vm.statusLabel(q.status))),
                DataCell(Text(q.createDate?.toLocal().toString().split(' ').first ?? "—")),
                DataCell(Text(q.ttTime ?? "—")), // brak pola 'validTo' w modelu -> używam ttTime jako placeholder
                DataCell(Text(q.orderDateSl?.toLocal().toString().split(' ').first ?? "—")),
                DataCell(Text(vm.localizeCountryName(q.receiptCountry, context))),
                DataCell(Text(q.receiptZipCode)),
                DataCell(Text(vm.localizeCountryName(q.deliveryCountry, context))),
                DataCell(Text(q.deliveryZipCode)),
                DataCell(Text(mp.toStringAsFixed(2))),
                DataCell(Text((q.weightChgw ?? 0).toStringAsFixed(2))),
                DataCell(Text((q.allIn ?? q.shippingPrice ?? 0).toStringAsFixed(2))),
                DataCell(_RowActions(q: q, vm: vm)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  final Quotation q;
  final QuotationsListViewModel vm;
  const _RowActions({required this.q, required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 6,
      children: [
        IconButton(
          tooltip: t.action_submit,
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => vm.approve(q.id!),
        ),
        IconButton(
          tooltip: t.action_edit,
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            // TODO: nawigacja do edycji, np. context.push('/quotation/${q.id}')
          },
        ),
        IconButton(
          tooltip: t.action_copy,
          icon: const Icon(Icons.copy_outlined),
          onPressed: () async {
            final nq = await vm.copy(q.id!);
            // TODO: przejście do nowej wyceny nq.id
          },
        ),
        IconButton(
          tooltip: t.action_reject,
          icon: const Icon(Icons.cancel_outlined),
          onPressed: () {
            showDialog(context: context, builder: (_) {
              String? reason;
              return AlertDialog(
                title: Text(t.action_reject),
                content: TextField(decoration: InputDecoration(labelText: t.reason_optional),
                    onChanged: (v) => reason = v),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
                  FilledButton(onPressed: () { Navigator.pop(context); vm.reject(q.id!, reason: reason); }, child: Text(t.ok)),
                ],
              );
            });
          },
        ),
      ],
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final QuotationsListViewModel vm;
  const _PaginationBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
