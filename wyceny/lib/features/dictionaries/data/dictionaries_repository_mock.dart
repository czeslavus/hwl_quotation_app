import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/models.dart';

class DictionariesRepositoryMock implements DictionariesRepository {
  bool _loaded = false;

  List<CountryDictionary> _countries = const [];
  List<CountryDictionary> _countriesDelivery = const [];
  List<CountryDictionary> _countriesReceipt = const [];

  AdditionsDictionary? _additions;
  List<AdditionsDictionaryClassic> _additionsV2 = const [];

  List<ServicesDictionary> _services = const [];
  List<StatusesDictionary> _statuses = const [];
  List<RejectCausesDictionary> _rejectCauses = const [];
  List<ADRNameDictionary> _adrNames = const [];
  List<ADRPackageUnitTypeDictionary> _adrPackageUnits = const [];
  List<StageTTDictionary> _stageTt = const [];
  List<LoadUnitDictionary> _loadUnits = const [];
  List<InstructionCodeDictionary> _instructionCodes = const [];

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> preload() async {
    if (_loaded) return;

    _countries = const [
      CountryDictionary(countryId: 1, country: 'Poland', countryCode: 'PL'),
      CountryDictionary(countryId: 2, country: 'Germany', countryCode: 'DE'),
      CountryDictionary(countryId: 3, country: 'Czechia', countryCode: 'CZ'),
      CountryDictionary(countryId: 4, country: 'Austria', countryCode: 'AT'),
    ];

    // w mocku kopiujemy, ale możesz różnicować
    _countriesDelivery = List.of(_countries);
    _countriesReceipt = const [
      CountryDictionary(countryId: 1, country: 'Poland', countryCode: 'PL'),
    ];

    _additions = const AdditionsDictionary(
      bafValue: 12.5,
      tafValue: 8.0,
      inflCorrectionValue: 1.2,
    );

    _additionsV2 = const [
      AdditionsDictionaryClassic(type: 'LIFTGATE', value: 35.0),
      AdditionsDictionaryClassic(type: 'INSIDE_DELIVERY', value: 22.0),
      AdditionsDictionaryClassic(type: 'INSURANCE', value: 0.0),
    ];

    _services = const [
      ServicesDictionary(serviceId: 1, name: 'FTL', description: 'Full Truck Load'),
      ServicesDictionary(serviceId: 2, name: 'LTL', description: 'Less Than Truck Load'),
    ];

    _statuses = const [
      StatusesDictionary(statusId: 1, name: 'Draft'),
      StatusesDictionary(statusId: 2, name: 'Proposed'),
      StatusesDictionary(statusId: 3, name: 'Approved'),
      StatusesDictionary(statusId: 4, name: 'Rejected'),
    ];

    _rejectCauses = const [
      RejectCausesDictionary(rejectCauseId: 1, rejectCauseName: 'Other'),
      RejectCausesDictionary(rejectCauseId: 2, rejectCauseName: 'Incorrect data'),
      RejectCausesDictionary(rejectCauseId: 3, rejectCauseName: 'Price too high'),
    ];

    _adrNames = const [
      ADRNameDictionary(un: '1202', name: 'GAS OIL', adrClass: '3', packingGroup: 'III', tremcard: '30G26'),
    ];

    _adrPackageUnits = const [
      ADRPackageUnitTypeDictionary(packageUnitTypeNR: 'BX', packageUnitTypeName: 'Box'),
      ADRPackageUnitTypeDictionary(packageUnitTypeNR: 'DR', packageUnitTypeName: 'Drum'),
    ];

    _stageTt = const [
      StageTTDictionary(ttStateNr: '1', tsStateName: 'Created'),
      StageTTDictionary(ttStateNr: '2', tsStateName: 'In transit'),
      StageTTDictionary(ttStateNr: '3', tsStateName: 'Delivered'),
    ];

    _loadUnits = const [
      LoadUnitDictionary(loadUnitTypeId: 1, loadUnitTypeNr: 'PAL', loadUnitTypeName: 'Pallet'),
      LoadUnitDictionary(loadUnitTypeId: 2, loadUnitTypeNr: 'BOX', loadUnitTypeName: 'Box'),
    ];

    _instructionCodes = const [
      InstructionCodeDictionary(instructionCodeId: 1, instructionCodeNr: 'CALL', instructionCodeName: 'Call before delivery'),
      InstructionCodeDictionary(instructionCodeId: 2, instructionCodeNr: 'LIFT', instructionCodeName: 'Liftgate required'),
    ];

    _loaded = true;
  }

  // --- getters ---
  @override
  List<CountryDictionary> get countries => _countries;
  @override
  List<CountryDictionary> get countriesDelivery => _countriesDelivery;
  @override
  List<CountryDictionary> get countriesReceipt => _countriesReceipt;

  @override
  AdditionsDictionary? get additions => _additions;
  @override
  List<AdditionsDictionaryClassic> get additionsV2 => _additionsV2;

  @override
  List<ServicesDictionary> get services => _services;
  @override
  List<StatusesDictionary> get statuses => _statuses;
  @override
  List<RejectCausesDictionary> get rejectCauses => _rejectCauses;
  @override
  List<ADRNameDictionary> get adrNames => _adrNames;
  @override
  List<ADRPackageUnitTypeDictionary> get adrPackageUnits => _adrPackageUnits;
  @override
  List<StageTTDictionary> get stageTtStatuses => _stageTt;
  @override
  List<LoadUnitDictionary> get loadUnits => _loadUnits;
  @override
  List<InstructionCodeDictionary> get instructionCodes => _instructionCodes;
}
