import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:flutter/material.dart';
import '../../config/localization/app_locale.dart';
import '../../models/video_model.dart';
import '../../config/app_config.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;

// Vereinfachte Komponente ohne eigene Overlay-Logik
class VideoPlayerContent extends StatefulWidget {
  final Video video;
  final VoidCallback onClose;
  final AppLocale locale;

  const VideoPlayerContent({
    Key? key,
    required this.video,
    required this.onClose,
    required this.locale,
  }) : super(key: key);

  @override
  _VideoPlayerContentState createState() => _VideoPlayerContentState();
}

class _VideoPlayerContentState extends State<VideoPlayerContent> {
  late final Player _player;
  late final media_kit.VideoController _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = media_kit.VideoController(_player);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = widget.video.videoUrl;
      await _player.open(Media('asset:///$videoUrl'));

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
      //await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _duration = _player.state.duration;
        });

        // Auto-play the video
        _player.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppConfig.getStrings(widget.locale).videoPlayer;
    final screenSize = MediaQuery.of(context).size;

    // Berechnung der Größe für ein kompaktes Overlay
    final videoWidth = screenSize.width * 0.5;
    final videoHeight = videoWidth / AppConfig.video.minAspectRatio;

    // Höhen für die verschiedenen Abschnitte
    final headerHeight = 48.0;
    final controlsHeight = 80.0;
    final totalHeight = videoHeight + headerHeight + controlsHeight;

    return Container(
      width: videoWidth,
      height: totalHeight,
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundDark,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video header
          SizedBox(
            height: headerHeight,
            child: _buildVideoHeader(strings),
          ),

          // Video player
          Container(
            height: videoHeight,
            color: AppConfig.colors.backgroundDark,
            child: _isInitialized
                ? _buildVideoPlayer()
                : Center(
                    child: CircularProgressIndicator(
                      color: AppConfig.colors.primary,
                    ),
                  ),
          ),

          // Controls
          SizedBox(
            height: controlsHeight,
            child: _isInitialized ? _buildControls() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHeader(VideoPlayerStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: widget.video.isDeepfake
            ? AppConfig.colors.warning.withOpacity(0.2)
            : AppConfig.colors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConfig.layout.cardRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Anzeige ob Deepfake oder echt
          Expanded(
            child: Row(
              children: [
                Icon(
                  widget.video.isDeepfake ? Icons.warning : Icons.check_circle,
                  color: widget.video.isDeepfake
                      ? AppConfig.colors.warning
                      : AppConfig.colors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.video.isDeepfake
                        ? strings.deepfakeLabel
                        : strings.realLabel,
                    style: AppConfig.textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.video.isDeepfake
                          ? AppConfig.colors.warning
                          : AppConfig.colors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Actual video player
        media_kit.Video(controller: _controller),

        // Buffering indicator
        if (_isBuffering)
          CircularProgressIndicator(
            color: AppConfig.colors.primary,
          ),

        // Tap to play/pause
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                if (_player.state.playing) {
                  _player.pause();
                } else {
                  _player.play();
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: AnimatedOpacity(
                opacity: _player.state.playing ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConfig.colors.backgroundDark.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _player.state.playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight.withOpacity(0.3),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppConfig.layout.cardRadius),
        ),
        border: Border(
          top: BorderSide(
            color: AppConfig.colors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SizedBox(
            height: 24,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: AppConfig.layout.progressBarHeight,
                thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius:
                        AppConfig.layout.progressBarHeight * 1.5),
                activeTrackColor: AppConfig.colors.videoProgress,
                inactiveTrackColor: AppConfig.colors.backgroundLight,
                thumbColor: AppConfig.colors.videoProgress,
              ),
              child: Slider(
                value: _position.inMilliseconds.toDouble(),
                min: 0,
                max: _duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _player.seek(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),

          // Zeitanzeige und Bedienelemente
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Zeitanzeige
                  Text(
                    '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                    style: AppConfig.textStyles.bodySmall,
                  ),

                  // Play/Pause und Restart-Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _player.state.playing
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: AppConfig.colors.textPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_player.state.playing) {
                              _player.pause();
                            } else {
                              _player.play();
                            }
                          });
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        iconSize: 28,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.replay,
                          color: AppConfig.colors.textPrimary,
                        ),
                        onPressed: () {
                          _player.seek(Duration.zero);
                          _player.play();
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
