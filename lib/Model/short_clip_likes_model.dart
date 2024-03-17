class ShortClipLikesModel {
  // final int id;
  // final int userId;
  final int shortClipId;
  bool isLiked;

  ShortClipLikesModel({
    // required this.id,
    // required this.userId,
    required this.shortClipId,
    required this.isLiked,
  });

  factory ShortClipLikesModel.fromJson(Map<String, dynamic> json) {
    return ShortClipLikesModel(
      // id: json['id'],
      // userId: json['user_id'],
      shortClipId: json['short_clips_id'],
      isLiked: json['is_like'].toString() == "0" ? true : false,
    );
  }
}
