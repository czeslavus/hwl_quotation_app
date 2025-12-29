import 'package:flutter/material.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class QuotationQuoteDetailsPanel extends StatelessWidget {
  const QuotationQuoteDetailsPanel({
    super.key,
    required this.vm,
  });

  final QuotationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    if (!vm.hasQuote || vm.totalPrice == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${t.fee_total}: ${vm.totalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Icon(Icons.tune),
              const SizedBox(width: 6),
              Text(t.details),
            ],
          ),
          children: [
            if (vm.quoteLines.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(t.no_details),
              )
            else
              ...vm.quoteLines.map((line) {
                final idx = line['index']?.toString() ?? '';
                final price = (line['price'] as num?)?.toDouble() ?? 0.0;
                final adr = (line['adr'] as bool?) ?? false;
                final qty = line['qty']?.toString() ?? '';
                return ListTile(
                  dense: true,
                  leading: Text('#$idx'),
                  title: Text('${t.item_qty}: $qty'),
                  subtitle: Text('ADR: ${adr ? t.yes : t.no}'),
                  trailing: Text(price.toStringAsFixed(2)),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
