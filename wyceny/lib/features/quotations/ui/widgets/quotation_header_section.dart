import 'package:flutter/material.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';
import 'package:wyceny/l10n/app_localizations.dart';

import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/dictionaries/domain/models/services_dictionary.dart';
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
  late final TextEditingController _insuranceValueCtrl;
  late final FocusNode _insuranceValueFocus;

  @override
  void initState() {
    super.initState();
    _originZipCtrl = TextEditingController(text: widget.vm.originZip);
    _destZipCtrl = TextEditingController(text: widget.vm.destinationZip);
    _insuranceValueCtrl = TextEditingController(
      text: widget.vm.insuranceValue?.toString() ?? '',
    );
    _insuranceValueFocus = FocusNode()..addListener(_handleInsuranceValueFocus);

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
      _insuranceValueCtrl.text = widget.vm.insuranceValue?.toString() ?? '';
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
    final insuranceText = vm.insuranceValue?.toString() ?? '';
    if (_insuranceValueCtrl.text != insuranceText) {
      _insuranceValueCtrl.text = insuranceText;
    }
  }

  @override
  void dispose() {
    widget.vm.removeListener(_syncFromVm);
    _originZipCtrl.dispose();
    _destZipCtrl.dispose();
    _insuranceValueCtrl.dispose();
    _insuranceValueFocus
      ..removeListener(_handleInsuranceValueFocus)
      ..dispose();
    super.dispose();
  }

  void _handleInsuranceValueFocus() {
    if (!_insuranceValueFocus.hasFocus) {
      _commitInsuranceValue();
    }
  }

  void _commitInsuranceValue() {
    final value = _insuranceValueCtrl.text.trim();
    if (value.isEmpty) {
      widget.vm.setInsuranceValue(null);
      return;
    }
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed != null) {
      widget.vm.setInsuranceValue(parsed);
    }
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
        // Ogłoszenia
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AnnouncementsPanel(
            header: Text("${t.announcement_line} • ${t.overdue_info}"),
            body: Text("${t.announcement_line} • ${t.overdue_info}"),
          ),
        ),
        const SizedBox(height: 12),
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
                      countries: vm.receiptCountries,
                      selectedId: vm.originCountryId,
                      onChanged: vm.originCountryLocked ? null : vm.setOriginCountryId,
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
                      countries: vm.deliveryCountries,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _AdrField(
                      value: vm.adr,
                      onChanged: vm.setAdr,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _insuranceValueCtrl,
                      focusNode: _insuranceValueFocus,
                      decoration: InputDecoration(labelText: t.insurance_value_label),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onEditingComplete: _commitInsuranceValue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ServicesDropdown(
                      servicesLoading: vm.servicesLoading,
                      servicesError: vm.servicesError,
                      services: vm.services,
                      selectedId: vm.additionalServiceId,
                      onChanged: vm.setAdditionalServiceId,
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
  final ValueChanged<int?>? onChanged;
  final String? Function(int?)? validator;

  const CountryDropdown({
    super.key,
    required this.label,
    required this.countriesLoading,
    required this.countriesError,
    required this.countries,
    required this.selectedId,
    required this.onChanged,
    this.validator,
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

    final safeValue = countries.any((c) => c.countryId == selectedId)
        ? selectedId
        : null;
    return DropdownButtonFormField<int>(
      value: safeValue,
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
      validator: validator,
    );
  }
}

class _AdrField extends StatelessWidget {
  const _AdrField({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'ADR'),
      child: Checkbox(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
      ),
    );
  }
}

class _ServicesDropdown extends StatelessWidget {
  const _ServicesDropdown({
    required this.servicesLoading,
    required this.servicesError,
    required this.services,
    required this.selectedId,
    required this.onChanged,
  });

  final bool servicesLoading;
  final Object? servicesError;
  final List<ServicesDictionary> services;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (servicesLoading) {
      return InputDecorator(
        decoration: InputDecoration(labelText: t.additional_services_label),
        child: LinearProgressIndicator(),
      );
    }

    if (servicesError != null) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: t.additional_services_label,
          errorText: servicesError.toString(),
        ),
        child: const SizedBox(height: 24),
      );
    }

    return DropdownButtonFormField<int>(
      value: selectedId,
      decoration: InputDecoration(labelText: t.additional_services_label),
      items: services
          .map(
            (s) => DropdownMenuItem<int>(
              value: s.serviceId,
              child: Text(s.name ?? ''),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
