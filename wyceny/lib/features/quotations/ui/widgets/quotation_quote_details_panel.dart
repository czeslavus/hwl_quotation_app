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

    if (!vm.hasQuote) return const SizedBox.shrink();

    final rows = <_FeeRow>[
      _FeeRow('insurancePrice', vm.insurancePrice),
      _FeeRow('additionalServicePrice', vm.additionalServicePrice),
      _FeeRow('adrPrice', vm.adrPrice),
      _FeeRow('shippingPrice', vm.shippingPrice),
      _FeeRow('baf', vm.baf),
      _FeeRow('taf', vm.taf),
      _FeeRow('inflCorrection', vm.inflCorrection),
    ].where((r) => r.value.abs() > 0.000001).toList(growable: false);

    // jeśli wszystkie = 0, nadal pokażemy total (może API zwróciło 0)
    final total = vm.totalPrice;

    return AbsorbPointer(
      absorbing: vm.isUiLocked, // blokada interakcji w trakcie długiej wyceny / ładowań
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ExpansionTile(
            key: ValueKey('quotePanel_v${vm.quoteVersion}'),
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: vm.quotePanelOpen, // panel domyślnie otwarty po wycenie
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${t.fee_total}: ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (vm.isSubmitting) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.tune),
                const SizedBox(width: 6),
                Text(t.details),
              ],
            ),
            children: [
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(t.no_details),
                )
              else
                ...rows.map((r) => ListTile(
                  dense: true,
                  title: Text(_labelFor(context, t, r.key)),
                  trailing: Text(r.value.toStringAsFixed(2)),
                )),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(BuildContext context, AppLocalizations t, String key) {
    // Jeśli masz już lokalizacje na te etykiety — podepnij tutaj.
    // Na razie czytelne fallbacki:
    switch (key) {
      case 'insurancePrice':
        return 'Insurance';
      case 'additionalServicePrice':
        return 'Additional service';
      case 'adrPrice':
        return 'ADR';
      case 'shippingPrice':
        return 'Shipping';
      case 'baf':
        return 'BAF';
      case 'taf':
        return 'TAF';
      case 'inflCorrection':
        return 'Infl. correction';
      default:
        return key;
    }
  }
}

class _FeeRow {
  final String key;
  final double value;
  const _FeeRow(this.key, this.value);
}
