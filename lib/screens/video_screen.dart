import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../blocs/game/game_event.dart';
import '../blocs/game/game_state.dart';
import 'base_game_screen.dart';

class VideoScreen extends BaseGameScreen {
  final Video video;
  final bool isFirstVideo;

  const VideoScreen({
    Key? key,
    required this.video,
    required this.isFirstVideo,
  }) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    return _VideoScreenContent(
      video: video,
      isFirstVideo: isFirstVideo,
      onNext: () => dispatchGameEvent(context, const NextScreen()),
    );
  }
}

class _VideoScreenContent extends StatefulWidget {
  final Video video;
  final bool isFirstVideo;
  final VoidCallback onNext;

  const _VideoScreenContent({
    Key? key,
    required this.video,
    required this.isFirstVideo,
    required this.onNext,
  }) : super(key: key);

  @override
  _VideoScreenContentState createState() => _VideoScreenContentState();
}

class _VideoScreenContentState extends State<_VideoScreenContent> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.video.videoUrl);

      await _controller.initialize();

      _controller.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
        _duration = _controller.value.duration;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _position = _controller.value.position;
      _isBuffering = _controller.value.isBuffering;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isFirstVideo ? 'First Video' : 'Second Video',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Video Player and Controls
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isInitialized)
                          VideoPlayer(_controller)
                        else
                          Container(
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (_isBuffering && _isInitialized)
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                  if (_isInitialized) ...[
                    const SizedBox(height: 8),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    _buildControlButtons(),
                  ],
                ],
              ),
            ),

            // Navigation Buttons
            if (_isInitialized) ...[
              // Back Button (except for first video)
              if (!widget.isFirstVideo)
                Positioned(
                  left: 16,
                  top: MediaQuery.of(context).size.height / 2 - 28,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 56,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.3),
            ),
            child: Slider(
              value: _position.inMilliseconds.toDouble(),
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _position = Duration(milliseconds: value.toInt());
                });
                _controller.seekTo(_position);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
    );
  }
}
