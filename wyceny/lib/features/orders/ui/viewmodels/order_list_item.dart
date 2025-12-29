
import 'package:wyceny/features/dictionaries/domain/models/country_dictionary.dart';

class OrderListItem {
  final String? id;
  final String? orderNr;
  final String? status;
  final DateTime? createdAt;

  final CountryDictionary? originCountry;
  final String? originZip;
  final CountryDictionary? destCountry;
  final String? destZip;

  final int itemsCount;
  final double? weightChg; // chargeable weight
  final double? total;     // all-in

  OrderListItem({
    required this.id,
    required this.orderNr,
    required this.status,
    required this.createdAt,
    required this.originCountry,
    required this.originZip,
    required this.destCountry,
    required this.destZip,
    required this.itemsCount,
    required this.weightChg,
    required this.total,
  });
}
