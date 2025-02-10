import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../blocs/game/game_state.dart';
import '../config/config.dart';
import 'base_game_screen.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';

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
      currentScreen: state.currentScreen,
    );
  }
}

class _VideoScreenContent extends StatefulWidget {
  final Video video;
  final bool isFirstVideo;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final GameScreen currentScreen;

  const _VideoScreenContent({
    Key? key,
    required this.video,
    required this.isFirstVideo,
    required this.onNext,
    required this.onBack,
    required this.currentScreen,
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
    await _controller.pause();
    await _controller.seekTo(Duration.zero);
    if (isForward) {
      widget.onNext();
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.colors.backgroundDark,
      body: Column(
        children: [
          ProgressBar(currentScreen: widget.currentScreen),
          Expanded(
            child: Stack(
              children: [
                // Main content centered
                Center(
                  child: Column(
                    children: [
                      Expanded(child: _buildVideoPlayer()),
                      if (_isInitialized) ...[
                        const SizedBox(height: 8),
                        _buildProgressBar(),
                        const SizedBox(height: 8),
                        _buildControlButtons(),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),

                // Navigation buttons
                if (_isInitialized)
                  NavigationButtons.forGameScreen(
                    onNext: () => _handleNavigation(true),
                    onBack: () => _handleNavigation(false),
                    currentScreen: widget.currentScreen,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.7; // 70% der Bildschirmbreite
        final height = width / AppConfig.video.minAspectRatio;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized) ...[
                VideoPlayer(_controller),
                _buildTapToPlayOverlay(),
              ] else
                Container(
                  color: AppConfig.colors.backgroundDark,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppConfig.colors.textPrimary,
                    ),
                  ),
                ),
              if (_isBuffering && _isInitialized)
                CircularProgressIndicator(
                  color: AppConfig.colors.textPrimary,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.7, // Reduziert auf 70% der Bildschirmbreite
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: AppConfig.layout.progressBarHeight,
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: AppConfig.layout.progressBarHeight * 1.5),
              overlayShape: RoundSliderOverlayShape(
                  overlayRadius: AppConfig.layout.progressBarHeight * 3),
              activeTrackColor: AppConfig.colors.videoProgress,
              inactiveTrackColor: AppConfig.colors.backgroundLight,
              thumbColor: AppConfig.colors.videoProgress,
              overlayColor: AppConfig.colors.primary.withOpacity(0.3),
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
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.layout.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: AppConfig.textStyles.bodySmall,
                ),
                Text(
                  _formatDuration(_duration),
                  style: AppConfig.textStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
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
            duration: AppConfig.animation.normal,
            child: Icon(
              _controller.value.isPlaying
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              size: AppConfig.layout.videoControlSize * 1.5,
              color: AppConfig.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppConfig.colors.textPrimary,
            size: AppConfig.layout.videoControlSize,
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
        SizedBox(width: AppConfig.layout.spacingMedium),
        IconButton(
          icon: Icon(
            Icons.replay,
            color: AppConfig.colors.textPrimary,
            size: AppConfig.layout.videoControlSize,
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
