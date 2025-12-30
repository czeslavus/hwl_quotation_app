import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/domain/models/models.dart';

class DictionariesRepositoryImpl implements DictionariesRepository {
  DictionariesRepositoryImpl(
      this._dio, {
        String Function(int countryId, String? countryName)? resolveCountryIso2,
      }) : _resolveCountryIso2 = resolveCountryIso2;

  final Dio _dio;
  final String Function(int countryId, String? countryName)? _resolveCountryIso2;

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

  // --- getters (unmodifiable) ---
  @override
  List<CountryDictionary> get countries => UnmodifiableListView(_countries);

  @override
  List<CountryDictionary> get countriesDelivery => UnmodifiableListView(_countriesDelivery);

  @override
  List<CountryDictionary> get countriesReceipt => UnmodifiableListView(_countriesReceipt);

  @override
  AdditionsDictionary? get additions => _additions;

  @override
  List<AdditionsDictionaryClassic> get additionsV2 => UnmodifiableListView(_additionsV2);

  @override
  List<ServicesDictionary> get services => UnmodifiableListView(_services);

  @override
  List<StatusesDictionary> get statuses => UnmodifiableListView(_statuses);

  @override
  List<RejectCausesDictionary> get rejectCauses => UnmodifiableListView(_rejectCauses);

  @override
  List<ADRNameDictionary> get adrNames => UnmodifiableListView(_adrNames);

  @override
  List<ADRPackageUnitTypeDictionary> get adrPackageUnits => UnmodifiableListView(_adrPackageUnits);

  @override
  List<StageTTDictionary> get stageTtStatuses => UnmodifiableListView(_stageTt);

  @override
  List<LoadUnitDictionary> get loadUnits => UnmodifiableListView(_loadUnits);

  @override
  List<InstructionCodeDictionary> get instructionCodes => UnmodifiableListView(_instructionCodes);

  @override
  Future<void> preload() async {
    if (_loaded) return;

    // Ładujemy wszystko równolegle (szybciej po starcie)
    await Future.wait([
      _loadCountries(),
      _loadCountriesDelivery(),
      _loadCountriesReceipt(),
      _loadAdditions(),
      _loadAdditionsV2(),
      _loadServices(),
      _loadStatuses(),
      _loadRejectCauses(),
      _loadAdrNames(),
      _loadAdrPackageUnits(),
      _loadStageTtStatuses(),
      _loadLoadUnits(),
      _loadInstructionCodes(),
    ]);

    _loaded = true;
  }

  // -------- loaders --------

  Future<void> _loadCountries() async {
    final data = await _getList('/api/dictionaries/countries');
    _countries = data
        .map((e) => CountryDictionary.fromJson(
      e,
      resolveIso2: _resolveCountryIso2,
    ))
        .toList(growable: false);
  }

  Future<void> _loadCountriesDelivery() async {
    final data = await _getList('/api/dictionaries/countries-delivery');
    _countriesDelivery = data
        .map((e) => CountryDictionary.fromJson(
      e,
      resolveIso2: _resolveCountryIso2,
    ))
        .toList(growable: false);
  }

  Future<void> _loadCountriesReceipt() async {
    final data = await _getList('/api/dictionaries/countries-receipt');
    _countriesReceipt = data
        .map((e) => CountryDictionary.fromJson(
      e,
      resolveIso2: _resolveCountryIso2,
    ))
        .toList(growable: false);
  }

  Future<void> _loadAdditions() async {
    final json = await _getObject('/api/dictionaries/additions');
    _additions = AdditionsDictionary.fromJson(json);
  }

  Future<void> _loadAdditionsV2() async {
    final data = await _getList('/api/dictionaries/additions-v2');
    _additionsV2 = data.map((e) => AdditionsDictionaryClassic.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadServices() async {
    final data = await _getList('/api/dictionaries/services');
    _services = data.map((e) => ServicesDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadStatuses() async {
    final data = await _getList('/api/dictionaries/statuses');
    _statuses = data.map((e) => StatusesDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadRejectCauses() async {
    final data = await _getList('/api/dictionaries/reject-causes');
    _rejectCauses = data.map((e) => RejectCausesDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadAdrNames() async {
    final data = await _getList('/api/dictionaries/adr-names');
    _adrNames = data.map((e) => ADRNameDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadAdrPackageUnits() async {
    final data = await _getList('/api/dictionaries/adr-package-units');
    _adrPackageUnits =
        data.map((e) => ADRPackageUnitTypeDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadStageTtStatuses() async {
    final data = await _getList('/api/dictionaries/stagett-statuses');
    _stageTt = data.map((e) => StageTTDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadLoadUnits() async {
    final data = await _getList('/api/dictionaries/load-units');
    _loadUnits = data.map((e) => LoadUnitDictionary.fromJson(e)).toList(growable: false);
  }

  Future<void> _loadInstructionCodes() async {
    final data = await _getList('/api/dictionaries/instruction-codes');
    _instructionCodes = data.map((e) => InstructionCodeDictionary.fromJson(e)).toList(growable: false);
  }

  // -------- dio helpers --------

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final res = await _dio.get(path);
    final data = res.data;

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList(growable: false);
    }

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: 'Expected JSON array from $path, got: ${data.runtimeType}',
    );
  }

  Future<Map<String, dynamic>> _getObject(String path) async {
    final res = await _dio.get(path);
    final data = res.data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: 'Expected JSON object from $path, got: ${data.runtimeType}',
    );
  }
}
