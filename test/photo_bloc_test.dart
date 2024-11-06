import 'package:awesomapp/src/bloc/photo_bloc.dart';
import 'package:awesomapp/src/bloc/photo_event.dart';
import 'package:awesomapp/src/bloc/photo_state.dart';
import 'package:awesomapp/src/models/photo_model.dart';
import 'package:awesomapp/src/repositories/repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

void main() {
  late MockHttpService mockHttpService;
  late Repository repository;

  setUp(() {
    mockHttpService = MockHttpService();
    repository = Repository(mockHttpService);
  });

  group('HttpService', () {
    test('fetchPhotos returns a list of Photos on success', () async {
      // Arrange
      final mockPhotosJson = [
        {
          'id': 1,
          'photographer': 'John Doe',
          'src': {
            'large': 'https://samplephoto.com/photo1_large',
            'medium': 'https://samplephoto.com/photo1_medium'
          }
        },
        {
          'id': 2,
          'photographer': 'Jane Doe',
          'src': {
            'large': 'https://samplephoto.com/photo2_large',
            'medium': 'https://samplephoto.com/photo2_medium'
          }
        },
      ];

      when(mockHttpService.fetchPhotos(page: anyNamed('page'), perPage: anyNamed('perPage')))
          .thenAnswer((_) async => mockPhotosJson.map((e) => Photo.fromJson(e)).toList());

      // Act
      final photos = await repository.fetchPhotos(page: 1, perPage: 2);

      // Assert
      expect(photos, isA<List<Photo>>());
      expect(photos.length, equals(2));
      expect(photos.first.thumbnailUrl, 'https://samplephoto.com/photo1_medium');
    });

    test('fetchPhotos throws an exception on failure', () async {
      // Arrange
      when(mockHttpService.fetchPhotos(page: anyNamed('page'), perPage: anyNamed('perPage')))
          .thenThrow(Exception('Failed to load photos'));

      // Act & Assert
      expect(() => repository.fetchPhotos(page: 1, perPage: 10), throwsException);
    });
  });

  group('PhotoBloc', () {
    late PhotoBloc photoBloc;
    late MockRepository mockRepository;

    setUp(() {
      mockRepository = MockRepository();
      photoBloc = PhotoBloc(mockRepository);
    });

    blocTest<PhotoBloc, PhotoState>(
      'emits [PhotoLoading, PhotoLoaded] when photos are loaded successfully',
      build: () {
        when(mockRepository.fetchPhotos(page: 1)).thenAnswer((_) async => [
          Photo(id: "1", thumbnailUrl: 'https://samplephoto.com/photo1_medium', photographer: 'John Doe', photoUrl: ''),
          Photo(id: "2", thumbnailUrl: 'https://samplephoto.com/photo2_medium', photographer: 'Jane Doe', photoUrl: ''),
        ]);
        return photoBloc;
      },
      act: (bloc) => bloc.add(LoadPhotos(page: 1)),
      expect: () => [
        PhotoLoading(),
        isA<PhotoLoaded>().having((state) => state.photos.length, 'photos length', 2)
            .having((state) => state.photos.first.thumbnailUrl, 'first photo thumbnailUrl', 'https://samplephoto.com/photo1_medium'),
      ],
    );

    blocTest<PhotoBloc, PhotoState>(
      'emits [PhotoLoading, PhotoError] when an exception is thrown',
      build: () {
        when(mockRepository.fetchPhotos(page: 1)).thenThrow(Exception('Failed to load photos'));
        return photoBloc;
      },
      act: (bloc) => bloc.add(LoadPhotos(page: 1)),
      expect: () => [
        PhotoLoading(),
        PhotoError('Exception: Failed to load photos'),
      ],
    );
  });
}