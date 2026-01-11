import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/ui/widgets/common/route_map_by_postcode.dart';

class QuotationRouteMap extends StatelessWidget {
  const QuotationRouteMap({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuotationViewModel>();
    return RouteMapByPostcode(
      originZip: vm.originZip,
      destinationZip: vm.destinationZip,
      originCountryCode: vm.countryCodeForId(vm.originCountryId),
      destinationCountryCode: vm.countryCodeForId(vm.destinationCountryId),
    );
  }
}
