import 'package:flutter/material.dart';
import '../viewmodels/quotation_viewmodel.dart';

class QuotationItemWidget extends StatelessWidget {
  final int index;
  final QuotationItem item;
  final ValueChanged<QuotationItem> onChanged;
  final VoidCallback onRemove;

  const QuotationItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // pola formularza w elastycznym Wrap
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _num("Ilość (szt.)", item.quantity.toString(),
                          (v) => onChanged(item..quantity = int.tryParse(v) ?? 1),
                      width: 100),
                  _num("Długość (cm)", item.length.toStringAsFixed(0),
                          (v) => onChanged(item..length = double.tryParse(v) ?? 0),
                      width: 120),
                  _num("Szerokość (cm)", item.width.toStringAsFixed(0),
                          (v) => onChanged(item..width = double.tryParse(v) ?? 0),
                      width: 120),
                  _num("Wysokość (cm)", item.height.toStringAsFixed(0),
                          (v) => onChanged(item..height = double.tryParse(v) ?? 0),
                      width: 120),
                  _num("Waga 1 opak. (kg)", item.weight.toStringAsFixed(1),
                          (v) => onChanged(item..weight = double.tryParse(v) ?? 0),
                      width: 150),
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      value: item.packageType,
                      items: const ["Paleta", "Paczka", "Karton"]
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) =>
                          onChanged(item..packageType = v ?? "Paleta"),
                      decoration:
                      const InputDecoration(labelText: "Typ opakowania"),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: item.dangerous,
                        onChanged: (v) =>
                            onChanged(item..dangerous = v ?? false),
                      ),
                      const Text("ADR"),
                    ],
                  ),
                ],
              ),
            ),
            // kosz zawsze przy prawej krawędzi
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

  Widget _num(String label, String initial, ValueChanged<String> onChanged,
      {double? width}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        onChanged: (v) => onChanged(v.replaceAll(',', '.')),
      ),
    );
  }
}
