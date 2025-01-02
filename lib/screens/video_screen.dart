import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class VideoScreen extends StatefulWidget {
  final Video video;
  final VoidCallback onNext;
  final bool isFirstVideo;

  //final VoidCallback onNext;
  // TODO: get video from GameState

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
  VideoPlayerController? _mobileController;
  html.VideoElement? _webVideoElement;
  final String _webVideoPlayerId =
      'video-player-${DateTime.now().millisecondsSinceEpoch}';
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebVideo();
    } else {
      _initializeMobileVideo();
    }
  }

  void _initializeWebVideo() {
    // HTML Video Element erstellen
    _webVideoElement = html.VideoElement()
      ..id = _webVideoPlayerId
      ..src =
          'assets/${widget.video.videoUrl}' // Video muss in web/assets liegen
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain';

    // Controls hinzufügen
    _webVideoElement!
      ..controls = false
      ..onTimeUpdate.listen((_) {
        if (mounted) {
          setState(() {
            _progress =
                _webVideoElement!.currentTime / _webVideoElement!.duration;
          });
        }
      })
      ..onPlay.listen((_) {
        if (mounted) setState(() => _isPlaying = true);
      })
      ..onPause.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });

    // Video Element in den DOM einfügen
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _webVideoPlayerId,
      (int viewId) => _webVideoElement!,
    );
  }

  Future<void> _initializeMobileVideo() async {
    _mobileController = VideoPlayerController.asset(widget.video.videoUrl);

    await _mobileController!.initialize();
    _mobileController!.addListener(() {
      if (!mounted) return;
      setState(() {
        _isPlaying = _mobileController!.value.isPlaying;
        if (_mobileController!.value.duration.inMilliseconds > 0) {
          _progress = _mobileController!.value.position.inMilliseconds /
              _mobileController!.value.duration.inMilliseconds;
        }
      });
    });
    setState(() {});
  }

  void _togglePlayPause() {
    setState(() {
      if (kIsWeb) {
        if (_isPlaying) {
          _webVideoElement!.pause();
        } else {
          _webVideoElement!.play();
        }
      } else {
        if (_mobileController!.value.isPlaying) {
          _mobileController!.pause();
        } else {
          _mobileController!.play();
        }
      }
    });
  }

  void _replay() {
    if (kIsWeb) {
      _webVideoElement!.currentTime = 0;
      _webVideoElement!.play();
    } else {
      _mobileController!.seekTo(Duration.zero);
      _mobileController!.play();
    }
    setState(() => _isPlaying = true);
  }

  @override
  void dispose() {
    if (kIsWeb) {
      _webVideoElement?.remove();
    } else {
      _mobileController?.dispose();
    }
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

            // Video Player mit Fortschrittsanzeige
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: kIsWeb
                        ? HtmlElementView(viewType: _webVideoPlayerId)
                        : _mobileController?.value.isInitialized ?? false
                            ? VideoPlayer(_mobileController!)
                            : const Center(child: CircularProgressIndicator()),
                  ),
                  // Video Progress Bar
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey[800],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Controls
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.replay,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: _replay,
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
