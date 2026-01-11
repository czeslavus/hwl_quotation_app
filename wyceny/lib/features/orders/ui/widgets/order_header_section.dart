import 'package:flutter/material.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/widgets/announcements_panel_widget.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_header_section.dart';
import 'package:wyceny/l10n/app_localizations.dart';

class OrderHeaderSection extends StatefulWidget {
  const OrderHeaderSection({
    super.key,
    required this.vm,
    required this.scrollable,
  });

  final OrderViewModel vm;
  final bool scrollable;

  @override
  State<OrderHeaderSection> createState() => _OrderHeaderSectionState();
}

class _OrderHeaderSectionState extends State<OrderHeaderSection> {
  late final TextEditingController _receiptZipCtrl;
  late final TextEditingController _deliveryZipCtrl;

  @override
  void initState() {
    super.initState();
    _receiptZipCtrl = TextEditingController(text: widget.vm.receiptZipCode);
    _deliveryZipCtrl = TextEditingController(text: widget.vm.deliveryZipCode);
    widget.vm.addListener(_syncFromVm);
  }

  @override
  void didUpdateWidget(covariant OrderHeaderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      oldWidget.vm.removeListener(_syncFromVm);
      widget.vm.addListener(_syncFromVm);
      _receiptZipCtrl.text = widget.vm.receiptZipCode;
      _deliveryZipCtrl.text = widget.vm.deliveryZipCode;
    }
  }

  void _syncFromVm() {
    final vm = widget.vm;
    if (_receiptZipCtrl.text != vm.receiptZipCode) {
      _receiptZipCtrl.text = vm.receiptZipCode;
    }
    if (_deliveryZipCtrl.text != vm.deliveryZipCode) {
      _deliveryZipCtrl.text = vm.deliveryZipCode;
    }
  }

  @override
  void dispose() {
    widget.vm.removeListener(_syncFromVm);
    _receiptZipCtrl.dispose();
    _deliveryZipCtrl.dispose();
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
            t.order_title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
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
                      countries: vm.countries,
                      selectedId: vm.receiptCountryId,
                      onChanged: vm.setReceiptCountryId,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _receiptZipCtrl,
                      decoration: InputDecoration(labelText: t.gen_origin_zip),
                      onChanged: vm.setReceiptZip,
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
                      selectedId: vm.deliveryCountryId,
                      onChanged: vm.setDeliveryCountryId,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _deliveryZipCtrl,
                      decoration: InputDecoration(labelText: t.gen_dest_zip),
                      onChanged: vm.setDeliveryZip,
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
