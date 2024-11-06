import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/photo_model.dart';
import '../repositories/repository.dart';
import 'photo_event.dart';
import 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final Repository repository;
  List<Photo> allPhotos = [];
  bool isLoadingMore = false;

  PhotoBloc(this.repository) : super(PhotoInitial()) {
    on<LoadPhotos>((event, emit) async {
      if (isLoadingMore) return;
      isLoadingMore = true;

      try {
        if (event.page == 1 || allPhotos.isEmpty) {
          emit(PhotoLoading());
        }

        final photos = await repository.fetchPhotos(page: event.page);

        if (photos.isNotEmpty) {
          if (event.page == 1) {
            allPhotos.clear();
          }
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