import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/photo_model.dart';
import '../service/http_service.dart';
import 'photo_event.dart';
import 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final PhotoService photoService;
  List<Photo> allPhotos = [];
  bool isLoadingMore = false;

  PhotoBloc(this.photoService) : super(PhotoInitial()) {
    on<LoadPhotos>((event, emit) async {
      if (isLoadingMore) return;
      isLoadingMore = true;

      try {
        if (allPhotos.isEmpty) emit(PhotoLoading());

        final photos = await photoService.fetchPhotos(page: event.page);

        if (photos.isNotEmpty) {
          allPhotos.addAll(photos);
          emit(PhotoLoaded(List.from(allPhotos)));
        } else {
          emit(PhotoLoaded(allPhotos));
        }
      } catch (e) {
        emit(PhotoError(e.toString()));
      } finally {
        isLoadingMore = false;
      }
    });
  }
}