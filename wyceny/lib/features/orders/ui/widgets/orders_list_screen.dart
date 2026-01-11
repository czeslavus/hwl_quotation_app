import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
import 'package:wyceny/features/orders/ui/viewmodels/orders_list_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/ui/widgets/common/neutral_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';
import 'package:wyceny/ui/widgets/common/secondary_action_button.dart';

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
      appBar: TopBarAppBar(authState: vm.auth),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: isPhone
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.orders_title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PositiveActionButton(
                        tooltip: t.action_new_order,
                        label: t.action_new_order,
                        icon: Icons.add,
                        showCaption: false,
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
                      PositiveActionButton(
                        onPressed: () => context.push('/order/new'),
                        icon: Icons.add,
                        label: t.action_new_order,
                        tooltip: t.action_new_order,
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AnnouncementsPanel(
              header: Text("${t.announcement_line} • ${t.overdue_info}"),
              body: Text("${t.announcement_line} • ${t.overdue_info}"),
            ),
          ),
          const Divider(height: 1),
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
                        : _OrdersTable(vm: vm),
          ),
          const Divider(height: 1),
          _PaginationBar(vm: vm),
        ],
      ),
    );
  }
}

class _ResponsiveFiltersBar extends StatefulWidget {
  final OrdersListViewModel vm;
  const _ResponsiveFiltersBar({required this.vm});

  @override
  State<_ResponsiveFiltersBar> createState() => _ResponsiveFiltersBarState();
}

class _ResponsiveFiltersBarState extends State<_ResponsiveFiltersBar> {
  DateTime? _deliveryFrom;
  DateTime? _deliveryTo;
  DateTime? _receiptFrom;
  DateTime? _receiptTo;
  final TextEditingController _customerNrCtrl = TextEditingController();
  final TextEditingController _deliveryZipCtrl = TextEditingController();
  final TextEditingController _receiptZipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deliveryFrom = widget.vm.deliveryStartDate;
    _deliveryTo = widget.vm.deliveryEndDate;
    _receiptFrom = widget.vm.receiptStartDate;
    _receiptTo = widget.vm.receiptEndDate;
    _customerNrCtrl.text = widget.vm.orderCustomerNr ?? '';
    _deliveryZipCtrl.text = widget.vm.deliveryZipCode ?? '';
    _receiptZipCtrl.text = widget.vm.receiptZipCode ?? '';
  }

  @override
  void dispose() {
    _customerNrCtrl.dispose();
    _deliveryZipCtrl.dispose();
    _receiptZipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vm = widget.vm;

    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;

    final fields = <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dateField(context: context, label: 'Odbiór od', value: _receiptFrom, onPick: (d) => setState(() => _receiptFrom = d)),
          const SizedBox(width: 8),
          _dateField(context: context, label: 'Odbiór do', value: _receiptTo, onPick: (d) => setState(() => _receiptTo = d)),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dateField(context: context, label: 'Dostawa od', value: _deliveryFrom, onPick: (d) => setState(() => _deliveryFrom = d)),
          const SizedBox(width: 8),
          _dateField(context: context, label: 'Dostawa do', value: _deliveryTo, onPick: (d) => setState(() => _deliveryTo = d)),
        ],
      ),
      SizedBox(
        width: 200,
        child: TextField(
          controller: _customerNrCtrl,
          decoration: const InputDecoration(labelText: 'Nr klienta'),
        ),
      ),
      SizedBox(
        width: 200,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: vm.deliveryCountry,
          decoration: InputDecoration(labelText: t.gen_dest_country),
          items: vm.countries
              .map((c) => DropdownMenuItem(
                    value: c.countryCode,
                    child: Text(CountryLocalizer.localize(c.country, context)),
                  ))
              .toList(),
          onChanged: (code) => setState(() => vm.deliveryCountry = code),
        ),
      ),
      SizedBox(
        width: 160,
        child: TextField(
          controller: _deliveryZipCtrl,
          decoration: const InputDecoration(labelText: 'Kod dostawy'),
        ),
      ),
      SizedBox(
        width: 160,
        child: TextField(
          controller: _receiptZipCtrl,
          decoration: const InputDecoration(labelText: 'Kod odbioru'),
        ),
      ),
      SizedBox(
        width: 200,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: vm.statusNr,
          decoration: InputDecoration(labelText: t.col_status),
          items: vm.statusOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(vm.statusLabel(s))))
              .toList(),
          onChanged: (s) => setState(() => vm.statusNr = s),
        ),
      ),
    ];

    void onApply() => vm.applyFilters(
          orderCustomerNr: _customerNrCtrl.text,
          deliveryStart: _deliveryFrom,
          deliveryEnd: _deliveryTo,
          receiptStart: _receiptFrom,
          receiptEnd: _receiptTo,
          status: vm.statusNr,
          deliveryCountry: vm.deliveryCountry,
          deliveryZip: _deliveryZipCtrl.text,
          receiptZip: _receiptZipCtrl.text,
        );

    void onClear() {
      setState(() {
        _deliveryFrom = null;
        _deliveryTo = null;
        _receiptFrom = null;
        _receiptTo = null;
        _customerNrCtrl.clear();
        _deliveryZipCtrl.clear();
        _receiptZipCtrl.clear();
        vm.statusNr = null;
        vm.deliveryCountry = null;
      });
      vm.applyFilters(
        orderCustomerNr: null,
        deliveryStart: null,
        deliveryEnd: null,
        receiptStart: null,
        receiptEnd: null,
        status: null,
        deliveryCountry: null,
        deliveryZip: null,
        receiptZip: null,
      );
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
                NeutralActionButton(
                  onPressed: onApply,
                  icon: Icons.filter_alt,
                  label: t.filter_apply,
                ),
                const SizedBox(width: 8),
                SecondaryActionButton(
                  onPressed: onClear,
                  icon: Icons.filter_alt_off,
                  label: t.filter_clear,
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
      width: 160,
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

class _OrdersTable extends StatelessWidget {
  final OrdersListViewModel vm;
  const _OrdersTable({required this.vm});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
                    columns: [
                      DataColumn(label: Text(t.col_order_nr)),
                      const DataColumn(label: Text('Trasa')),
                      const DataColumn(label: Text('Daty')),
                      const DataColumn(label: Text('Ładunki')),
                      DataColumn(label: Text(t.col_price)),
                      DataColumn(label: Text(t.col_status)),
                      DataColumn(label: Text(t.col_actions)),
                    ],
                    rows: vm.items.map((o) {
                      final receipt = '${o.receiptPoint.country} ${o.receiptPoint.zipCode}';
                      final delivery = '${o.deliveryPoint.country} ${o.deliveryPoint.zipCode}';
                      final receiptDate = o.receiptDateBegin?.toLocal().toString().split(' ').first ?? '—';
                      final deliveryDate = o.deliveryDateBegin?.toLocal().toString().split(' ').first ?? '—';

                      return DataRow(cells: [
                        DataCell(_twoLines(o.orderNr ?? '—', o.orderCustomerNr ?? '—')),
                        DataCell(_twoLines(receipt, delivery)),
                        DataCell(_twoLines(receiptDate, deliveryDate)),
                        DataCell(_twoLines('MP: ${o.itemsCount}', 'W: ${o.totalWeight.toStringAsFixed(1)} kg')),
                        DataCell(Text('${o.orderValue?.toStringAsFixed(2) ?? '0.00'} ${o.orderValueCurrency ?? ''}'.trim())),
                        DataCell(Text(vm.statusLabel(o.status))),
                        DataCell(_ActionsCell(vm: vm, orderId: o.orderId?.toString() ?? '')),
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
