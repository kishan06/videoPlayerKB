import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:video_player/video_player.dart';
import 'package:videoplayerkb/Model/short_clip_likes_model.dart';
import 'package:videoplayerkb/Model/short_clip_model.dart';

import 'PreController.dart';
import 'Utils/Constants.dart';

class VideoPlayerKB extends StatefulWidget {
  VideoPlayerKB({
    Key? key,
    required this.fetchedClips,
    required this.fetchedLikes,
  }) : super(key: key);

  final List<ShortClipModel> fetchedClips;
  final List<ShortClipLikesModel> fetchedLikes;
  List<VideoPlayerController> videoControllers = [];
  @override
  State<VideoPlayerKB> createState() => _VideoPlayerKBState();
}

class _VideoPlayerKBState extends State<VideoPlayerKB> {
  bool showFullDesc = false;
  bool showLikeBtnLoader = false;
  bool showShareBtnLoader = false;
  BranchContentMetaData metadata = BranchContentMetaData();
  BranchUniversalObject? buo;
  BranchLinkProperties lp = BranchLinkProperties();

  static const imageURL =
      'https://raw.githubusercontent.com/RodrigoSMarques/flutter_branch_sdk/master/assets/branch_logo_qrcode.jpeg';
  final PreloadController preloadcontroller = Get.put(PreloadController());
  @override
  void initState() {
    super.initState();
    widget.videoControllers.clear();
  }

  // @override
  // void dispose() {
  //   for (var c in widget.videoControllers) {
  //     c.dispose();
  //   }
  //   super.dispose();
  // }

  void initDeepLinkData(int index) {
    metadata = BranchContentMetaData()
      ..addCustomMetadata('custom_number', index.toString());

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: 'GSF',
        imageUrl: imageURL,
        contentDescription: 'View on GSF now',
        contentMetadata: metadata,
        keywords: ['Plugin', 'Branch', 'Flutter'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: ['one', 'two', 'three'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$android_redirect_timeout', 750)
      ..addControlParam('referring_user_id', 'user_id');
  }

  Future<String> generateLink(BuildContext context) async {
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);
    if (response.success) {
      if (context.mounted) {
        //showGeneratedLink(context, response.result);
        // shareLink();
        print("Link is ${response.result}");
      }
      return response.result.toString();
    } else {
      Flushbar(
        // title: 'Hey Ninja',
        message: 'Error : ${response.errorCode} - ${response.errorMessage}',
        duration: const Duration(seconds: 2),
      ).show(context);
      return "Error";
    }
  }

  bool _isonce = true;
  callSetstateOnce() {
    if (_isonce) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isonce = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Obx(() {
            if (preloadcontroller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.kPrimaryColor,
                ),
              );
            } else {
              return const SizedBox(); // Your UI using the controller's state
            }
          }),
          Obx(() => Theme(
                data: ThemeData(
                  iconTheme: const IconThemeData(color: Colors.white),
                  scaffoldBackgroundColor:
                      (Theme.of(context).brightness != Brightness.light)
                          ? ColorConstants.kBlack
                          : ColorConstants.kWhite,
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: PageView.builder(
                    itemCount: preloadcontroller.urls.length,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      preloadcontroller.onVideoIndexChanged(index);
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      ShortClipModel shortClipModel =
                          widget.fetchedClips[index];
                      ShortClipLikesModel scLikesModel =
                          widget.fetchedLikes[index];
                      callSetstateOnce();

                      widget.videoControllers
                          .add(preloadcontroller.controllers[index]!);

                      return preloadcontroller.focusedIndex.value == index
                          ? WillPopScope(
                              onWillPop: () async {
                                preloadcontroller.controllers[index]?.dispose();
                                return true;
                              },
                              child: Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      preloadcontroller.controllers[index]!
                                              .value.isPlaying
                                          ? preloadcontroller.controllers[index]
                                              ?.pause()
                                          : preloadcontroller.controllers[index]
                                              ?.play();
                                    },
                                    child: VideoPlayer(
                                        preloadcontroller.controllers[index]!),
                                  ),
                                  likeAndShare(
                                      shortClipModel, index, scLikesModel),
                                  titleAndDescription(shortClipModel)
                                ],
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget likeAndShare(
      ShortClipModel shortClipModel, index, ShortClipLikesModel scLikesModel) {
    return Positioned(
      top: 32,
      right: 6,
      child: Column(
        children: [
          //share
          StatefulBuilder(
            builder: (context, setShareBtnState) {
              return Column(
                children: [
                  if (!showShareBtnLoader)
                    FloatingActionButton.small(
                      heroTag: "btn1",
                      elevation: 0,
                      backgroundColor: const Color.fromARGB(100, 0, 0, 0),
                      onPressed: () {
                        //   podPlayerController.pause();
                        setShareBtnState(() => showShareBtnLoader = true);
                        initDeepLinkData(index);
                        generateLink(
                          context,
                          // shortClipModel
                          //     .videoUrl
                        ).then((value) => setShareBtnState(() {
                              showShareBtnLoader = false;
                              Share.shareWithResult(
                                value,
                                subject: shortClipModel.title,
                              ).then((value) {
                                //  podPlayerController.play()
                              });
                            }));
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(Icons.share_outlined),
                      ),
                    ),
                  if (showShareBtnLoader)
                    const FloatingActionButton.small(
                      heroTag: "btn2",
                      elevation: 0,
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                      onPressed: null,
                      child: Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.8,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),

          //like
          StatefulBuilder(builder: (context, setLikeBtnSet) {
            return Column(
              children: [
                if (!showLikeBtnLoader)
                  FloatingActionButton.small(
                    heroTag: "btn3",
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(100, 0, 0, 0),
                    onPressed: () {
                      //Like Button Action API call
                      // setLikeBtnSet(() {
                      //   showLikeBtnLoader = true;
                      // });
                      // ShortClipService()
                      //     .likeOrUnlikeClip(shortClipModel.id)
                      //     .then((isLiked) {
                      //   setLikeBtnSet(() {
                      //     shortClipLikesModel.isLiked = isLiked;
                      //     // print('isLikedOnly ${isLiked}');
                      //     isLiked
                      //         ? shortClipModel.likes++
                      //         : shortClipModel.likes--;
                      //     showLikeBtnLoader = false;
                      //   });
                      // });
                    },
                    child: Icon(scLikesModel.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined),
                  ),
                if (showLikeBtnLoader)
                  const FloatingActionButton.small(
                    heroTag: "btn4",
                    elevation: 0,
                    backgroundColor: Color.fromARGB(100, 0, 0, 0),
                    onPressed: null,
                    child: Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.8,
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(100, 0, 0, 0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(shortClipModel.likes.toString()),
                ),
              ],
            );
          })
        ],
      ),
    );
  }

  Widget titleAndDescription(ShortClipModel shortClipModel) {
    return Positioned(
      bottom: 38,
      child: Container(
        width: Get.size.width,
        color: const Color.fromARGB(100, 0, 0, 0),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shortClipModel.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            //description
            StatefulBuilder(
              builder: (context, setDescState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    child: Text(
                      shortClipModel.description,
                      maxLines: showFullDesc ? 30 : 2,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onTap: () {
                      setDescState(() {
                        showFullDesc = !showFullDesc;
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
