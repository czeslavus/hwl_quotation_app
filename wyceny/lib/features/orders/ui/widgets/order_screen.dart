import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_item.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_viewmodel.dart';
import 'package:wyceny/features/orders/ui/widgets/order_header_section.dart';
import 'package:wyceny/l10n/app_localizations.dart';
import 'package:wyceny/ui/widgets/common/neutral_action_button.dart';
import 'package:wyceny/ui/widgets/common/positive_action_button.dart';
import 'package:wyceny/features/route_by_postcode/ui/widgets/route_map_by_postcode.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final t = AppLocalizations.of(context);

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
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final isWide = w >= 980;

          return isWide
              ? _WideLayout(vm: vm)
              : _NarrowLayout(vm: vm);
        },
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.vm});

  final OrderViewModel vm;

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
            child: _BodyContent(vm: vm),
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.vm});

  final OrderViewModel vm;

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
          _BodyContent(vm: vm),
        ],
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  const _BodyContent({required this.vm});

  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Nadawca',
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Nazwa'),
                    onChanged: (v) => vm.receiptName = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Miasto'),
                    onChanged: (v) => vm.receiptCity = v,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Ulica'),
                    onChanged: (v) => vm.receiptStreet = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => vm.receiptPhone = v,
                  ),
                ),
              ]),
            ],
          ),
        ),
        _SectionCard(
          title: 'Odbiorca',
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Nazwa'),
                    onChanged: (v) => vm.deliveryName = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Miasto'),
                    onChanged: (v) => vm.deliveryCity = v,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Ulica'),
                    onChanged: (v) => vm.deliveryStreet = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => vm.deliveryPhone = v,
                  ),
                ),
              ]),
            ],
          ),
        ),
        _SectionCard(
          title: 'Terminy',
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: _dateField(
                    context: context,
                    label: 'Odbiór od',
                    value: vm.receiptDateBegin,
                    onPick: (d) {
                      vm.receiptDateBegin = d;
                      vm.notifyListeners();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dateField(
                    context: context,
                    label: 'Odbiór do',
                    value: vm.receiptDateEnd,
                    onPick: (d) {
                      vm.receiptDateEnd = d;
                      vm.notifyListeners();
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _dateField(
                    context: context,
                    label: 'Dostawa od',
                    value: vm.deliveryDateBegin,
                    onPick: (d) {
                      vm.deliveryDateBegin = d;
                      vm.notifyListeners();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dateField(
                    context: context,
                    label: 'Dostawa do',
                    value: vm.deliveryDateEnd,
                    onPick: (d) {
                      vm.deliveryDateEnd = d;
                      vm.notifyListeners();
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
        _SectionCard(
          title: 'Dane zamówienia',
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Nr klienta'),
                    onChanged: (v) => vm.orderCustomerNr = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'E-mail do powiadomień'),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => vm.notificationEmail = v,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'SMS do powiadomień'),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => vm.notificationSms = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Wartość zlecenia (PLN)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => vm.orderValue = double.tryParse(v.replaceAll(',', '.')) ?? 0,
                  ),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                t.items_section,
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
        Column(
          children: [
            for (int i = 0; i < vm.items.length; i++)
              OrderItemWidget(
                index: i,
                item: vm.items[i],
                onChanged: (it) => vm.updateItem(i, it),
                onRemove: () => vm.removeItem(i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Usługi dodatkowe',
          child: Column(
            children: [
              CheckboxListTile(
                value: vm.services,
                onChanged: (v) {
                  vm.services = v ?? false;
                  vm.notifyListeners();
                },
                title: const Text('Serwisy (dodatkowe czynności)'),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: vm.preAdvice,
                onChanged: (v) {
                  vm.preAdvice = v ?? false;
                  vm.notifyListeners();
                },
                title: const Text('Awizacja'),
                contentPadding: EdgeInsets.zero,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Dodatkowe ubezpieczenie CARGO (wartość)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) => vm.insuranceValue = double.tryParse(v.replaceAll(',', '.')) ?? 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _kv('CBM', vm.cbmTotal),
            const SizedBox(height: 4),
            const Divider(),
            _kv('Suma (ALL-IN)', vm.totalPrice, emphasize: true),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PositiveActionButton(
              icon: Icons.calculate,
              label: 'Przelicz',
              onPressed: vm.calculate,
            ),
            NeutralActionButton(
              icon: Icons.delete_outline,
              label: t.action_clear,
              onPressed: vm.clear,
            ),
            PositiveActionButton(
              icon: Icons.send,
              label: t.action_submit_order,
              onPressed: vm.submit,
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
  }) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 2),
          lastDate: DateTime(now.year + 1),
        );
        onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value != null ? "${value.toLocal()}".split(' ')[0] : '—'),
      ),
    );
  }
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

class OrderItemWidget extends StatelessWidget {
  final int index;
  final OrderItem item;
  final ValueChanged<OrderItem> onChanged;
  final VoidCallback onRemove;

  const OrderItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title = 'Pozycja ${index + 1}';
    final content = Column(
      children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Ilość (szt)'),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final q = int.tryParse(v) ?? 0;
                onChanged(item..qty = q);
              },
              controller: TextEditingController(text: item.qty?.toString() ?? '')
                ..selection = TextSelection.collapsed(offset: (item.qty?.toString() ?? '').length),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _PackDropdown(
              value: item.packType ?? 'EUR-1 (1,2x0,8)',
              onChanged: (v) => onChanged(item..packType = v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CheckboxListTile(
              value: item.adr,
              onChanged: (v) => onChanged(item..adr = (v ?? false)),
              title: const Text('ADR'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _numField(
              label: 'Długość (cm)',
              value: item.lengthCm,
              onChanged: (d) => onChanged(item..lengthCm = d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              label: 'Szerokość (cm)',
              value: item.widthCm,
              onChanged: (d) => onChanged(item..widthCm = d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              label: 'Wysokość (cm)',
              value: item.heightCm,
              onChanged: (d) => onChanged(item..heightCm = d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              label: 'Waga rzeczywista (kg)',
              value: item.weightKg,
              onChanged: (d) => onChanged(item..weightKg = d),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: Text('CBM pozycji: ${item.cbm.toStringAsFixed(3)}')),
            IconButton(
              tooltip: 'Usuń pozycję',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _numField({
    required String label,
    required double? value,
    required ValueChanged<double> onChanged,
  }) {
    final txt = (value == null) ? '' : value.toString();
    final controller = TextEditingController(text: txt)
      ..selection = TextSelection.collapsed(offset: txt.length);
    return TextField(
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: controller,
      onChanged: (v) => onChanged(double.tryParse(v.replaceAll(',', '.')) ?? 0),
    );
  }
}

class _PackDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _PackDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const packs = <String>[
      'EUR-1 (1,2x0,8)',
      'EUR-2 (1,2x1,0)',
      'Kartony',
      'Skrzynie',
    ];
    return DropdownButtonFormField<String>(
      initialValue: packs.contains(value) ? value : packs.first,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Typ opakowania'),
      items: packs.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      onChanged: (v) => onChanged(v ?? packs.first),
    );
  }
}
