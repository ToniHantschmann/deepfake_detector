import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class VideoScreen extends StatefulWidget {
  final Video video;
  final VoidCallback onNext;
  final bool isFirstVideo;

  const VideoScreen({
    Key? key,
    required this.video,
    required this.onNext,
    required this.isFirstVideo,
  }) : super(key: key);

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.video.videoUrl);

    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Info Card
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    'Video ${widget.video.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Video Player und Fortschrittsanzeige
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _isInitialized
                        ? VideoPlayer(_controller)
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  if (_isInitialized)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.only(top: 8),
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: Colors.blue,
                          bufferedColor:
                              const Color.fromRGBO(33, 150, 243, 0.2),
                          backgroundColor: Colors.grey[800]!,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Video Controls
            if (_isInitialized)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.replay,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        _controller.seekTo(Duration.zero);
                        _controller.play();
                      },
                    ),
                  ],
                ),
              ),

            // Next Button
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height / 2 - 28,
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 56,
                ),
                onPressed: widget.onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
