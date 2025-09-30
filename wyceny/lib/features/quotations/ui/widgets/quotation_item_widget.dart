import 'package:flutter/material.dart';
import '../viewmodels/quotation_viewmodel.dart';

class QuotationItemWidget extends StatelessWidget {
  final int index;
  final QuotationItem item;
  final ValueChanged<QuotationItem> onChanged;
  final VoidCallback onRemove;
  final bool isPhone;

  const QuotationItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onRemove,
    this.isPhone = false,
  });

  double _fieldWidth(BuildContext context, double desktopWidth) {
    if (!isPhone) return desktopWidth;
    // Na telefonie celujemy w ~połowę szerokości z marginesami,
    // ale zostawiamy minimum 150px, by etykiety się mieściły.
    final w = MediaQuery.sizeOf(context).width;
    final target = (w - 16 - 16 - 12) / 2; // padding L/R + spacing
    return target.clamp(150, 220);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Pola formularza w elastycznym Wrap
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: _fieldWidth(context, 100),
                    child: _num(
                      "Ilość (szt.)",
                      item.quantity.toString(),
                          (v) => onChanged(item..quantity = int.tryParse(v) ?? 1),
                    ),
                  ),
                  SizedBox(
                    width: _fieldWidth(context, 120),
                    child: _num(
                      "Długość (cm)",
                      item.length.toStringAsFixed(0),
                          (v) => onChanged(item..length = double.tryParse(v) ?? 0),
                    ),
                  ),
                  SizedBox(
                    width: _fieldWidth(context, 120),
                    child: _num(
                      "Szerokość (cm)",
                      item.width.toStringAsFixed(0),
                          (v) => onChanged(item..width = double.tryParse(v) ?? 0),
                    ),
                  ),
                  SizedBox(
                    width: _fieldWidth(context, 120),
                    child: _num(
                      "Wysokość (cm)",
                      item.height.toStringAsFixed(0),
                          (v) => onChanged(item..height = double.tryParse(v) ?? 0),
                    ),
                  ),
                  SizedBox(
                    width: _fieldWidth(context, 160),
                    child: _num(
                      "Waga 1 opak. (kg)",
                      item.weight.toStringAsFixed(1),
                          (v) => onChanged(item..weight = double.tryParse(v) ?? 0),
                      decimal: true,
                    ),
                  ),
                  SizedBox(
                    width: _fieldWidth(context, 160),
                    child: DropdownButtonFormField<String>(
                      value: item.packageType,
                      items: const ["Paleta", "Paczka", "Karton"]
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => onChanged(item..packageType = v ?? "Paleta"),
                      decoration: const InputDecoration(labelText: "Typ opakowania"),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: item.dangerous,
                          onChanged: (v) => onChanged(item..dangerous = v ?? false),
                        ),
                        const Text("ADR"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Kosz zawsze po prawej
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: "Usuń pozycję",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _num(String label, String initial, ValueChanged<String> onChanged, {bool decimal = false}) {
    return TextFormField(
      initialValue: initial,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true, signed: false)
          : TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onChanged(v.replaceAll(',', '.')),
    );
  }
}
