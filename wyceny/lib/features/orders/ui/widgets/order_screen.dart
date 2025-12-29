import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_viewmodel.dart';
import 'package:wyceny/l10n/country_localizer.dart';
import 'package:wyceny/features/quotations/ui/widgets/quotation_map.dart';

// ======== ViewModel – wymagane pola/metody (dopasuj do siebie) ========
// class OrderViewModel extends ChangeNotifier {
//   String customerName = "";
//   String contractorName = "";
//   bool countriesLoading = false;
//   Object? countriesError;
//   List<Country> countries = const [];
//
//   // Nadawca / Odbiorca
//   int? originCountryId;
//   int? destinationCountryId;
//   String originZip = "";
//   String destZip = "";
//   String senderName = ""; String senderCity = ""; String senderStreet = ""; String senderPhone = "";
//   String recipientName = ""; String recipientCity = ""; String recipientStreet = ""; String recipientPhone = "";
//
//   // Usługi i ubezpieczenie
//   bool services = false;
//   bool preAdvice = false;
//   double insuranceValue = 0;
//
//   // Pozycje
//   final List<OrderItem> items = [];
//   void addItem(); void updateItem(int i, OrderItem it); void removeItem(int i);
//
//   // Wyliczenia / akcje
//   double get cbmTotal => 0;
//   double get totalPrice => 0;
//   void setOriginCountry(int? id); void setDestinationCountry(int? id);
//   void init(); void calculate(); void clear(); void submit();
// }
//
// class OrderItem {
//   int qty;
//   String packType; // np. "EUR-1 (1,2x0,8)"
//   double lengthCm, widthCm, heightCm, weightKg;
//   bool adr;
//   OrderItem({ /* ... */ });
//   double get cbm => qty * (lengthCm/100.0) * (widthCm/100.0) * (heightCm/100.0);
// }
// ======================================================================

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>(); // <- podmień na OrderViewModel
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                // np. „Klient: X • Kontrahent: Y”
                "Klient: ${vm.customerName} • Kontrahent: ${vm.contractorName}",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () {/* logout */},
              icon: const Icon(Icons.logout),
              label: const Text("Wyloguj"),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isPhone = c.maxWidth < 600;
          final isWide  = c.maxWidth >= 1100;

          final left = _LeftPaneOrder(vm: vm, isPhone: isPhone);
          const right = QuotationMap();

          if (isWide) {
            return Row(
              children: const [
                Expanded(flex: 2, child: _ScrollWrapper(child: _LeftPaneOrder.passThrough())),
                VerticalDivider(width: 1),
                Expanded(flex: 1, child: QuotationMap()),
              ],
            ).withInjected(leftChild: left); // mały trick poniżej
          } else {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                left,
                const Divider(height: 1),
                right,
              ],
            );
          }
        },
      ),
    );
  }
}

// Pomocniczy „injection” dla statycznego const drzewa w Row powyżej:
extension _Inject on Row {
  Row withInjected({required Widget leftChild}) {
    final kids = List<Widget>.from(children);
    kids[0] = Expanded(flex: 2, child: leftChild);
    return Row(children: kids);
  }
}

class _ScrollWrapper extends StatelessWidget {
  final Widget child;
  const _ScrollWrapper({required this.child});
  @override
  Widget build(BuildContext context) => ListView(padding: EdgeInsets.zero, children: [child]);
}

/// Lewy panel – formularz nowego zlecenia
class _LeftPaneOrder extends StatelessWidget {
  final dynamic vm; // <- podmień na OrderViewModel
  final bool isPhone;
  const _LeftPaneOrder({required this.vm, required this.isPhone});

  // Używane wyłącznie jako placeholder przy const Row – nie wywołuj bez podmiany:
  const _LeftPaneOrder.passThrough()
      : vm = null,
        isPhone = true;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      // Tytuł
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text("Nowe zlecenie", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("Informacje o liniach międzynarodowych / świętach / ograniczeniach"),
      ),
      const SizedBox(height: 12),

      // === NADAWCA ===
      _SectionCard(
        title: "Nadawca",
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: _CountryDropdown(
                  label: "Kraj nadania",
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
                  decoration: const InputDecoration(labelText: "Kod pocztowy nadania"),
                  onChanged: (v) => vm.originZip = v,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Nazwa"),
                  onChanged: (v) => vm.senderName = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Miasto"),
                  onChanged: (v) => vm.senderCity = v,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Ulica"),
                  onChanged: (v) => vm.senderStreet = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Telefon"),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => vm.senderPhone = v,
                ),
              ),
            ]),
          ],
        ),
      ),

      // === ODBIORCA ===
      _SectionCard(
        title: "Odbiorca",
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: _CountryDropdown(
                  label: "Kraj dostawy",
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
                  decoration: const InputDecoration(labelText: "Kod pocztowy dostawy"),
                  onChanged: (v) => vm.destZip = v,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Nazwa"),
                  onChanged: (v) => vm.recipientName = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Miasto"),
                  onChanged: (v) => vm.recipientCity = v,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Ulica"),
                  onChanged: (v) => vm.recipientStreet = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Telefon"),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => vm.recipientPhone = v,
                ),
              ),
            ]),
          ],
        ),
      ),

      // === POZYCJE ===
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            const Expanded(
              child: Text("Towar / paczki", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            // Zielony, wyraźny plus – wyrównany do prawej
            IconButton.filled(
              onPressed: vm.addItem,
              style: IconButton.styleFrom(backgroundColor: Colors.green),
              icon: const Icon(Icons.add, size: 22),
              tooltip: "Dodaj pozycję",
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (int i = 0; i < vm.items.length; i++)
              OrderItemWidget(
                index: i,
                item: vm.items[i],
                onChanged: (it) => vm.updateItem(i, it),
                onRemove: () => vm.removeItem(i),
                isPhone: isPhone,
              ),
          ],
        ),
      ),

      const SizedBox(height: 8),

      // === Usługi dodatkowe ===
      _SectionCard(
        title: "Usługi dodatkowe",
        child: Column(
          children: [
            CheckboxListTile(
              value: vm.services,
              onChanged: (v) { vm.services = v ?? false; vm.notifyListeners(); },
              title: const Text("Serwisy (dodatkowe czynności)"),
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              value: vm.preAdvice,
              onChanged: (v) { vm.preAdvice = v ?? false; vm.notifyListeners(); },
              title: const Text("Awizacja"),
              contentPadding: EdgeInsets.zero,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Dodatkowe ubezpieczenie CARGO (wartość)"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => vm.insuranceValue = double.tryParse(v.replaceAll(',', '.')) ?? 0,
            ),
          ],
        ),
      ),

      // === Podsumowanie (cbm + koszt) ===
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _kv("CBM", vm.cbmTotal),
            const SizedBox(height: 4),
            const Divider(),
            _kv("Suma (ALL-IN)", vm.totalPrice, emphasize: true),
          ],
        ),
      ),

      const SizedBox(height: 8),

      // === Akcje ===
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton(onPressed: vm.clear, child: const Text("Wyczyść")),
            FilledButton(onPressed: vm.calculate, child: const Text("Przelicz")),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: vm.submit,
              child: const Text("ZATWIERDŹ ZLECENIE"),
            ),
          ],
        ),
      ),
    ];

    // Scroll: taki sam schemat jak w QuotationScreen
    return isPhone
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content)
        : ListView(padding: EdgeInsets.zero, children: content);
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
}

/// Karta-sekcja z tytułem
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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

/// Dropdown krajów – jak w wycenach
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
    if (countriesLoading) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: const SizedBox(
          height: 24,
          child: Align(alignment: Alignment.centerLeft, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    if (countriesError != null) {
      return InputDecorator(
        decoration: InputDecoration(labelText: label, errorText: countriesError.toString()),
        child: TextButton.icon(
          onPressed: () => context.read<dynamic>().init(), // <- podmień na OrderViewModel
          icon: const Icon(Icons.refresh),
          label: const Text("Ponów"),
        ),
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: countries
          .map((c) => DropdownMenuItem<int>(
        value: c.countryId,
        child: Text(CountryLocalizer.localize(c.country, context)),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// POZYCJA ZAMÓWIENIA
class OrderItemWidget extends StatelessWidget {
  final int index;
  final dynamic item; // <- podmień na OrderItem
  final ValueChanged<dynamic> onChanged; // <- ValueChanged<OrderItem>
  final VoidCallback onRemove;
  final bool isPhone;

  const OrderItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onRemove,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final title = "Pozycja ${index + 1}";
    final content = Column(
      children: [
        // Pierwszy wiersz: ilość + typ opakowania
        Row(children: [
          Expanded(
            flex: 1,
            child: TextField(
              decoration: const InputDecoration(labelText: "Ilość (szt)"),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final q = int.tryParse(v) ?? 0;
                onChanged(item..qty = q);
              },
              controller: TextEditingController(text: item.qty?.toString() ?? "")..selection = TextSelection.collapsed(offset: (item.qty?.toString() ?? "").length),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _PackDropdown(
              value: item.packType ?? "EUR-1 (1,2x0,8)",
              onChanged: (v) => onChanged(item..packType = v),
            ),
          ),
          const SizedBox(width: 8),
          // ADR
          Expanded(
            child: CheckboxListTile(
              value: item.adr ?? false,
              onChanged: (v) => onChanged(item..adr = (v ?? false)),
              title: const Text("ADR"),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ]),

        const SizedBox(height: 8),

        // Drugi wiersz: L / W / H / Waga
        Row(children: [
          Expanded(
            child: _numField(
              label: "Długość (cm)",
              value: item.lengthCm,
              onChanged: (d) => onChanged(item..lengthCm = d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              label: "Szerokość (cm)",
              value: item.widthCm,
              onChanged: (d) => onChanged(item..widthCm = d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              label: "Wysokość (cm)",
              value: item.heightCm,
              onChanged: (d) => onChanged(item..heightCm = d),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numField(
              label: "Waga rzeczywista (kg)",
              value: item.weightKg,
              onChanged: (d) => onChanged(item..weightKg = d),
            ),
          ),
        ]),

        const SizedBox(height: 8),
        // Podsumowanie pozycji + usuń
        Row(
          children: [
            Expanded(
              child: Text("CBM pozycji: ${item.cbm.toStringAsFixed(3)}"),
            ),
            IconButton(
              tooltip: "Usuń pozycję",
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            )
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
    final txt = (value == null) ? "" : value.toString();
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

/// Dropdown typów opakowań (przykładowe)
class _PackDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _PackDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const packs = <String>[
      "EUR-1 (1,2x0,8)",
      "EUR-2 (1,2x1,0)",
      "Kartony",
      "Skrzynie",
    ];
    return DropdownButtonFormField<String>(
      initialValue: packs.contains(value) ? value : packs.first,
      isExpanded: true,
      decoration: const InputDecoration(labelText: "Typ opakowania"),
      items: packs.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
      onChanged: (v) => onChanged(v ?? packs.first),
    );
  }
}
