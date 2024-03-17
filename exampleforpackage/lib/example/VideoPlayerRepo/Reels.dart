import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:videoplayerkb/Model/short_clip_likes_model.dart';
import 'package:videoplayerkb/Model/short_clip_model.dart';
import 'package:videoplayerkb/VideoPageGetx.dart';
import 'package:videoplayerkb/api_service.dart';

class Reels extends StatefulWidget {
  const Reels({super.key});

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  List<ShortClipModel> fetchedClips = [
    ShortClipModel(
        id: 36,
        title: "Mindful Approach",
        description: "Mindful Approach for your health",
        videoUrl:
            "https://player.vimeo.com/progressive_redirect/playback/861153289/rendition/540p/file.mp4?loc=external&signature=375b7a2ebe8586f6630f63872bf8f2c95cc78a7cd48dd3f71cd2a3021bd724d3",
        thumbnailUrl:
            "https://thegsf.co/public/uploads/short_clips/1693980602.png?d=1710692729",
        likes: 6),
    ShortClipModel(
        id: 37,
        title: "Does green tea really cause weight loss?",
        description: "Does green tea really cause weight loss?",
        videoUrl:
            "https://player.vimeo.com/progressive_redirect/playback/861152968/rendition/720p/file.mp4?loc=external&signature=693dceacbc17c8893917d74c5288acd9083fdf3c062c8c322319b8c99a402585",
        thumbnailUrl:
            "https://thegsf.co/public/uploads/short_clips/1693980701.png?d=1710692729",
        likes: 5),
    ShortClipModel(
        id: 38,
        title: "No need to have fancy food for having a good health",
        description: "No need to have fancy food for having a good health",
        videoUrl:
            "https://player.vimeo.com/progressive_redirect/playback/861152607/rendition/720p/file.mp4?loc=external&signature=efd819cdf12671287b15e80134017c3ca2b158b46cb4aa0b51cf43bf2a1429c4",
        thumbnailUrl:
            "https://thegsf.co/public/uploads/short_clips/1693980902.png?d=1710692729",
        likes: 4),
  ];
  List<ShortClipLikesModel> fetchedLikes = [
    ShortClipLikesModel(shortClipId: 36, isLiked: true),
    ShortClipLikesModel(shortClipId: 37, isLiked: false),
    ShortClipLikesModel(shortClipId: 38, isLiked: true),
  ];

  @override
  Widget build(BuildContext context) {
    ApiService.videos = fetchedClips.map((e) => e.videoUrl).toList();
    return Scaffold(
        appBar: AppBar(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFCC9900),
          title: const Text('Reels'),
        ),
        body: VideoPlayerKB(
            fetchedClips: fetchedClips, fetchedLikes: fetchedLikes));
  }
}
