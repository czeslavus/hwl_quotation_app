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

    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;

    return Scaffold(
      appBar: TopBarAppBar(
        customerName: vm.customerName,
        contractorName: vm.contractorName,
        onLogout: () {/* TODO: logout */},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nagłówek + przycisk Nowa wycena (ikonowy na telefonie)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: isPhone
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.quotations_title,
                          style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                _NewQuotationButton(
                  onPressed: () => context.push('/quote/new'),
                ),
              ],
            ),
          ),

          // Ogłoszenia – pełna szerokość, rozwijane (bez własnego scrolla)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _AnnouncementsPanel(
              header: Text("${t.announcement_line} • ${t.overdue_info}"),
              // Jeśli chcesz, wrzuć tu bogatszą treść/HTML do środka:
              body: Text("${t.announcement_line} • ${t.overdue_info}"),
            ),
          ),

          const Divider(height: 1),

          // Filtry – responsywne: na telefonie przyciski to ikony; na szerokim ekr. przyciski w 1 linii po prawej
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _ResponsiveFiltersBar(vm: vm),
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

class _AnnouncementsPanel extends StatefulWidget {
  final Widget header;
  final Widget body;
  const _AnnouncementsPanel({required this.header, required this.body});

  @override
  State<_AnnouncementsPanel> createState() => _AnnouncementsPanelState();
}

class _AnnouncementsPanelState extends State<_AnnouncementsPanel>
    with TickerProviderStateMixin {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nagłówek – klikalny, przełącza rozwinięcie
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Treść nagłówka
                  Expanded(
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!,
                      child: widget.header,
                    ),
                  ),
                  // Strzałka z animacją obrotu
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0, // 0.5 obrotu = strzałka w górę
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),

          // Treść rozwijana – bez własnego przewijania
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: widget.body,
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Telefon: duży, zielony, idealnie wyśrodkowany przycisk z ikoną „+”
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
          minimumSize: const Size(52, 52), // rozmiar koła
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

/// Pasek filtrów:
/// - pola mogą się łamać (Wrap)
/// - na wąskich ekranach przyciski = same ikony
/// - na szerokich ekranach przyciski zawsze w jednej linii po prawej
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
    final t = AppLocalizations.of(context)!;
    final vm = widget.vm;

    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;

    final fields = <Widget>[
      // Zakres dat (zachowuję Twoje _dateField)
      Row(mainAxisSize: MainAxisSize.min, children: [
        _dateField(context: context, label: t.filter_date_from, value: _from, onPick: (d) => setState(() => _from = d)),
        const SizedBox(width: 8),
        _dateField(context: context, label: t.filter_date_to, value: _to, onPick: (d) => setState(() => _to = d)),
      ]),
      // Kraj nadania
      SizedBox(
        width: 240,
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          value: vm.originCountryId,
          decoration: InputDecoration(labelText: t.gen_origin_country),
          items: vm.countries
              .map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(CountryLocalizer.localize(c.country, context)),
          ))
              .toList(),
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
          items: vm.countries
              .map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(CountryLocalizer.localize(c.country, context)),
          ))
              .toList(),
          onChanged: (id) => setState(() => vm.destCountryId = id),
        ),
      ),
    ];

    final onApply = () => vm.applyFilters(from: _from, to: _to, originId: vm.originCountryId, destId: vm.destCountryId);
    final onClear = () {
      setState(() {
        _from = null;
        _to = null;
        vm.originCountryId = null;
        vm.destCountryId = null;
      });
      vm.applyFilters(from: null, to: null, originId: null, destId: null);
    };

    if (isPhone) {
      // 🔹 Wersja mobilna – małe ikonowe przyciski
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

// 🔹 Szeroki ekran – pola + przyciski po prawej, łamane elastycznie
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            // ✅ Lewa część: pola filtrów
            ConstrainedBox(
              constraints: BoxConstraints(
                // pozwól polom zająć do ~80% szerokości kontenera
                maxWidth: constraints.maxWidth * 0.8,
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: fields,
              ),
            ),

            // ✅ Prawa część: przyciski akcji
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
                  DataCell(_c(Text(q.ttTime ?? "—"),                                width: 140)), // TODO: podmień na validTo jeśli masz
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
                  const DataCell(SizedBox()), // wypełnia kolumnę "Actions" stałą szerokością
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// --- Reszta Twoich klas: _ActionsCell, _RowActions, _PaginationBar ---
// (bez zmian, możesz pozostawić jak w Twoim kodzie)

class _ActionsCell extends StatelessWidget {
  final Quotation quotation;
  final QuotationsListViewModel vm;
  const _ActionsCell({required this.quotation, required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SizedBox(
      width: 220,
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
              onPressed: () {/* TODO */},
            ),
            IconButton(
              tooltip: t.action_copy,
              icon: const Icon(Icons.copy_outlined),
              onPressed: () async {
                await vm.copy(quotation.id!);
              },
            ),
            IconButton(
              tooltip: t.action_reject,
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () {/* TODO */},
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
          onPressed: () {},
        ),
        IconButton(
          tooltip: t.action_copy,
          icon: const Icon(Icons.copy_outlined),
          onPressed: () async {
            final _ = await vm.copy(q.id!);
          },
        ),
        IconButton(
          tooltip: t.action_reject,
          icon: const Icon(Icons.cancel_outlined),
          onPressed: () {},
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
