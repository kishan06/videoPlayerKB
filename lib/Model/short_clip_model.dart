class ShortClipModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  int likes;

  ShortClipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.likes,
  });

  factory ShortClipModel.fromJson(Map<String, dynamic> json) => ShortClipModel(
        id: json['id'] as int,
        title: json['video_title'] as String,
        description: json['video_description'] as String,
        videoUrl: json['video_url'] as String,
        thumbnailUrl: json['thumbnail'] as String,
        likes: json['likes'],
      );
}
