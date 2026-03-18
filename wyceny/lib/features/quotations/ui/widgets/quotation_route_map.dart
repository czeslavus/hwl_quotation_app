import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyceny/app/di/locator.dart';
import 'package:wyceny/features/logs/data/service/logger_service.dart';

import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/features/route_by_postcode/ui/widgets/route_map_by_postcode.dart';

class QuotationRouteMap extends StatelessWidget {
  const QuotationRouteMap({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuotationViewModel>();
    final originCountryCode = vm.countryCodeForId(vm.originCountryId);
    final destinationCountryCode = vm.countryCodeForId(vm.destinationCountryId);
    getIt<LogService>().logger.i(
      '[quote-map] build originZip=${vm.originZip} originCountryId=${vm.originCountryId} originCode=$originCountryCode '
      'destZip=${vm.destinationZip} destCountryId=${vm.destinationCountryId} destCode=$destinationCountryCode',
    );
    return RouteMapByPostcode(
      originZip: vm.originZip,
      destinationZip: vm.destinationZip,
      originCountryCode: originCountryCode,
      destinationCountryCode: destinationCountryCode,
    );
  }
}
