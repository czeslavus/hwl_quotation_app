import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/app/navigation_refresh.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
import 'package:wyceny/features/orders/domain/models/order_model.dart';
import 'package:wyceny/features/orders/ui/viewmodels/orders_list_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/ui/widgets/common/danger_action_button.dart';
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
    return const _OrdersListViewBody();
  }
}

class _OrdersListViewBody extends StatefulWidget {
  const _OrdersListViewBody();

  @override
  State<_OrdersListViewBody> createState() => _OrdersListViewBodyState();
}

class _OrdersListViewBodyState extends State<_OrdersListViewBody> {
  String? _lastMatchedLocation;
  NavigationRefresh? _navigationRefresh;
  int _lastRefreshVersion = 0;

  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<NavigationRefresh>()) {
      _navigationRefresh = getIt<NavigationRefresh>();
      _lastRefreshVersion = _navigationRefresh!.ordersVersion;
      _navigationRefresh!.addListener(_handleRefreshSignal);
    }
  }

  @override
  void dispose() {
    _navigationRefresh?.removeListener(_handleRefreshSignal);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final matchedLocation = GoRouterState.of(context).matchedLocation;
    final shouldRefresh =
        _lastMatchedLocation != null &&
        _lastMatchedLocation != matchedLocation &&
        matchedLocation == '/order';
    _lastMatchedLocation = matchedLocation;

    if (shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OrdersListViewModel>().showLatest();
      });
    }
  }

  void _handleRefreshSignal() {
    final navigationRefresh = _navigationRefresh;
    if (navigationRefresh == null) return;

    final nextVersion = navigationRefresh.ordersVersion;
    if (_lastRefreshVersion == nextVersion) return;
    _lastRefreshVersion = nextVersion;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrdersListViewModel>().showLatest();
    });
  }

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
  final TextEditingController _deliveryZipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deliveryFrom = widget.vm.deliveryStartDate;
    _deliveryTo = widget.vm.deliveryEndDate;
    _receiptFrom = widget.vm.receiptStartDate;
    _receiptTo = widget.vm.receiptEndDate;
    _deliveryZipCtrl.text = widget.vm.deliveryZipCode ?? '';
  }

  @override
  void dispose() {
    _deliveryZipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vm = widget.vm;
    final countryItems = _countryItems(context, vm);
    final selectedCountry =
        countryItems.any((item) => item.value == vm.deliveryCountry)
        ? vm.deliveryCountry
        : null;

    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;

    final fields = <Widget>[
      _dateField(
        context: context,
        label: t.field_pickup_from,
        value: _receiptFrom,
        onPick: (d) => setState(() => _receiptFrom = d),
      ),
      _dateField(
        context: context,
        label: t.field_pickup_to,
        value: _receiptTo,
        onPick: (d) => setState(() => _receiptTo = d),
      ),
      _dateField(
        context: context,
        label: t.field_delivery_from,
        value: _deliveryFrom,
        onPick: (d) => setState(() => _deliveryFrom = d),
      ),
      _dateField(
        context: context,
        label: t.field_delivery_to,
        value: _deliveryTo,
        onPick: (d) => setState(() => _deliveryTo = d),
      ),
      SizedBox(
        width: 200,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: selectedCountry,
          decoration: InputDecoration(labelText: t.gen_dest_country),
          items: countryItems,
          onChanged: (code) => setState(() => vm.deliveryCountry = code),
        ),
      ),
      SizedBox(
        width: 160,
        child: TextField(
          controller: _deliveryZipCtrl,
          decoration: InputDecoration(labelText: t.gen_dest_zip),
        ),
      ),
      SizedBox(
        width: 200,
        child: DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: vm.statusId,
          decoration: InputDecoration(labelText: t.col_status),
          items: vm.statusOptions
              .map(
                (s) =>
                    DropdownMenuItem(value: s, child: Text(vm.statusLabel(s))),
              )
              .toList(),
          onChanged: (s) => setState(() => vm.statusId = s),
        ),
      ),
    ];

    void onApply() => vm.applyFilters(
      deliveryStart: _deliveryFrom,
      deliveryEnd: _deliveryTo,
      receiptStart: _receiptFrom,
      receiptEnd: _receiptTo,
      statusId: vm.statusId,
      deliveryCountry: vm.deliveryCountry,
      deliveryZip: _deliveryZipCtrl.text,
    );

    void onClear() {
      setState(() {
        _deliveryFrom = null;
        _deliveryTo = null;
        _receiptFrom = null;
        _receiptTo = null;
        _deliveryZipCtrl.clear();
        vm.statusId = null;
        vm.deliveryCountry = null;
      });
      vm.applyFilters(
        deliveryStart: null,
        deliveryEnd: null,
        receiptStart: null,
        receiptEnd: null,
        statusId: null,
        deliveryCountry: null,
        deliveryZip: null,
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

  List<DropdownMenuItem<String>> _countryItems(
    BuildContext context,
    OrdersListViewModel vm,
  ) {
    final seen = <String>{};
    final items = <DropdownMenuItem<String>>[];

    for (final country in vm.countries) {
      final code = country.countryCode.trim();
      if (code.isEmpty || code == '??' || !seen.add(code)) continue;
      items.add(
        DropdownMenuItem(
          value: code,
          child: Text(CountryLocalizer.localize(country.country, context)),
        ),
      );
    }

    return items;
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
                      DataColumn(label: Text(t.col_route)),
                      DataColumn(label: Text(t.col_dates)),
                      DataColumn(label: Text(t.col_loads)),
                      DataColumn(label: Text(t.col_price)),
                      DataColumn(label: Text(t.col_status)),
                      DataColumn(label: Text(t.col_actions)),
                    ],
                    rows: vm.items.map((o) {
                      final receipt =
                          '${o.receiptPoint.country} ${o.receiptPoint.zipCode}';
                      final delivery =
                          '${o.deliveryPoint.country} ${o.deliveryPoint.zipCode}';
                      final receiptDate =
                          o.receiptDateBegin
                              ?.toLocal()
                              .toString()
                              .split(' ')
                              .first ??
                          '—';
                      final deliveryDate =
                          o.deliveryDateBegin
                              ?.toLocal()
                              .toString()
                              .split(' ')
                              .first ??
                          '—';

                      return DataRow(
                        cells: [
                          DataCell(
                            _twoLines(
                              o.orderNr ?? '—',
                              o.orderCustomerNr ?? '—',
                            ),
                          ),
                          DataCell(_twoLines(receipt, delivery)),
                          DataCell(_twoLines(receiptDate, deliveryDate)),
                          DataCell(
                            _twoLines(
                              'MP: ${o.itemsCount}',
                              'W: ${o.totalWeight.toStringAsFixed(1)} kg',
                            ),
                          ),
                          DataCell(
                            Text(
                              '${o.orderValue?.toStringAsFixed(2) ?? '0.00'} ${o.orderValueCurrency ?? ''}'
                                  .trim(),
                            ),
                          ),
                          DataCell(
                            Text(
                              vm.statusLabel(o.statusId, fallback: o.status),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: _ActionsCell(
                                vm: vm,
                                orderId: o.orderId?.toString() ?? '',
                                order: o,
                              ),
                            ),
                          ),
                        ],
                      );
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
  final OrderModel order;
  const _ActionsCell({
    required this.vm,
    required this.orderId,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: 240,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeutralActionButton(
              label: t.action_view,
              icon: Icons.visibility_outlined,
              showCaption: false,
              onPressed: () => context.go('/order/$orderId/view', extra: order),
            ),
            const SizedBox(width: 6),
            NeutralActionButton(
              label: t.action_edit,
              icon: Icons.edit_outlined,
              showCaption: false,
              onPressed: () => context.go('/order/$orderId'),
            ),
            const SizedBox(width: 6),
            SecondaryActionButton(
              label: t.action_copy,
              icon: Icons.copy_outlined,
              showCaption: false,
              onPressed: () => vm.copy(orderId),
            ),
            const SizedBox(width: 6),
            DangerActionButton(
              label: t.action_cancel,
              icon: Icons.cancel_outlined,
              showCaption: false,
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
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text("${t.pagination_page_size}: $s"),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
