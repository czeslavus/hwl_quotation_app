import 'package:flutter/material.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class QuotationItemsSummaryRow extends StatelessWidget {
  const QuotationItemsSummaryRow({
    super.key,
    required this.vm,
  });

  final QuotationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    // ---- SUMY liczone lokalnie z items ----
    final sumPackages = vm.items.fold<int>(
      0,
          (acc, i) => acc + i.quantity,
    );

    final sumWeight = vm.items.fold<double>(
      0.0,
          (acc, i) => acc + i.quantity * i.weight.toDouble(),
    );

    final sumVolume = vm.items.fold<double>(
      0.0,
          (acc, i) =>
      acc +
          i.quantity *
              i.length.toDouble() *
              i.width.toDouble() *
              i.height.toDouble() /
              1000000,
    );

    final sumLongWeight = vm.items.fold<double>(
      0.0,
          (acc, i) =>
      acc + i.quantity * (i.longWeight ?? 0.0),
    );

    Widget item(String label, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: baseStyle),
          Text(
            value,
            style: baseStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: vm.isUiLocked ? 0.6 : 1.0,
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          item(t.sum_packages, sumPackages.toString()),
          item(t.sum_weight, '${sumWeight.toStringAsFixed(2)} kg'),
          item(t.sum_volume, '${sumVolume.toStringAsFixed(2)} m³'),
          item(t.sum_long_weight, '${sumLongWeight.toStringAsFixed(2)} kg'),
        ],
      ),
    );
  }
}
