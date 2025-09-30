import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/features/quotations/domain/models/dictionaries/dicts.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import '../viewmodels/quotation_viewmodel.dart';
import 'quotation_item_widget.dart';
import 'quotation_map.dart';

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuotationViewModel>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
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
          final isPhone = c.maxWidth < 600;
          final isWide  = c.maxWidth >= 1100;

          final left = _LeftPane(vm: vm, isPhone: isPhone);
          final right = const QuotationMap();

          if (isWide) {
            // Desktop / szeroko
            return Row(
              children: [
                // W trybie szerokim _LeftPane sam w sobie ma scroll (ListView)
                Expanded(flex: 2, child: left),
                const VerticalDivider(width: 1),
                Expanded(flex: 1, child: right),
              ],
            );
          } else {
            // Telefon / wąsko: JEDEN zewnętrzny scroll
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // W trybie wąskim _LeftPane zwraca Column (bez własnego scrolla)
                left,
                const Divider(height: 1),
                // Mapa na samym dole
                right,
              ],
            );
          }
        },
      ),
    );
  }
}

class _LeftPane extends StatelessWidget {
  final QuotationViewModel vm;
  final bool isPhone;
  const _LeftPane({required this.vm, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final content = [
      // --- Nagłówek i ogłoszenia ---
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(t.quotation_title, style: Theme.of(context).textTheme.headlineMedium),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "${t.announcement_line} • ${t.overdue_info}",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      const SizedBox(height: 12),

      // --- Parametry wyceny (nr + kraje + extra) ---
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: t.gen_quote_number),
              onChanged: (v) => vm.quotationNumber = v,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _CountryDropdown(
                  label: t.gen_origin_country,
                  countriesLoading: vm.countriesLoading,
                  countriesError: vm.countriesError,
                  countries: vm.countries,
                  selectedId: vm.originCountryId,
                  onChanged: vm.setOriginCountry,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: t.gen_origin_zip),
                  onChanged: (v) => vm.originZip = v,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _CountryDropdown(
                  label: t.gen_dest_country,
                  countriesLoading: vm.countriesLoading,
                  countriesError: vm.countriesError,
                  countries: vm.countries,
                  selectedId: vm.destinationCountryId,
                  onChanged: vm.setDestinationCountry,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: t.gen_dest_zip),
                  onChanged: (v) => vm.destinationZip = v,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            // Extra – część „parametrów”
            CheckboxListTile(
              value: vm.preAdvice,
              onChanged: (v) { vm.preAdvice = v ?? false; vm.notifyListeners(); },
              title: Text(t.extra_pre_advice),
              contentPadding: EdgeInsets.zero,
            ),
            TextField(
              decoration: InputDecoration(labelText: t.extra_insurance_value),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              onChanged: (v) => vm.insuranceValue = double.tryParse(v.replaceAll(',', '.')) ?? 0,
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      // --- Lista towarów (tytuł + ikonka plus po prawej) ---
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(t.items_section, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (isPhone)
              IconButton(
                onPressed: vm.addItem,
                icon: const Icon(Icons.add),
                tooltip: t.add_item,
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (int i = 0; i < vm.items.length; i++)
              QuotationItemWidget(
                index: i,
                item: vm.items[i],
                onChanged: (it) => vm.updateItem(i, it),
                onRemove: () => vm.removeItem(i),
                isPhone: isPhone,
              ),
            if (!isPhone)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: vm.addItem,
                  icon: const Icon(Icons.add),
                  label: Text(t.add_item),
                ),
              ),
          ],
        ),
      ),

      const SizedBox(height: 12),

      // --- Blok przycisków #1 (po liście): Wycena + Wyczyść (tylko telefon) ---
      if (isPhone)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(onPressed: vm.calculate, child: Text(t.action_quote)),
              OutlinedButton(onPressed: vm.clear, child: Text(t.action_clear)),
            ],
          ),
        ),

      const SizedBox(height: 20),

      // --- Detale wyceny ---
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(t.pricing_section, style: Theme.of(context).textTheme.titleLarge),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _kv(t.fee_baf, vm.baf),
            _kv(t.fee_myt, vm.myt),
            _kv(t.fee_infl, vm.inflation),
            _kv(t.fee_recalc_weight, vm.recalculatedWeight),
            _kv(t.fee_freight, vm.freightPrice),
            _kv(t.fee_all_in, vm.allInPrice),
            _kv(t.fee_insurance, vm.insuranceFee),
            _kv(t.fee_adr, vm.adrFee),
            _kv(t.fee_service, vm.serviceFee),
            _kv(t.fee_pre_advice, vm.preAdviceFee),
            const Divider(),
            _kv(t.fee_total, vm.total, emphasize: true),
          ],
        ),
      ),

      const SizedBox(height: 12),

      // --- Blok przycisków #2 (po detalach): Zatwierdź + Odrzuć (telefon),
      //     a na desktopie – stary zestaw pełny
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: isPhone
            ? Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.tonal(onPressed: () {/* submit */}, child: Text(t.action_submit)),
            OutlinedButton(onPressed: () {/* reject */}, child: Text(t.action_reject)),
          ],
        )
            : Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(onPressed: vm.calculate, child: Text(t.action_quote)),
            FilledButton.tonal(onPressed: () {/* submit */}, child: Text(t.action_submit)),
            OutlinedButton(onPressed: vm.clear, child: Text(t.action_clear)),
            OutlinedButton(onPressed: () {/* reject */}, child: Text(t.action_reject)),
          ],
        ),
      ),
    ];

    // WERSJE SCROLLOWANIA:
    // - Desktop/tablet szeroki: własny ListView (wewnętrzny scroll)
    // - Telefon/wąsko: zwracamy Column (bez scrolla) — scroll robi ListView z rodzica
    return isPhone
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content)
        : ListView(
      padding: EdgeInsets.zero,
      children: content,
    );
  }

  Widget _kv(String k, double v, {bool emphasize = false}) {
    final style = emphasize
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : const TextStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final String label;
  final bool countriesLoading;
  final Object? countriesError;
  final List<Country> countries;
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
    final t = AppLocalizations.of(context)!;

    if (countriesLoading) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const SizedBox(height: 24, child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator(strokeWidth: 2))),
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
          .map((c) => DropdownMenuItem<int>(
        value: c.id,
        child: Text(CountryLocalizer.localize(c.country, context)),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

