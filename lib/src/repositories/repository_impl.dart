import 'package:awesomapp/src/repositories/repository.dart';
import '../models/photo_model.dart';
import '../service/http_service.dart';

class PhotoRepositoryImpl implements Repository {
  final HttpService httpService;

  PhotoRepositoryImpl(this.httpService);

  @override
  Future<List<Photo>> fetchPhotos({int page = 1, int perPage = 10}) {
    return httpService.fetchPhotos(page: page, perPage: perPage);
  }
}