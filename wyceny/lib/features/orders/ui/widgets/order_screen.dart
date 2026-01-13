import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_item.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_viewmodel.dart';
import 'package:wyceny/features/orders/ui/widgets/order_header_section.dart';
import 'package:wyceny/features/common/language_flag_toggle.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/ui/widgets/common/danger_action_button.dart';
import 'package:wyceny/ui/widgets/common/neutral_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';
import 'package:wyceny/features/route_by_postcode/ui/widgets/route_map_by_postcode.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final t = AppLocalizations.of(context);

    final canReject = widget.orderId != 'new';

    return Scaffold(
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
          ],
        ),
        actions: const [
          LanguageFlagToggle(),
          SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final isWide = w >= 980;

            return isWide
                ? _WideLayout(vm: vm, orderId: widget.orderId)
                : _NarrowLayout(vm: vm, orderId: widget.orderId);
          },
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.vm, required this.orderId});

  final OrderViewModel vm;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: OrderHeaderSection(vm: vm, scrollable: true),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 7,
                child: SizedBox.expand(
                  child: ClipRect(
                    child: RouteMapByPostcode(
                      originZip: vm.receiptZipCode,
                      destinationZip: vm.deliveryZipCode,
                      originCountryCode: vm.countryCodeForId(vm.receiptCountryId),
                      destinationCountryCode: vm.countryCodeForId(vm.deliveryCountryId),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _BodyContent(vm: vm, orderId: orderId),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.vm, required this.orderId});

  final OrderViewModel vm;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderHeaderSection(vm: vm, scrollable: false),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: RouteMapByPostcode(
                originZip: vm.receiptZipCode,
                destinationZip: vm.deliveryZipCode,
                originCountryCode: vm.countryCodeForId(vm.receiptCountryId),
                destinationCountryCode: vm.countryCodeForId(vm.deliveryCountryId),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _BodyContent(vm: vm, orderId: orderId),
        ],
      ),
    );
  }
}

class _BodyContent extends StatefulWidget {
  const _BodyContent({required this.vm, required this.orderId});

  final OrderViewModel vm;
  final String orderId;

  @override
  State<_BodyContent> createState() => _BodyContentState();
}

class _BodyContentState extends State<_BodyContent> {
  late final TextEditingController _receiptNameCtrl;
  late final TextEditingController _receiptCityCtrl;
  late final TextEditingController _receiptStreetCtrl;
  late final TextEditingController _receiptPhoneCtrl;
  late final TextEditingController _deliveryNameCtrl;
  late final TextEditingController _deliveryCityCtrl;
  late final TextEditingController _deliveryStreetCtrl;
  late final TextEditingController _deliveryPhoneCtrl;
  late final TextEditingController _orderCustomerNrCtrl;
  late final TextEditingController _notificationEmailCtrl;
  late final TextEditingController _notificationSmsCtrl;
  late final TextEditingController _orderValueCtrl;
  late final TextEditingController _insuranceValueCtrl;
  bool _formValid = false;

  @override
  void initState() {
    super.initState();
    final vm = widget.vm;
    _receiptNameCtrl = TextEditingController(text: vm.receiptName);
    _receiptCityCtrl = TextEditingController(text: vm.receiptCity);
    _receiptStreetCtrl = TextEditingController(text: vm.receiptStreet);
    _receiptPhoneCtrl = TextEditingController(text: vm.receiptPhone);
    _deliveryNameCtrl = TextEditingController(text: vm.deliveryName);
    _deliveryCityCtrl = TextEditingController(text: vm.deliveryCity);
    _deliveryStreetCtrl = TextEditingController(text: vm.deliveryStreet);
    _deliveryPhoneCtrl = TextEditingController(text: vm.deliveryPhone);
    _orderCustomerNrCtrl = TextEditingController(text: vm.orderCustomerNr ?? '');
    _notificationEmailCtrl = TextEditingController(text: vm.notificationEmail ?? '');
    _notificationSmsCtrl = TextEditingController(text: vm.notificationSms ?? '');
    _orderValueCtrl = TextEditingController(text: _formatDouble(vm.orderValue));
    _insuranceValueCtrl = TextEditingController(text: _formatDouble(vm.insuranceValue));
    vm.addListener(_syncFromVm);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFormValidity());
  }

  @override
  void didUpdateWidget(covariant _BodyContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      oldWidget.vm.removeListener(_syncFromVm);
      widget.vm.addListener(_syncFromVm);
      _syncFromVm();
    }
  }

  @override
  void dispose() {
    widget.vm.removeListener(_syncFromVm);
    _receiptNameCtrl.dispose();
    _receiptCityCtrl.dispose();
    _receiptStreetCtrl.dispose();
    _receiptPhoneCtrl.dispose();
    _deliveryNameCtrl.dispose();
    _deliveryCityCtrl.dispose();
    _deliveryStreetCtrl.dispose();
    _deliveryPhoneCtrl.dispose();
    _orderCustomerNrCtrl.dispose();
    _notificationEmailCtrl.dispose();
    _notificationSmsCtrl.dispose();
    _orderValueCtrl.dispose();
    _insuranceValueCtrl.dispose();
    super.dispose();
  }

  void _syncFromVm() {
    final vm = widget.vm;
    _setControllerText(_receiptNameCtrl, vm.receiptName);
    _setControllerText(_receiptCityCtrl, vm.receiptCity);
    _setControllerText(_receiptStreetCtrl, vm.receiptStreet);
    _setControllerText(_receiptPhoneCtrl, vm.receiptPhone);
    _setControllerText(_deliveryNameCtrl, vm.deliveryName);
    _setControllerText(_deliveryCityCtrl, vm.deliveryCity);
    _setControllerText(_deliveryStreetCtrl, vm.deliveryStreet);
    _setControllerText(_deliveryPhoneCtrl, vm.deliveryPhone);
    _setControllerText(_orderCustomerNrCtrl, vm.orderCustomerNr ?? '');
    _setControllerText(_notificationEmailCtrl, vm.notificationEmail ?? '');
    _setControllerText(_notificationSmsCtrl, vm.notificationSms ?? '');
    _setControllerText(_orderValueCtrl, _formatDouble(vm.orderValue));
    _setControllerText(_insuranceValueCtrl, _formatDouble(vm.insuranceValue));
    _updateFormValidity();
  }

  void _updateFormValidity() {
    if (!mounted) return;
    final form = Form.of(context);
    if (form == null) return;
    final valid = form.validate();
    if (valid != _formValid) {
      setState(() => _formValid = valid);
    }
  }

  String _formatDouble(double value) {
    if (value == 0) return '';
    return value.toStringAsFixed(2);
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
    controller.selection = TextSelection.collapsed(offset: value.length);
  }

  AppLocalizations get _t => AppLocalizations.of(context);

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return _t.validation_required;
    return null;
  }

  String? _requiredNumber(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) return _t.validation_required;
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return _t.validation_invalid_number;
    if (!allowZero && parsed <= 0) return _t.validation_positive_number;
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return _t.validation_required;
    final email = value.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return ok ? null : _t.validation_invalid_email;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return _t.validation_required;
    final normalized = value.trim().replaceAll(RegExp(r'[\s()-]+'), '');
    if (!RegExp(r'^\+?\d+$').hasMatch(normalized)) return _t.validation_invalid_phone;
    String digits = normalized.startsWith('+') ? normalized.substring(1) : normalized;
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    if (digits.length < 6 || digits.length > 15) return _t.validation_invalid_phone;
    return null;
  }

  String? _validateReceiptDateBegin(DateTime? value) {
    if (value == null) return _t.validation_required;
    final today = DateTime.now();
    final dateOnly = DateTime(value.year, value.month, value.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (dateOnly.isBefore(todayOnly)) return _t.validation_date_in_past;
    return null;
  }

  String? _validateReceiptDateEnd(DateTime? value) {
    if (value == null) return _t.validation_required;
    final start = widget.vm.receiptDateBegin;
    if (start != null) {
      final startOnly = DateTime(start.year, start.month, start.day);
      final endOnly = DateTime(value.year, value.month, value.day);
      if (endOnly.isBefore(startOnly)) return _t.validation_end_before_start;
    }
    return null;
  }

  String? _validateDeliveryDateBegin(DateTime? value) {
    if (value == null) return _t.validation_required;
    final receipt = widget.vm.receiptDateBegin;
    if (receipt != null) {
      final receiptOnly = DateTime(receipt.year, receipt.month, receipt.day);
      final deliveryOnly = DateTime(value.year, value.month, value.day);
      if (deliveryOnly.isBefore(receiptOnly)) return _t.validation_delivery_before_pickup;
    }
    return null;
  }

  String? _validateDeliveryDateEnd(DateTime? value) {
    if (value == null) return _t.validation_required;
    final start = widget.vm.deliveryDateBegin;
    if (start != null) {
      final startOnly = DateTime(start.year, start.month, start.day);
      final endOnly = DateTime(value.year, value.month, value.day);
      if (endOnly.isBefore(startOnly)) return _t.validation_end_before_start;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final t = AppLocalizations.of(context);
    final canReject = widget.orderId != 'new';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: t.section_sender,
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _receiptNameCtrl,
                    decoration: InputDecoration(labelText: t.field_name),
                    onChanged: (v) {
                      vm.receiptName = v;
                      vm.markDirty();
                    },
                    validator: _requiredText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _receiptCityCtrl,
                    decoration: InputDecoration(labelText: t.field_city),
                    onChanged: (v) {
                      vm.receiptCity = v;
                      vm.markDirty();
                    },
                    validator: _requiredText,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _receiptStreetCtrl,
                    decoration: InputDecoration(labelText: t.field_street),
                    onChanged: (v) {
                      vm.receiptStreet = v;
                      vm.markDirty();
                    },
                    validator: _requiredText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _receiptPhoneCtrl,
                    decoration: InputDecoration(labelText: t.field_phone),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) {
                      vm.receiptPhone = v;
                      vm.markDirty();
                    },
                    validator: _validatePhone,
                  ),
                ),
              ]),
            ],
          ),
        ),
        _SectionCard(
          title: t.section_recipient,
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _deliveryNameCtrl,
                    decoration: InputDecoration(labelText: t.field_name),
                    onChanged: (v) {
                      vm.deliveryName = v;
                      vm.markDirty();
                    },
                    validator: _requiredText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _deliveryCityCtrl,
                    decoration: InputDecoration(labelText: t.field_city),
                    onChanged: (v) {
                      vm.deliveryCity = v;
                      vm.markDirty();
                    },
                    validator: _requiredText,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _deliveryStreetCtrl,
                    decoration: InputDecoration(labelText: t.field_street),
                    onChanged: (v) {
                      vm.deliveryStreet = v;
                      vm.markDirty();
                    },
                    validator: _requiredText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _deliveryPhoneCtrl,
                    decoration: InputDecoration(labelText: t.field_phone),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) {
                      vm.deliveryPhone = v;
                      vm.markDirty();
                    },
                    validator: _validatePhone,
                  ),
                ),
              ]),
            ],
          ),
        ),
        _SectionCard(
          title: t.section_dates,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final maxWidth = constraints.maxWidth;
              final columns = maxWidth >= 900 ? 4 : (maxWidth >= 600 ? 2 : 1);
              final fieldWidth = (maxWidth - spacing * (columns - 1)) / columns;

              Widget field(Widget child) => SizedBox(
                width: fieldWidth,
                child: child,
              );

              return Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: [
                  field(
                    _dateField(
                      context: context,
                      label: t.field_pickup_from,
                      value: vm.receiptDateBegin,
                      onPick: (d) {
                        vm.receiptDateBegin = d;
                        vm.markDirty();
                      },
                      validator: _validateReceiptDateBegin,
                    ),
                  ),
                  field(
                    _dateField(
                      context: context,
                      label: t.field_pickup_to,
                      value: vm.receiptDateEnd,
                      onPick: (d) {
                        vm.receiptDateEnd = d;
                        vm.markDirty();
                      },
                      validator: _validateReceiptDateEnd,
                    ),
                  ),
                  field(
                    _dateField(
                      context: context,
                      label: t.field_delivery_from,
                      value: vm.deliveryDateBegin,
                      onPick: (d) {
                        vm.deliveryDateBegin = d;
                        vm.markDirty();
                      },
                      validator: _validateDeliveryDateBegin,
                    ),
                  ),
                  field(
                    _dateField(
                      context: context,
                      label: t.field_delivery_to,
                      value: vm.deliveryDateEnd,
                      onPick: (d) {
                        vm.deliveryDateEnd = d;
                        vm.markDirty();
                      },
                      validator: _validateDeliveryDateEnd,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _SectionCard(
          title: t.section_order_data,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final maxWidth = constraints.maxWidth;
              final columns = maxWidth >= 900 ? 4 : (maxWidth >= 600 ? 2 : 1);
              final fieldWidth = (maxWidth - spacing * (columns - 1)) / columns;

              Widget field(Widget child) => SizedBox(
                width: fieldWidth,
                child: child,
              );

              return Wrap(
                spacing: spacing,
                runSpacing: 8,
                children: [
                  field(
                    TextFormField(
                      controller: _orderCustomerNrCtrl,
                      decoration: InputDecoration(labelText: t.field_customer_nr),
                      onChanged: (v) {
                        vm.orderCustomerNr = v;
                        vm.markDirty();
                      },
                      validator: _requiredText,
                    ),
                  ),
                  field(
                    TextFormField(
                      controller: _notificationEmailCtrl,
                      decoration: InputDecoration(labelText: t.field_notification_email),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) {
                        vm.notificationEmail = v;
                        vm.markDirty();
                      },
                      validator: _validateEmail,
                    ),
                  ),
                  field(
                    TextFormField(
                      controller: _notificationSmsCtrl,
                      decoration: InputDecoration(labelText: t.field_notification_sms),
                      keyboardType: TextInputType.phone,
                      onChanged: (v) {
                        vm.notificationSms = v;
                        vm.markDirty();
                      },
                      validator: _validatePhone,
                    ),
                  ),
                  field(
                    TextFormField(
                      controller: _orderValueCtrl,
                      decoration: InputDecoration(labelText: t.field_order_value_pln),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        vm.orderValue = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                        vm.markDirty();
                      },
                      validator: _requiredNumber,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                t.items_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            PositiveActionButton(
              onPressed: vm.addItem,
              icon: Icons.add,
              label: t.add_item,
              tooltip: t.add_item,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _OrderItemsTable(vm: vm),
        const SizedBox(height: 12),
        _SectionCard(
          title: t.services_title,
          child: Column(
            children: [
              CheckboxListTile(
                value: vm.services,
                onChanged: (v) {
                  vm.services = v ?? false;
                  vm.markDirty();
                },
                title: Text(t.services_services),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: vm.preAdvice,
                onChanged: (v) {
                  vm.preAdvice = v ?? false;
                  vm.markDirty();
                },
                title: Text(t.services_pre_advice),
                contentPadding: EdgeInsets.zero,
              ),
              TextFormField(
                controller: _insuranceValueCtrl,
                decoration: InputDecoration(labelText: t.services_cargo_insurance),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  vm.insuranceValue = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                  vm.markDirty();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _kv(t.summary_cbm, vm.cbmTotal),
            const SizedBox(height: 4),
            const Divider(),
            _kv(t.summary_all_in, vm.totalPrice, emphasize: true),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PositiveActionButton(
              icon: Icons.calculate,
              label: t.action_calculate,
              onPressed: (vm.hasChangesStored && _formValid) ? vm.calculate : null,
            ),
            NeutralActionButton(
              icon: Icons.delete_outline,
              label: t.action_clear,
              onPressed: vm.hasChangesStored ? vm.clear : null,
            ),
            PositiveActionButton(
              icon: Icons.send,
              label: t.action_submit_order,
              onPressed: _formValid ? vm.submit : null,
            ),
            DangerActionButton(
              icon: Icons.cancel_outlined,
              label: t.action_reject_order,
              onPressed: canReject
                  ? () async {
                final ok = await _confirmRejectDialog(context, t);
                if (ok != true) return;
                await vm.rejectOrder(widget.orderId);
                if (!context.mounted) return;
                context.go('/order');
              }
                  : null,
            ),
          ],
        ),
      ],
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
          Text(v.toStringAsFixed(3), style: style),
        ],
      ),
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
    String? Function(DateTime?)? validator,
  }) {
    return FormField<DateTime>(
      key: ValueKey('$label-${value?.toIso8601String() ?? 'none'}'),
      initialValue: value,
      validator: validator,
      builder: (field) {
        return InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: field.value ?? now,
              firstDate: DateTime(now.year - 2),
              lastDate: DateTime(now.year + 1),
            );
            field.didChange(picked);
            field.validate();
            onPick(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: field.errorText,
            ),
            child: Text(field.value != null ? "${field.value!.toLocal()}".split(' ')[0] : '—'),
          ),
        );
      },
    );
  }
}

Future<bool?> _confirmRejectDialog(BuildContext context, AppLocalizations t) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.confirm_reject_order_title),
      content: Text(t.confirm_reject_order_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(t.action_reject_order),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemsTable extends StatefulWidget {
  const _OrderItemsTable({required this.vm});

  final OrderViewModel vm;

  @override
  State<_OrderItemsTable> createState() => _OrderItemsTableState();
}

class _OrderItemsTableState extends State<_OrderItemsTable> {
  final _hController = ScrollController();

  static const _wXS = 70.0;
  static const _wS = 90.0;
  static const _wM = 110.0;
  static const _wL = 150.0;

  @override
  void dispose() {
    _hController.dispose();
    super.dispose();
  }

  String? _requiredInt(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) return t.validation_required;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return t.validation_invalid_number;
    if (parsed <= 0) return t.validation_positive_number;
    return null;
  }

  String? _requiredDouble(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) return t.validation_required;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return t.validation_invalid_number;
    if (parsed <= 0) return t.validation_positive_number;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final t = AppLocalizations.of(context);

    if (vm.items.isEmpty) {
      return _EmptyBox(text: t.items_empty_hint);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final minWidth = c.maxWidth < 900 ? 980.0 : c.maxWidth;
        return Scrollbar(
          controller: _hController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _hController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth),
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 46,
                dataRowMaxHeight: 54,
                horizontalMargin: 8,
                columnSpacing: 10,
                columns: [
                  DataColumn(label: Text(t.label_qty)),
                  DataColumn(label: Text(t.label_pack_type)),
                  DataColumn(label: Text(t.label_length_cm)),
                  DataColumn(label: Text(t.label_width_cm)),
                  DataColumn(label: Text(t.label_height_cm)),
                  DataColumn(label: Text(t.label_weight_real_kg)),
                  DataColumn(label: Text(t.item_dangerous)),
                  DataColumn(label: Text(t.label_item_cbm)),
                  const DataColumn(label: Text('')),
                ],
                rows: List.generate(vm.items.length, (i) => _row(context, i, vm.items[i])),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _row(BuildContext context, int index, OrderItem it) {
    final vm = widget.vm;
    final t = AppLocalizations.of(context);

    return DataRow(
      cells: [
        DataCell(
          _intField(
            width: _wXS,
            value: it.qty ?? 0,
            validator: (v) => _requiredInt(v, t),
            onChanged: (v) => vm.updateItem(index, it..qty = v),
          ),
        ),
        DataCell(
          _packDropdown(
            width: _wL,
            value: it.packType ?? 'EUR-1 (1,2x0,8)',
            validator: (v) => (v == null || v.trim().isEmpty) ? t.validation_required : null,
            onChanged: (v) => vm.updateItem(index, it..packType = v),
          ),
        ),
        DataCell(
          _doubleField(
            width: _wS,
            value: it.lengthCm ?? 0,
            validator: (v) => _requiredDouble(v, t),
            onChanged: (v) => vm.updateItem(index, it..lengthCm = v),
          ),
        ),
        DataCell(
          _doubleField(
            width: _wS,
            value: it.widthCm ?? 0,
            validator: (v) => _requiredDouble(v, t),
            onChanged: (v) => vm.updateItem(index, it..widthCm = v),
          ),
        ),
        DataCell(
          _doubleField(
            width: _wS,
            value: it.heightCm ?? 0,
            validator: (v) => _requiredDouble(v, t),
            onChanged: (v) => vm.updateItem(index, it..heightCm = v),
          ),
        ),
        DataCell(
          _doubleField(
            width: _wM,
            value: it.weightKg ?? 0,
            validator: (v) => _requiredDouble(v, t),
            onChanged: (v) => vm.updateItem(index, it..weightKg = v),
          ),
        ),
        DataCell(
          Checkbox(
            value: it.adr,
            onChanged: (v) => vm.updateItem(index, it..adr = (v ?? false)),
          ),
        ),
        DataCell(SizedBox(width: _wM, child: Text(it.cbm.toStringAsFixed(3)))),
        DataCell(_deleteButton(t.item_delete_tt, () => vm.removeItem(index))),
      ],
    );
  }

  InputDecoration _cellDeco() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    border: OutlineInputBorder(),
  );

  TextStyle _cellStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12);

  Widget _intField({
    required double width,
    required int value,
    required ValueChanged<int> onChanged,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: width,
      child: _SelectableNumberField(
        value: value.toString(),
        keyboardType: TextInputType.number,
        decoration: _cellDeco(),
        textStyle: _cellStyle(context),
        validator: validator,
        onChanged: (s) {
          final v = int.tryParse(s.trim());
          if (v == null) return;
          onChanged(v);
        },
      ),
    );
  }

  Widget _doubleField({
    required double width,
    required double value,
    required ValueChanged<double> onChanged,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: width,
      child: _SelectableNumberField(
        value: value.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _cellDeco(),
        textStyle: _cellStyle(context),
        validator: validator,
        onChanged: (s) {
          final raw = s.trim();
          final v = double.tryParse(raw.replaceAll(',', '.'));
          if (v == null) return;
          onChanged(v);
        },
      ),
    );
  }

  Widget _packDropdown({
    required double width,
    required String value,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
  }) {
    const packs = <String>[
      'EUR-1 (1,2x0,8)',
      'EUR-2 (1,2x1,0)',
      'Kartony',
      'Skrzynie',
    ];
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: packs.contains(value) ? value : packs.first,
        isDense: true,
        decoration: _cellDeco().copyWith(
          labelText: AppLocalizations.of(context).label_pack_type,
        ),
        items: packs.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) => onChanged(v ?? packs.first),
        validator: validator,
      ),
    );
  }

  Widget _deleteButton(String tooltip, VoidCallback onPressed) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          padding: EdgeInsets.zero,
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _SelectableNumberField extends StatefulWidget {
  const _SelectableNumberField({
    required this.value,
    required this.keyboardType,
    required this.decoration,
    required this.textStyle,
    required this.onChanged,
    this.validator,
  });

  final String value;
  final TextInputType keyboardType;
  final InputDecoration decoration;
  final TextStyle textStyle;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  @override
  State<_SelectableNumberField> createState() => _SelectableNumberFieldState();
}

class _SelectableNumberFieldState extends State<_SelectableNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _SelectableNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) return;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.textStyle,
      keyboardType: widget.keyboardType,
      decoration: widget.decoration,
      onChanged: widget.onChanged,
      validator: widget.validator,
      onTap: _handleFocusChange,
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
