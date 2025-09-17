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

import 'package:wyceny/features/auth/data/services/token_storage/token_storage_secure.dart'
//    if (dart.library.html) 'package:wyceny/features/auth/data/services/token_storage/token_storage_memory_web.dart'; // bez pamiętania
    if (dart.library.html) 'package:wyceny/features/auth/data/services/token_storage/token_storage_web_secure.dart';

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

  // getIt.registerLazySingleton<ApiService>(() => ApiServiceImpl(getIt<Dio>(), getIt<OutboxRepository>()));


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

  await getIt.allReady();
}
