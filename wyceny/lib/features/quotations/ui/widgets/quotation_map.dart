import 'package:flutter/material.dart';

class QuotationMap extends StatelessWidget {
  const QuotationMap({super.key});

  @override
  Widget build(BuildContext context) {
    // Tu możesz podmienić na google_maps_flutter / mapy OpenStreetMap
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.map, size: 64),
          SizedBox(height: 8),
          Text("MAPA (widget niezależny)"),
        ],
      ),
    );
  }
}
