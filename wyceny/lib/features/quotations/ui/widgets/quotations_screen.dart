import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_header_section.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_items_summary_row.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_items_table.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_quote_details_panel.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_route_map.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/ui/widgets/common/danger_action_button.dart';
import 'package:wyceny/ui/widgets/common/neutral_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuotationViewModel>();
    final t = AppLocalizations.of(context);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        context.pop(vm.hasAnyChangesStored);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  t.topbar_customer(
                    '${vm.auth.forename} ${vm.auth.surname}',
                    vm.auth.contractorName,
                    vm.auth.skyLogicNumber,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Jeśli chcesz przycisk logout – możesz go dodać z powrotem
              // FilledButton.tonalIcon(
              //   onPressed: () {/* logout */},
              //   icon: const Icon(Icons.logout),
              //   label: Text(t.topbar_logout),
              // ),
            ],
          ),
        ),
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: vm.isUiLocked,
              child: Opacity(
                opacity: vm.isUiLocked ? 0.6 : 1.0,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final isWide = w >= 980;
                    return isWide ? _WideLayout(vm: vm) : _NarrowLayout(vm: vm);
                  },
                ),
              ),
            ),

            // Jeśli kiedyś chcesz overlay typu loader na blokadzie UI:
            if (vm.isUiLocked)
              const Positioned.fill(
                child: IgnorePointer(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.vm});

  final QuotationViewModel vm;

  @override
  Widget build(BuildContext context) {
    // dopasuj proporcje do gustu
    const leftFlex = 5;
    const rightFlex = 7;

    return Column(
      children: [
        // TOP: header + mapa, bez scrolla
        SizedBox(
          height: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: leftFlex,
                child: QuotationHeaderSection(vm: vm, scrollable: false),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: rightFlex,
                child: SizedBox.expand(
                  child: ClipRect(
                    child: const QuotationRouteMap(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // BOTTOM: jeden scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _BodyContent(vm: vm),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.vm});

  final QuotationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuotationHeaderSection(vm: vm, scrollable: false),
          const SizedBox(height: 12),

          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const QuotationRouteMap(),
            ),
          ),
          const SizedBox(height: 12),

          _BodyContent(vm: vm),
        ],
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  const _BodyContent({required this.vm});

  final QuotationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.items_section,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        QuotationItemsTable(vm: vm),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(child: QuotationItemsSummaryRow(vm: vm)),
            const SizedBox(width: 12),
            PositiveActionButton(
              onPressed: vm.isUiLocked ? null : vm.addEmptyItem,
              icon: Icons.add,
              label: t.add_item,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Panel wyceny – sam steruje widocznością (vm.hasQuote itd.)
        QuotationQuoteDetailsPanel(vm: vm),

        const SizedBox(height: 12),

        _ActionsRow(vm: vm),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.vm});

  final QuotationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PositiveActionButton(
          icon: Icons.calculate,
          label: t.action_quote,
          onPressed: vm.canRequestQuote
              ? () async {
            final ok = await vm.requestQuote();
            if (!ok) return;
            if (!context.mounted) return;
          }
              : null,
        ),
        NeutralActionButton(
          icon: Icons.delete_outline,
          label: t.action_clear,
          onPressed: vm.isUiLocked
              ? null
              : () async {
            final ok = await _confirmDialog(
              context: context,
              title: t.action_clear,
              message: t.confirm_clear_all,
            );
            if (ok == true) {
              vm.clearAllData();
            }
          },
        ),

        // Finalny przycisk aktywny tylko gdy wycena jest aktualna
        PositiveActionButton(
          icon: Icons.send,
          label: t.action_submit,
          onPressed: vm.canSubmitFinal
              ? () async {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.submit_ok)),
            );
          }
              : null,
        ),

        if (vm.canReject)
          DangerActionButton(
            icon: Icons.block,
            label: t.action_reject,
            backgroundColor: Colors.redAccent,
            onPressed: vm.isUiLocked
                ? null
                : () {
              // TODO: rejection reasons / dialog
            },
          ),
      ],
    );
  }
}

Future<bool?> _confirmDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Nie'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Tak'),
        ),
      ],
    ),
  );
}
