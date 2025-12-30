import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/common/top_bar_appbar.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_list_actions_cell.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotations_list_viewmodel.dart';
import 'package:wyceny/ui/widgets/common/neutral_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';
import 'package:wyceny/ui/widgets/common/secondary_action_button.dart';

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
        authState: vm.auth,
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
                PositiveActionButton(
                  tooltip: t.action_new_quotation,
                  label: t.action_new_quotation,
                  icon: Icons.add,
                  showCaption: false,
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
                PositiveActionButton(
                  onPressed: () => context.push('/quote/new'),
                  icon: Icons.add,
                  label: t.action_new_quotation,
                  tooltip: t.action_new_quotation
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
                            child: QuotationListActionsCell(
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

