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
      onNext: () => handleNextNavigation(context),
      onBack: () => handleBackNavigation(context),
    );
  }
}

class _VideoScreenContent extends StatefulWidget {
  final Video video;
  final bool isFirstVideo;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _VideoScreenContent({
    Key? key,
    required this.video,
    required this.isFirstVideo,
    required this.onNext,
    required this.onBack,
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
      await _controller.seekTo(Duration.zero);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _duration = _controller.value.duration;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      // We don't need to handle the error here as BaseGameScreen will handle it
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

  Future<void> _handleNavigation(bool isForward) async {
    // Pausiere das Video
    await _controller.pause();
    // Setze es auf den Anfang zurück
    await _controller.seekTo(Duration.zero);
    // Führe die Navigation aus
    if (isForward) {
      widget.onNext();
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Video Title Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildTitleCard(),
                ),

                // Main Video Content
                _buildMainContent(constraints),

                // Navigation Arrows
                if (_isInitialized) ...[
                  _buildBackButton(constraints),
                  _buildNextButton(constraints),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xCC212121), // grey[900] with 80% opacity
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.video.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVideoPlayer(constraints),
            if (_isInitialized) ...[
              const SizedBox(height: 8),
              _buildProgressBar(),
              const SizedBox(height: 16),
              _buildControlButtons(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constraints.maxHeight - 200,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isInitialized) ...[
              VideoPlayer(_controller),
              _buildTapToPlayOverlay(),
            ] else
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
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.blue,
              overlayColor: const Color(0x4D2196F3),
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

  Widget _buildTapToPlayOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: AnimatedOpacity(
            opacity: _controller.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _controller.value.isPlaying
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
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

  Widget _buildBackButton(BoxConstraints constraints) {
    return Positioned(
      left: 16,
      top: constraints.maxHeight / 2 - 28,
      child: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 56,
        ),
        onPressed: () => _handleNavigation(false),
      ),
    );
  }

  Widget _buildNextButton(BoxConstraints constraints) {
    return Positioned(
      right: 16,
      top: constraints.maxHeight / 2 - 28,
      child: IconButton(
        icon: const Icon(
          Icons.chevron_right,
          color: Colors.white,
          size: 56,
        ),
        onPressed: () => _handleNavigation(true),
      ),
    );
  }
}
