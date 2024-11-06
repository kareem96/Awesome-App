import '../models/photo_model.dart';
import '../service/http_service.dart';

class Repository {
  final HttpService httpService;

  Repository(this.httpService);

  Future<List<Photo>> fetchPhotos({int page = 1, int perPage = 10}) {
    return httpService.fetchPhotos(page: page, perPage: perPage);
  }
}