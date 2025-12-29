import 'package:flutter/material.dart';
import 'package:wyceny/features/quotations/domain/models/quotation_item.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/ui/widgets/common/danger_action_button.dart';

class QuotationItemsTable extends StatefulWidget {
  const QuotationItemsTable({
    super.key,
    required this.vm,
  });

  final QuotationViewModel vm;

  @override
  State<QuotationItemsTable> createState() => _QuotationItemsTableState();
}

class _QuotationItemsTableState extends State<QuotationItemsTable> {
  final _hController = ScrollController();

  @override
  void dispose() {
    _hController.dispose();
    super.dispose();
  }

  // kompaktowe szerokości
  static const _wXS = 62.0;
  static const _wS = 76.0;
  static const _wM = 92.0;
  static const _wL = 120.0;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final t = AppLocalizations.of(context);

    if (vm.items.isEmpty) {
      return _EmptyBox(text: t.items_empty_hint);
    }

    return LayoutBuilder(
      builder: (context, c) {
        // DataTable nie skaluje się responsywnie – więc zawsze dajemy H-scroll,
        // a w środku minimum szerokości tak, by nagłówki nie "ściskały" pól.
        final minWidth = c.maxWidth < 900 ? 1100.0 : c.maxWidth;

        return Scrollbar(
          controller: _hController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _hController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth),
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 54,
                horizontalMargin: 8,
                columnSpacing: 10,
                columns: [
                  const DataColumn(label: Text('ADR')),
                  DataColumn(label: Text(t.item_qty)),
                  DataColumn(label: Text(t.item_len_cm)),
                  DataColumn(label: Text(t.item_wid_cm)),
                  DataColumn(label: Text(t.item_hei_cm)),
                  DataColumn(label: Text(t.item_w_unit)),
                  DataColumn(label: Text(t.item_pack_type)),
                  DataColumn(label: Text(t.item_w_unit)),
                  DataColumn(label: Text(t.item_cbm)),
                  DataColumn(label: Text(t.item_lbm)),
                  DataColumn(label: Text(t.item_ldm_cbm)),
                  DataColumn(label: Text(t.item_long_weight)),
                  const DataColumn(label: Text('')),
                ],
                rows: List.generate(vm.items.length, (i) => _row(context, i, vm.items[i])),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _row(BuildContext context, int index, QuotationItem it) {
    final vm = widget.vm;
    final t = AppLocalizations.of(context);
    final adrColor = it.adr ? Colors.red : Colors.grey;

    return DataRow(
      cells: [
        DataCell(
          IconButton(
            tooltip: 'ADR',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.warning_amber_rounded, color: adrColor),
            onPressed: () {
              // TODO: docelowo otwiera okno ADR; na razie toggle
              vm.toggleAdr(index);
            },
          ),
        ),
        DataCell(_intField(width: _wXS, value: it.quantity, onChanged: (v) => vm.updateItem(index, it.copyWith(quantity: v)))),
        DataCell(_intField(width: _wS, value: it.length, onChanged: (v) => vm.updateItem(index, it.copyWith(length: v)))),
        DataCell(_intField(width: _wS, value: it.width, onChanged: (v) => vm.updateItem(index, it.copyWith(width: v)))),
        DataCell(_intField(width: _wS, value: it.height, onChanged: (v) => vm.updateItem(index, it.copyWith(height: v)))),
        DataCell(_intField(width: _wS, value: it.weight, onChanged: (v) => vm.updateItem(index, it.copyWith(weight: v)))),
        DataCell(_packagingDropdown(
          width: _wL,
          selectedId: it.packaging,
          onChanged: (id) => vm.updateItem(index, it.copyWith(packaging: id)),
          units: vm.packagingUnits,
        )),
        DataCell(_doubleField(width: _wM, value: it.packagingWeight, onChanged: (v) => vm.updateItem(index, it.copyWith(packagingWeight: v)))),
        DataCell(_doubleField(width: _wM, value: it.cbm, onChanged: (v) => vm.updateItem(index, it.copyWith(cbm: v)))),
        DataCell(_doubleField(width: _wM, value: it.ldm, onChanged: (v) => vm.updateItem(index, it.copyWith(ldm: v)))),
        DataCell(_doubleField(width: _wM, value: it.ldmCbm, onChanged: (v) => vm.updateItem(index, it.copyWith(ldmCbm: v)))),
        DataCell(_doubleField(width: _wM, value: it.longWeight, onChanged: (v) => vm.updateItem(index, it.copyWith(longWeight: v)))),
        DataCell(
          DangerActionButton(
            icon: Icons.delete_outline,
            label: t.item_delete_tt,
            showCaption: false,
            tooltip: t.item_delete_tt,
            onPressed: () => vm.removeItemAt(index),
          ),
        ),
      ],
    );
  }

  InputDecoration _cellDeco() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    border: OutlineInputBorder(),
  );

  TextStyle _cellStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);

  Widget _intField({
    required double width,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        style: _cellStyle(context),
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        decoration: _cellDeco(),
        onChanged: (s) {
          final v = int.tryParse(s.trim());
          if (v == null) return;
          onChanged(v);
        },
      ),
    );
  }

  Widget _doubleField({
    required double width,
    required double? value,
    required ValueChanged<double?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        style: _cellStyle(context),
        initialValue: value?.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _cellDeco(),
        onChanged: (s) {
          final raw = s.trim();
          if (raw.isEmpty) return onChanged(null);
          final v = double.tryParse(raw.replaceAll(',', '.'));
          if (v == null) return;
          onChanged(v);
        },
      ),
    );
  }

  Widget _packagingDropdown({
    required double width,
    required int? selectedId,
    required ValueChanged<int?> onChanged,
    required List<dynamic> units,
  }) {
    final Map<int, String> byId = {};
    for (final u in units) {
      final id = u.loadUnitTypeId;
      if (id == null) continue;
      byId.putIfAbsent(id, () {
        final lbl = u.loadUnitTypeName.trim();
        return lbl.isNotEmpty ? lbl : id.toString();
      });
    }

    final dropdownItems = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('—')),
      ...byId.entries.map((e) => DropdownMenuItem<int?>(value: e.key, child: Text(e.value))),
    ];

    final safeValue = (selectedId != null && byId.containsKey(selectedId)) ? selectedId : null;

    return SizedBox(
      width: width,
      child: DropdownButtonFormField<int?>(
        isDense: true,
        value: safeValue,
        items: dropdownItems,
        decoration: _cellDeco(),
        onChanged: onChanged,
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
