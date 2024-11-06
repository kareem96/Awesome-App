class Photo {
  final String id;
  final String photographer;
  final String photoUrl;
  final String thumbnailUrl;

  Photo({
    required this.id,
    required this.photographer,
    required this.photoUrl,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'].toString(),
      photographer: json['photographer'],
      photoUrl: json['src']['large'],
      thumbnailUrl: json['src']['medium'],
    );
  }
}