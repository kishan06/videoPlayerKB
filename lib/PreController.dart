import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'api_service.dart';

class PreloadController extends GetxController {
  var isLoading = false.obs;
  var urls = <String>[].obs;
  var focusedIndex = 0.obs;
  RxMap<int, VideoPlayerController?> controllers =
      RxMap<int, VideoPlayerController?>({});

  @override
  void onInit() {
    super.onInit();
    getVideosFromApi();
  }

  Future<void> getVideosFromApi() async {
    setLoading(true);
    final List<String> urlsfetched = await ApiService.getVideos();
    urls.addAll(urlsfetched);

    await _initializeControllerAtIndex(0);

    _playControllerAtIndex(0);

    await _initializeControllerAtIndex(1);

    setLoading(false);
  }

  void onVideoIndexChanged(int index) {
    if (index > focusedIndex.value) {
      _playNext(index);
    } else {
      _playPrevious(index);
    }

    focusedIndex.value = index;
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController _controller =
          VideoPlayerController.networkUrl(Uri.parse(urls[index]));

      controllers[index] = _controller;

      await _controller.initialize();
      update();
    }
  }

  void _playControllerAtIndex(int index) {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController _controller = controllers[index]!;

      _controller.setVolume(1);
      _controller.play();
      update();
    }
  }

  void _stopControllerAtIndex(int index) {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController _controller = controllers[index]!;
      _controller.pause();
      _controller.seekTo(const Duration());
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (urls.length > index && index >= 0) {
      final VideoPlayerController? _controller = controllers[index];
      _controller?.dispose();
      if (_controller != null) {
        controllers.remove(_controller);
      }
    }
  }

  void _playNext(int index) {
    _stopControllerAtIndex(index - 1);
    _disposeControllerAtIndex(index - 2);
    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    _stopControllerAtIndex(index + 1);
    _disposeControllerAtIndex(index + 2);
    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index - 1);
  }

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
