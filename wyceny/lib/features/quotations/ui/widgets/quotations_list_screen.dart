import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
import 'package:wyceny/features/quotations/domain/models/quotation.dart';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEWA: filtry (Wrap)
                Expanded(child: _FiltersLeft(vm: vm)),
                const SizedBox(width: 12),
                // PRAWA: zielony przycisk "Nowa wycena"
                _NewQuotationButton(onPressed: () {
                  context.push('/quote/new');
                }),
              ],
            ),
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

class _NewQuotationButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewQuotationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(t.action_new_quotation),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green), // zielony
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}

class _FiltersLeft extends StatefulWidget {
  final QuotationsListViewModel vm;
  const _FiltersLeft({required this.vm});
  @override
  State<_FiltersLeft> createState() => _FiltersLeftState();
}

class _FiltersLeftState extends State<_FiltersLeft> {
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
        Row(mainAxisSize: MainAxisSize.min, children: [
          _dateField(context: context, label: t.filter_date_from, value: _from, onPick: (d) => setState(() => _from = d)),
          const SizedBox(width: 8),
          _dateField(context: context, label: t.filter_date_to, value: _to, onPick: (d) => setState(() => _to = d)),
        ]),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: vm.originCountryId,
            decoration: InputDecoration(labelText: t.gen_origin_country),
            items: vm.countries.map((c) => DropdownMenuItem(
              value: c.id, child: Text(CountryLocalizer.localize(c.country, context)),
            )).toList(),
            onChanged: (id) => setState(() => vm.originCountryId = id),
          ),
        ),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: vm.destCountryId,
            decoration: InputDecoration(labelText: t.gen_dest_country),
            items: vm.countries.map((c) => DropdownMenuItem(
              value: c.id, child: Text(CountryLocalizer.localize(c.country, context)),
            )).toList(),
            onChanged: (id) => setState(() => vm.destCountryId = id),
          ),
        ),
        FilledButton.icon(
          onPressed: () => vm.applyFilters(from: _from, to: _to, originId: vm.originCountryId, destId: vm.destCountryId),
          icon: const Icon(Icons.filter_alt),
          label: Text(t.filter_apply),
        ),
        TextButton(onPressed: () { setState(() { _from = null; _to = null; }); vm.applyFilters(from: null, to: null, originId: null, destId: null); },
          child: Text(t.filter_clear),
        ),
      ],
    );
  }

  Widget _dateField({required BuildContext context, required String label, required DateTime? value, required ValueChanged<DateTime?> onPick}) {
    return SizedBox(
      width: 190,
      child: InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(context: context, initialDate: value ?? now, firstDate: DateTime(now.year - 2), lastDate: DateTime(now.year + 1));
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

    const double kMinTableWidth = 1400;

    Widget _h(String s, {double? w}) =>
        SizedBox(width: w, child: Text(s, overflow: TextOverflow.ellipsis));
    Widget _c(Widget w, {double? width}) =>
        width == null ? w : SizedBox(width: width, child: w);

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: kMinTableWidth),
          child: DataTable(
            columnSpacing: 16,
            headingRowHeight: 48,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 64,
            columns: [
              DataColumn(label: _h(t.col_qnr,            w: 120)),
              DataColumn(label: _h(t.col_order_nr,       w: 140)),
              DataColumn(label: _h(t.col_status,         w: 140)),
              DataColumn(label: _h(t.col_created,        w: 120)),
              DataColumn(label: _h(t.col_valid_to,       w: 140)),
              DataColumn(label: _h(t.col_decision_date,  w: 160)),
              DataColumn(label: _h(t.col_origin_country, w: 160)),
              DataColumn(label: _h(t.col_origin_zip,     w: 120)),
              DataColumn(label: _h(t.col_dest_country,   w: 180)),
              DataColumn(label: _h(t.col_dest_zip,       w: 120)),
              DataColumn(label: _h(t.col_mp_sum,         w: 100)),
              DataColumn(label: _h(t.col_weight,         w: 100)),
              DataColumn(label: _h(t.col_price,          w: 120)),
              DataColumn(label: _h(t.col_actions,        w: 220)),
            ],
            rows: vm.items.map<DataRow>((q) {
              final mp = (q.quotationItems ?? const [])
                  .fold<double>(0.0, (s, it) => s + (it.ldm ?? 0));

              return DataRow(
                cells: [
                  DataCell(_c(Text(q.id?.toString() ?? q.guid ?? "-"),              width: 120)),
                  DataCell(_c(Text(q.orderNrSl ?? "—"),                             width: 140)),
                  DataCell(_c(Text(vm.statusLabel(q.status)),                       width: 140)),
                  DataCell(_c(Text(q.createDate?.toLocal().toString().split(' ').first ?? "—"),
                      width: 120)),
                  DataCell(_c(Text(q.ttTime ?? "—"),                                width: 140)), // podmień na validTo jeśli masz
                  DataCell(_c(Text(q.orderDateSl?.toLocal().toString().split(' ').first ?? "—"),
                      width: 160)),
                  DataCell(_c(Text(vm.localizeCountryName(q.receiptCountry, context)),
                      width: 160)),
                  DataCell(_c(Text(q.receiptZipCode),                               width: 120)),
                  DataCell(_c(Text(vm.localizeCountryName(q.deliveryCountry, context)),
                      width: 180)),
                  DataCell(_c(Text(q.deliveryZipCode),                              width: 120)),
                  DataCell(_c(Text(mp.toStringAsFixed(2)),                          width: 100)),
                  DataCell(_c(Text((q.weightChgw ?? 0).toStringAsFixed(2)),         width: 100)),
                  DataCell(_c(Text((q.allIn ?? q.shippingPrice ?? 0).toStringAsFixed(2)),
                      width: 120)),
                  DataCell(_ActionsCell(quotation: q, vm: vm)), // ⬅️ akcje w stałej szerokości
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final Quotation quotation;
  final QuotationsListViewModel vm;
  const _ActionsCell({required this.quotation, required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SizedBox(
      width: 220, // dopasowane do szerokości kolumny "Actions"
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: t.action_submit,
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => vm.approve(quotation.id!),
            ),
            IconButton(
              tooltip: t.action_edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: np. context.push('/quote/${quotation.id}')
              },
            ),
            IconButton(
              tooltip: t.action_copy,
              icon: const Icon(Icons.copy_outlined),
              onPressed: () async {
                await vm.copy(quotation.id!);
                // TODO: nawigacja/refresh, jeśli chcesz
              },
            ),
            IconButton(
              tooltip: t.action_reject,
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () {
                // TODO: dialog z powodem + vm.reject(...)
              },
            ),
          ],
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
