import 'package:awesomapp/src/repositories/repository.dart';
import 'package:awesomapp/src/service/http_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => HttpService(getIt()));
  getIt.registerLazySingleton(() => Repository(getIt()));
}