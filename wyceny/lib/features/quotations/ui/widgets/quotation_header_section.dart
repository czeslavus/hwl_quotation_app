import 'package:flutter/material.dart';
import 'package:wyceny/l10n/app_localizations.dart';

import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';

class QuotationHeaderSection extends StatefulWidget {
  final QuotationViewModel vm;

  /// Jeśli używasz w układzie desktop z panelem bocznym
  /// i chcesz, żeby nagłówek był przewijalny osobno.
  final bool scrollable;

  const QuotationHeaderSection({
    super.key,
    required this.vm,
    required this.scrollable,
  });

  @override
  State<QuotationHeaderSection> createState() => _QuotationHeaderSectionState();
}

class _QuotationHeaderSectionState extends State<QuotationHeaderSection> {
  late final TextEditingController _originZipCtrl;
  late final TextEditingController _destZipCtrl;

  @override
  void initState() {
    super.initState();
    _originZipCtrl = TextEditingController(text: widget.vm.originZip);
    _destZipCtrl = TextEditingController(text: widget.vm.destinationZip);

    widget.vm.addListener(_syncFromVm);
  }

  @override
  void didUpdateWidget(covariant QuotationHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      oldWidget.vm.removeListener(_syncFromVm);
      widget.vm.addListener(_syncFromVm);

      // podmień tekst na start po zmianie instancji VM
      _originZipCtrl.text = widget.vm.originZip;
      _destZipCtrl.text = widget.vm.destinationZip;
    }
  }

  void _syncFromVm() {
    // Synchronizacja po loadQuotation() / init()
    // (ale nie rozwalamy wpisywania użytkownika)
    final vm = widget.vm;

    if (_originZipCtrl.text != vm.originZip) {
      _originZipCtrl.text = vm.originZip;
    }
    if (_destZipCtrl.text != vm.destinationZip) {
      _destZipCtrl.text = vm.destinationZip;
    }
  }

  @override
  void dispose() {
    widget.vm.removeListener(_syncFromVm);
    _originZipCtrl.dispose();
    _destZipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final t = AppLocalizations.of(context);

    final content = Column(
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
                    child: CountryDropdown(
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
                      controller: _originZipCtrl,
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
                    child: CountryDropdown(
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
                      controller: _destZipCtrl,
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

    if (!widget.scrollable) return content;

    return ClipRect(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: content,
      ),
    );
  }
}

/// Publiczny dropdown krajów – możesz użyć tego zamiast prywatnego _CountryDropdown.
/// Jeśli masz swój widget z lepszym UI, przenieś go tutaj i podmień użycia.
class CountryDropdown extends StatelessWidget {
  final String label;

  final bool countriesLoading;
  final Object? countriesError;
  final List<CountryDictionary> countries;

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  const CountryDropdown({
    super.key,
    required this.label,
    required this.countriesLoading,
    required this.countriesError,
    required this.countries,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (countriesLoading) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const LinearProgressIndicator(),
      );
    }

    if (countriesError != null) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: countriesError.toString(),
        ),
        child: const SizedBox(height: 24),
      );
    }

    return DropdownButtonFormField<int>(
      value: selectedId,
      decoration: InputDecoration(labelText: label),
      items: countries
          .map(
            (c) => DropdownMenuItem<int>(
          value: c.countryId,
          child: Text(c.country!),
        ),
      )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
