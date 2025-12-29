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
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    Widget item(String label, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: textStyle),
          Text(
            value,
            style: textStyle?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 24,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: [
        item(t.sum_packages, vm.sumPackages.toString()),
        item(t.sum_weight, '${vm.sumWeight.toStringAsFixed(2)} kg'),
        item(t.sum_volume, '${vm.sumVolume.toStringAsFixed(2)}'),
        item(t.sum_long_weight, '${vm.sumLongWeight.toStringAsFixed(2)} kg'),
      ],
    );
  }
}
