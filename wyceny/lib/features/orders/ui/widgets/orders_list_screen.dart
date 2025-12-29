import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';

import 'package:wyceny/features/orders/ui/viewmodels/orders_list_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<OrdersListViewModel>()..init(),
      child: const _OrdersListView(),
    );
  }
}

class _OrdersListView extends StatelessWidget {
  const _OrdersListView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrdersListViewModel>();
    final t = AppLocalizations.of(context);

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
          // Nagłówek + „Nowe zamówienie”
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: isPhone
                ? Row(
              children: [
                Expanded(
                  child: Text(
                    t.orders_title, // dodaj w l10n (np. „Zamówienia”)
                    style: Theme.of(context).textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _NewOrderCompactButton(
                  tooltip: t.action_new_order, // dodaj w l10n
                  onPressed: () => context.push('/order/new'),
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: Text(
                    t.orders_title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                _NewOrderButton(
                  onPressed: () => context.push('/order/new'),
                ),
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

          // Filtry
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
                : _OrdersTable(vm: vm),
          ),

          const Divider(height: 1),
          _PaginationBar(vm: vm),
        ],
      ),
    );
  }
}

// ————— Akcje nagłówka —————

class _NewOrderCompactButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;
  const _NewOrderCompactButton({required this.onPressed, this.tooltip});

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

class _NewOrderButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewOrderButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(t.action_new_order),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.green),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}

// ————— Pasek filtrów —————

class _ResponsiveFiltersBar extends StatefulWidget {
  final OrdersListViewModel vm;
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
        _dateField(context: context, label: t.filter_date_from, value: _from, onPick: (d) => setState(() => _from = d)),
        const SizedBox(width: 8),
        _dateField(context: context, label: t.filter_date_to, value: _to, onPick: (d) => setState(() => _to = d)),
      ]),
      SizedBox(
        width: 220,
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: vm.originCountryId,
          decoration: InputDecoration(labelText: t.gen_origin_country),
          items: vm.countries
              .map((c) => DropdownMenuItem(
            value: c.countryId,
            child: Text(CountryLocalizer.localize(c.country, context)),
          ))
              .toList(),
          onChanged: (id) => setState(() => vm.originCountryId = id),
        ),
      ),
      SizedBox(
        width: 220,
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
      SizedBox(
        width: 200,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: vm.status,
          decoration: InputDecoration(labelText: t.col_status),
          items: vm.statusOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(vm.statusLabel(s))))
              .toList(),
          onChanged: (s) => setState(() => vm.status = s),
        ),
      ),
    ];

    void onApply() => vm.applyFilters(from: _from, to: _to, originId: vm.originCountryId, destId: vm.destCountryId, status: vm.status);
    void onClear() {
      setState(() {
        _from = null;
        _to = null;
        vm.originCountryId = null;
        vm.destCountryId = null;
        vm.status = null;
      });
      vm.applyFilters(from: null, to: null, originId: null, destId: null, status: null);
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
            child: IconButton.filled(onPressed: onApply, icon: const Icon(Icons.filter_alt)),
          ),
          Tooltip(
            message: t.filter_clear,
            child: IconButton.outlined(onPressed: onClear, icon: const Icon(Icons.filter_alt_off)),
          ),
        ],
      );
    }

    // szeroko: przyciski po prawej, tylko gdy jest miejsce na pola
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

// ————— Tabela —————

class _OrdersTable extends StatelessWidget {
  final OrdersListViewModel vm;
  const _OrdersTable({required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const double kMinTableWidth = 1400;

    Widget h(String s, {double? w}) =>
        SizedBox(width: w, child: Text(s, overflow: TextOverflow.ellipsis));
    Widget c(Widget w, {double? width}) =>
        width == null ? w : SizedBox(width: width, child: w);

    final hCtrl = ScrollController();
    final vCtrl = ScrollController();

    final table = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: kMinTableWidth),
      child: DataTable(
        columnSpacing: 16,
        headingRowHeight: 48,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 64,
        columns: [
          DataColumn(label: h(t.col_order_nr,       w: 140)),
          DataColumn(label: h(t.col_status,         w: 140)),
          DataColumn(label: h(t.col_created,        w: 140)),
          DataColumn(label: h(t.col_origin_country, w: 160)),
          DataColumn(label: h(t.col_origin_zip,     w: 120)),
          DataColumn(label: h(t.col_dest_country,   w: 180)),
          DataColumn(label: h(t.col_dest_zip,       w: 120)),
          DataColumn(label: h(t.col_items_count,    w: 120)),
          DataColumn(label: h(t.col_weight,         w: 120)),
          DataColumn(label: h(t.col_price,          w: 140)),
          DataColumn(label: h(t.col_actions,        w: 220)),
        ],
        rows: vm.items.map<DataRow>((o) => DataRow(cells: [
          DataCell(c(Text(o.orderNr ?? o.id ?? "—"),                    width: 140)),
          DataCell(c(Text(vm.statusLabel(o.status)),                     width: 140)),
          DataCell(c(Text(o.createdAt?.toLocal().toString().split(' ').first ?? "—"), width: 140)),
          DataCell(c(Text(vm.localizeCountryName(o.originCountry, context)),          width: 160)),
          DataCell(c(Text(o.originZip ?? "—"),                           width: 120)),
          DataCell(c(Text(vm.localizeCountryName(o.destCountry, context)),            width: 180)),
          DataCell(c(Text(o.destZip ?? "—"),                             width: 120)),
          DataCell(c(Text("${o.itemsCount}"),                            width: 120)),
          DataCell(c(Text(o.weightChg?.toStringAsFixed(2) ?? "0.00"),    width: 120)),
          DataCell(c(Text(o.total?.toStringAsFixed(2) ?? "0.00"),        width: 140)),
          DataCell(_ActionsCell(vm: vm, orderId: o.id!)),
        ])).toList(),
      ),
    );

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
            constraints: const BoxConstraints(minWidth: 1400),
            child: SingleChildScrollView(
              controller: vCtrl,
              padding: const EdgeInsets.only(bottom: 80), // miejsce na paginację
              child: table,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final OrdersListViewModel vm;
  final String orderId;
  const _ActionsCell({required this.vm, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: 220,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: t.action_view,
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => vm.view(orderId),
            ),
            IconButton(
              tooltip: t.action_edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => vm.edit(orderId),
            ),
            IconButton(
              tooltip: t.action_copy,
              icon: const Icon(Icons.copy_outlined),
              onPressed: () => vm.copy(orderId),
            ),
            IconButton(
              tooltip: t.action_cancel,
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => vm.cancel(orderId),
            ),
          ],
        ),
      ),
    );
  }
}

// ————— Paginacja —————

class _PaginationBar extends StatelessWidget {
  final OrdersListViewModel vm;
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
