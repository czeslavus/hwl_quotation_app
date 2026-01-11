import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:wyceny/app/locale_controller.dart';

import 'package:wyceny/features/auth/ui/viewmodels/login_view_model.dart';
import 'package:wyceny/app/auth.dart';
import 'package:wyceny/features/logs/data/service/log_uploader.dart';
import 'package:wyceny/features/logs/data/service/logger_service.dart';
import 'package:wyceny/app/env/app_environment.dart';
import 'package:wyceny/app/env/env_config.dart';
import 'package:wyceny/core/network/dio_client.dart';

import 'package:wyceny/features/auth/data/services/token_storage.dart';
import 'package:wyceny/app/router.dart';

import 'package:wyceny/features/auth/domain/services/auth_service.dart';
import 'package:wyceny/features/auth/data/services/auth_service_impl.dart';
import 'package:wyceny/features/auth/domain/repositories/auth_repository.dart';
import 'package:wyceny/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:wyceny/features/auth/ui/viewmodels/recover_set_password_viewmodel.dart';
import 'package:wyceny/features/orders/data/orders_repository_mock.dart';
import 'package:wyceny/features/orders/domain/orders_repository.dart';
import 'package:wyceny/features/orders/ui/viewmodels/order_viewmodel.dart';
import 'package:wyceny/features/orders/ui/viewmodels/orders_list_viewmodel.dart';
import 'package:wyceny/features/quotations/data/quotation_repository_mock.dart';
import 'package:wyceny/features/quotations/domain/quotations_repository.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/features/quotations/ui/viewmodels/quotations_list_viewmodel.dart';

import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';
import 'package:wyceny/features/dictionaries/data/dictionaries_repository_mock.dart';
import 'package:wyceny/features/dictionaries/data/dictionaries_repository_impl.dart';

import 'package:wyceny/features/auth/data/services/token_storage/token_storage_secure.dart'
    if (dart.library.html) 'package:wyceny/features/auth/data/services/token_storage/token_storage_web_secure.dart';
import 'package:wyceny/features/route_by_postcode/data/ors_api.dart';
import 'package:wyceny/features/route_by_postcode/data/route_repository_ors.dart';
import 'package:wyceny/features/route_by_postcode/domain/route_repository.dart';
//    if (dart.library.html) 'package:wyceny/features/auth/data/services/token_storage/token_storage_memory_web.dart'; // bez pamiętania

final getIt = GetIt.instance;

// Przełącznik - zmień na 'false', aby używać prawdziwego API
const bool USE_MOCK_API = true;

Future<void> setupDI() async {
  // Konfiguracja środowiska
  final envConfig = EnvLoader.fromDartDefine();
  getIt.registerSingleton<EnvConfig>(envConfig);

  // singletony
  getIt.registerSingleton<LogService>(LogService());

  getIt.registerLazySingleton<LocaleController>(() => LocaleController());

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<TokenStorage>(() => createPlatformTokenStorage());

  Future<String?> refreshFn(String? refreshToken) async {
    if (refreshToken == null || refreshToken.isEmpty) return null;
    final ok = await getIt<AuthService>().refreshAccessToken();
    if (!ok) return null;
    return await getIt<TokenStorage>().read(kAccessTokenKey);
  }


  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(
      repository: getIt<AuthRepository>(),
      storage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthState>(() => AuthState(
      service: getIt<AuthService>()
  ));

  getIt.registerLazySingleton<Dio>(() {
    final storage = getIt<TokenStorage>();
    final client = DioClient(
      envConfig,
      storage,
      refreshFn: refreshFn,
      onRefreshFailed: () => getIt<AuthState>().logout(), // leniwa rezolucja
    );
    return client.instance;
  });


  getIt.registerLazySingleton<LogUploader>(() {
    final dio = getIt<Dio>();
    final endpoint = Uri.parse("${envConfig.baseUrl}/logs");
    return LogUploader(dio: dio, endpoint: endpoint);
  });

  getIt.registerLazySingleton<GoRouter>(() => buildRouter(getIt<AuthState>()));

  if (USE_MOCK_API) {
    getIt.registerLazySingleton<DictionariesRepository>(() => DictionariesRepositoryMock());
  } else {
    getIt.registerLazySingleton<DictionariesRepository>(() => DictionariesRepositoryImpl(getIt<Dio>()));
  }

  getIt.registerLazySingleton<MockQuotationsRepository>(() => MockQuotationsRepository());
  getIt.registerLazySingleton<QuotationsRepository>(() => getIt<MockQuotationsRepository>());
  getIt.registerLazySingleton<OrdersRepository>(() => MockOrdersRepository(getIt<MockQuotationsRepository>()));


  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.openrouteservice.org',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        // Authorization dodamy w OrsApi albo tu – jak wolisz
      },
    ));
    return dio;
  }, instanceName: 'orsDio');

  final orsKey = envConfig.orsKey;

  getIt.registerLazySingleton<OrsApi>(() => OrsApi(
    apiKey: orsKey,
    dio: getIt<Dio>(instanceName: 'orsDio'),
  ));

  getIt.registerLazySingleton<RouteRepository>(
        () => OrsRouteRepository(getIt<OrsApi>()),
  );

  // if (USE_MOCK_API) {
  //   getIt.registerLazySingleton<LineRidesService>(
  //     () => MockLineRidesServiceImpl(),
  //   );
  // } else {
  //   getIt.registerLazySingleton<LineRidesService>(
  //     () => LineRidesServiceImpl(
  //         getIt<Dio>(),
  //         () async => (await Connectivity().checkConnectivity()) != ConnectivityResult.none,
  //     ),
  //   );
  // }


  // ViewModels (factory, bo zależy nam na świeżych instancjach)
  getIt.registerFactory<RecoverSetPasswordViewModel>(
    () => RecoverSetPasswordViewModel(getIt<AuthService>()),
  );
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<AuthState>()),
  );

  getIt.registerFactory<QuotationsListViewModel>(() => QuotationsListViewModel(repo: getIt<QuotationsRepository>(), auth: getIt<AuthState>() ));
  getIt.registerFactory<QuotationViewModel>(() => QuotationViewModel());

  getIt.registerFactory<OrdersListViewModel>(() => OrdersListViewModel());
  getIt.registerFactory<OrderViewModel>(() => OrderViewModel());

  await getIt<DictionariesRepository>().preload();
  await getIt.allReady();
}
