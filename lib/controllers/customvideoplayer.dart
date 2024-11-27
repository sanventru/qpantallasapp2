import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerController extends GetxController {
  VideoPlayerController? videoController;
  var isPlaying = false.obs;
  var isInitialized = false.obs;
  var position = Duration.zero.obs;
  var duration = Duration.zero.obs;

  void initializeVideo(String videoPath) async {
    if (videoController != null) {
      await videoController!.dispose();
    }
    
    videoController = VideoPlayerController.file(File(videoPath))
      ..addListener(() {
        position.value = videoController!.value.position;
        
        // Check if video ended and restart if needed
        if (videoController!.value.position >= videoController!.value.duration) {
          videoController!.seekTo(Duration.zero);
          videoController!.play();
        }
      })
      ..initialize().then((_) {
        duration.value = videoController!.value.duration;
        isInitialized.value = true;
        play(); // Auto-play when initialized
      });
  }

  void play() {
    if (videoController?.value.isInitialized ?? false) {
      videoController!.play();
      isPlaying.value = true;
    }
  }

  void pause() {
    if (videoController?.value.isInitialized ?? false) {
      videoController!.pause();
      isPlaying.value = false;
    }
  }

  void togglePlay() {
    isPlaying.value ? pause() : play();
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }
}

class CustomVideoPlayer extends StatelessWidget {
  final String videoPath;
  final BoxFit fit;
  final bool showControls;

  CustomVideoPlayer({
    required this.videoPath,
    this.fit = BoxFit.cover,
    this.showControls = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomVideoPlayerController());
    
    // Initialize video when widget is built
    controller.initializeVideo(videoPath);

    return Obx(() {
      if (!controller.isInitialized.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.videoController!.value.aspectRatio,
            child: VideoPlayer(controller.videoController!),
          ),
          if (showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        controller.isPlaying.value 
                            ? Icons.pause 
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: controller.togglePlay,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}