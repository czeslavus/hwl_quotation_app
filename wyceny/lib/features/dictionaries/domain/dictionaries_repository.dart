import 'package:wyceny/features/dictionaries/domain/models/models.dart';

abstract class DictionariesRepository {
  /// Wywołaj raz po starcie aplikacji.
  Future<void> preload();

  /// Czy repo ma już dane w pamięci.
  bool get isLoaded;

  // --- API: Countries (3 endpointy, taki sam model) ---
  List<CountryDictionary> get countries;
  List<CountryDictionary> get countriesDelivery;
  List<CountryDictionary> get countriesReceipt;

  // --- API: Additions (2 endpointy, różne modele) ---
  AdditionsDictionary? get additions; // /additions
  List<AdditionsDictionaryClassic> get additionsV2; // /additions-v2

  // --- API: pozostałe listy ---
  List<ServicesDictionary> get services;
  List<StatusesDictionary> get statuses;
  List<RejectCausesDictionary> get rejectCauses;
  List<ADRNameDictionary> get adrNames;
  List<ADRPackageUnitTypeDictionary> get adrPackageUnits;
  List<StageTTDictionary> get stageTtStatuses;
  List<LoadUnitDictionary> get loadUnits;
  List<InstructionCodeDictionary> get instructionCodes;
}
