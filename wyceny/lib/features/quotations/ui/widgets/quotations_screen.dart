import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_items_summary_row.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_map.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_items_table.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_quote_details_panel.dart';
import 'package:wyceny/ui/widgets/common/danger_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuotationViewModel>();
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                // zostawiam jak było w Twoim screenie (zakładam, że VM to ma)
                t.topbar_customer(vm.customerName, vm.contractorName),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () {/* logout */},
              icon: const Icon(Icons.logout),
              label: Text(t.topbar_logout),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;

          final isPhone = w < 600;
          final isMedium = w >= 600 && w < 1100;
          final isWide = w >= 1100;

          // PHONE: jedna kolumna, jeden scroll
          if (isPhone) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _HeaderSection(vm: vm, scrollable: false),
                const Divider(height: 1),
                SizedBox(
                  height: 240,
                  child: const QuotationMap(),
                ),
                const Divider(height: 1),
                _BodySection(vm: vm, embedded: true),
              ],
            );
          }

          // MEDIUM + WIDE: góra split bez scrolla w mapie, dół scrollowany
          final leftFlex = isWide ? 2 : 3;
          final rightFlex = 2;

          return Column(
            children: [
              // TOP (split, mapa bez scrolla, przyklejona, min wysokość)
              SizedBox(
                height: 260, // <- możesz ustawić np. 280/320; to jest stała wysokość topu
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: leftFlex,
                      child: _HeaderSection(vm: vm, scrollable: true),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: rightFlex,
                      child: SizedBox.expand(
                        child: ClipRect(
                          child: const QuotationMap(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // BOTTOM: pełna szerokość, jeden scroll
              Expanded(
                child: _BodySection(vm: vm),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final QuotationViewModel vm;
  final bool scrollable;
  const _HeaderSection({required this.vm, required this.scrollable});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            t.quotation_title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CountryDropdown(
                      label: t.gen_origin_country,
                      countriesLoading: vm.countriesLoading,
                      countriesError: vm.countriesError,
                      countries: vm.countries,
                      selectedId: vm.originCountryId,
                      onChanged: vm.setOriginCountryId,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: t.gen_origin_zip),
                      onChanged: vm.setOriginZip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _CountryDropdown(
                      label: t.gen_dest_country,
                      countriesLoading: vm.countriesLoading,
                      countriesError: vm.countriesError,
                      countries: vm.countries,
                      selectedId: vm.destinationCountryId,
                      onChanged: vm.setDestinationCountryId,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(labelText: t.gen_dest_zip),
                      onChanged: vm.setDestinationZip,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );

    // W medium/wide: lewy panel może mieć scroll, ale mapa nadal bez scrolla.
    if (scrollable) {
      return ClipRect(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: child,
        ),
      );
    }

    // W phone: header jest w głównym ListView, więc tu NIE robimy scrolla.
    return child;
  }
}

class _BodySection extends StatelessWidget {
  final QuotationViewModel vm;
  final bool embedded; // <— gdy true: bez własnego scrolla
  const _BodySection({required this.vm, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(t.items_section, style: Theme.of(context).textTheme.titleLarge),
      ),
      const SizedBox(height: 8),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: QuotationItemsTable(vm: vm),
      ),

      const SizedBox(height: 12),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 24,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PositiveActionButton(
                  onPressed: vm.addEmptyItem,
                  icon: Icons.add,
                  label: t.add_item,
                  tooltip: t.add_item,
                ),
                DangerActionButton(
                  icon: Icons.delete_outline,
                  label: t.action_clear,
                  onPressed: () async {
                    final ok = await _confirm(
                      context,
                      title: t.action_clear,
                      message: t.confirm_clear_all,
                    );
                    if (ok != true) return;
                    vm.clearAllData();
                  },

                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 320),
              child: QuotationItemsSummaryRow(vm: vm),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: vm.canQuote ? () => vm.calculateQuote() : null,
                child: vm.isQuoting
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(t.action_quote),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 12),

      if (vm.hasQuote && vm.totalPrice != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: QuotationQuoteDetailsPanel(vm: vm),
        ),

      const SizedBox(height: 16),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PositiveActionButton(
              onPressed: () async {
                try {
                  await vm.submitOrder();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.submit_ok)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${t.submit_error}: $e')),
                    );
                  }
                }
              },
              icon: Icons.send,
              label: t.action_submit,
              tooltip: t.action_submit,
            ),
            DangerActionButton(
              icon: Icons.block,
              label: t.action_reject,
              color: Colors.red.shade800,
              onPressed: () {
                // TODO: rejection reasons
              },
            ),
          ],
        ),
      ),
    ];

    if (embedded) {
      // brak własnego scrolla — rodzic (ListView) skroluje całość
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    // standard (medium/wide): własny scroll
    return ListView(
      padding: EdgeInsets.zero,
      children: children,
    );
  }
}

// -------------------- Country dropdown --------------------

class _CountryDropdown extends StatelessWidget {
  final String label;
  final bool countriesLoading;
  final Object? countriesError;
  final List<CountryDictionary> countries;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const _CountryDropdown({
    required this.label,
    required this.countriesLoading,
    required this.countriesError,
    required this.countries,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    if (countriesLoading) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (countriesError != null) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label, errorText: countriesError.toString()),
        child: TextButton.icon(
          onPressed: () => context.read<QuotationViewModel>().init(),
          icon: const Icon(Icons.refresh),
          label: Text(t.common_retry),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: selectedId,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: countries
          .map(
            (c) => DropdownMenuItem<int>(
          value: c.countryId,
          child: Text(CountryLocalizer.localize(c.country, context)),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// -------------------- Helpers --------------------

Future<bool?> _confirm(
    BuildContext context, {
      required String title,
      required String message,
    }) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Nie')),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Tak')),
      ],
    ),
  );
}
