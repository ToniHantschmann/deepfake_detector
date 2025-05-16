import 'package:deepfake_detector/blocs/game/game_language_extension.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../config/localization/string_types.dart';
import '../models/video_model.dart';
import '../blocs/game/game_state.dart';
import 'base_game_screen.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../widgets/common/progress_bar.dart';
import '../config/app_config.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;

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
        previous.status != current.status ||
        previous.locale != current.locale;
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
  late final Player _player;
  late final media_kit.VideoController _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = media_kit.VideoController(_player);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Asset-Pfad für media_kit
      final videoUrl = widget.video.videoUrl;
      await _player.open(Media('asset:///$videoUrl'));

      // Player-Events abonnieren
      _player.stream.position.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _player.stream.duration.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _player.stream.buffering.listen((buffering) {
        if (mounted) {
          setState(() {
            _isBuffering = buffering;
          });
        }
      });

      // Warten auf Initialisierung
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _duration = _player.state.duration;
        });
        _startAutoPlayTimer();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _startAutoPlayTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted && _isInitialized) {
        _player.play();
      }
    });
  }

  @override
  void didUpdateWidget(_VideoScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.videoUrl != widget.video.videoUrl) {
      // Video wechseln
      _player.dispose();
      _player = Player();
      _controller = media_kit.VideoController(_player);
      _initializeVideo();
    } else if (_isInitialized) {
      _startAutoPlayTimer();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _handleNavigation(bool isForward) async {
    _autoPlayTimer?.cancel();
    await _player.pause();
    await _player.seek(Duration.zero);
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
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      _buildMainContent(constraints),
                      if (_isInitialized)
                        NavigationButtons.forGameScreen(
                          onNext: () => _handleNavigation(true),
                          onBack: () => _handleNavigation(false),
                          currentScreen: widget.currentScreen,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVideoPlayer(constraints),
            if (_isInitialized) ...[
              SizedBox(height: AppConfig.layout.spacingSmall),
              _buildProgressBar(),
              SizedBox(height: AppConfig.layout.spacingMedium),
              _buildControlButtons(),
              SizedBox(height: AppConfig.layout.spacingMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constraints.maxHeight - AppConfig.layout.spacingXLarge * 6,
      ),
      child: AspectRatio(
        aspectRatio: AppConfig.video.minAspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isInitialized) ...[
              media_kit.Video(controller: _controller),
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
                _player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppConfig.layout.spacingXLarge),
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
            if (_player.state.playing) {
              _player.pause();
            } else {
              _player.play();
            }
            // Erzwinge UI-Update
            setState(() {});
          },
          child: AnimatedOpacity(
            opacity: _player.state.playing ? 0.0 : 1.0,
            duration: AppConfig.animation.normal,
            child: Icon(
              _player.state.playing
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
      children: [
        IconButton(
          icon: Icon(
            _player.state.playing ? Icons.pause : Icons.play_arrow,
            color: AppConfig.colors.textPrimary,
            size: AppConfig.layout.videoControlSize,
          ),
          onPressed: () {
            if (_player.state.playing) {
              _player.pause();
            } else {
              _player.play();
            }
            // Erzwinge UI-Update
            setState(() {});
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
            _player.seek(Duration.zero);
            _player.play();
          },
        ),
      ],
    );
  }
}
