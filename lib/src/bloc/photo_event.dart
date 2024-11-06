import 'package:equatable/equatable.dart';

abstract class PhotoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadPhotos extends PhotoEvent {
  final int page;

  LoadPhotos({this.page = 1});

  @override
  List<Object> get props => [page];
}