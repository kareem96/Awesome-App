// Annotate this function to generate mocks for HttpService and Repository
import 'package:awesomapp/src/repositories/repository.dart';
import 'package:awesomapp/src/service/http_service.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;


@GenerateMocks([HttpService, Repository, http.Client])
void main() {}