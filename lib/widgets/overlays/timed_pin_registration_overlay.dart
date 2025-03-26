import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../blocs/game/game_language_extension.dart';
import '../../config/app_config.dart';
import '../../config/localization/string_types.dart';

/// Ein Overlay für die PIN-Registrierung mit integriertem Timer
/// Der Timer schließt das Overlay automatisch nach einer bestimmten Zeit
class TimedPinRegistrationOverlay extends StatefulWidget {
  final String pin;
  final VoidCallback onClose;
  final bool showTimer;

  const TimedPinRegistrationOverlay({
    Key? key,
    required this.pin,
    required this.onClose,
    this.showTimer = true,
  }) : super(key: key);

  @override
  State<TimedPinRegistrationOverlay> createState() =>
      _TimedPinRegistrationOverlayState();
}

class _TimedPinRegistrationOverlayState
    extends State<TimedPinRegistrationOverlay> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    // Setze die verbleibende Zeit direkt aus der AppConfig
    _remainingSeconds = AppConfig.timing.pinDisplayTimeout.inSeconds;
    print('Timer initialized with ${_remainingSeconds} seconds'); // Debug-Log
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isUserInteracting) {
        // Wenn der Nutzer interagiert, Timer zurücksetzen
        setState(() {
          _remainingSeconds = AppConfig.timing.pinDisplayTimeout.inSeconds;
          _isUserInteracting = false;
        });
      } else {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            widget.onClose();
          }
        });
      }
    });
  }

  void _onUserInteraction() {
    // Nutzerinteraktion registrieren - Timer wird im nächsten Tick zurückgesetzt
    _isUserInteracting = true;
  }

  @override
  Widget build(BuildContext context) {
    // Hole lokalisierte Strings für das aktuelle Gebietsschema
    final strings = AppConfig.getStrings(context.currentLocale).auth;

    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      onPointerUp: (_) => _onUserInteraction(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppConfig.colors.overlayBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(strings),
              SizedBox(height: AppConfig.layout.spacingXLarge),
              Text(
                strings.pinSavePrompt,
                style: AppConfig.textStyles.overlaySubtitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppConfig.layout.spacingLarge),
              _buildPinDisplay(),
              SizedBox(height: AppConfig.layout.spacingLarge),
              _buildCopyButton(context, strings),
              SizedBox(height: AppConfig.layout.spacingXLarge),
              _buildStartGameButton(context, strings),

              // Timer-Anzeige, wenn aktiviert
              if (widget.showTimer) ...[
                SizedBox(height: AppConfig.layout.spacingMedium),
                Text(
                  strings.autoCloseText
                      .replaceAll('{seconds}', _remainingSeconds.toString()),
                  style: AppConfig.textStyles.bodySmall.copyWith(
                    color: AppConfig.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strings.pinTitle,
          style: AppConfig.textStyles.overlayTitle,
        ),
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.pin
          .split('')
          .map((digit) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.layout.pinDigitSpacing / 2,
                ),
                width: AppConfig.layout.pinDigitSize,
                height: AppConfig.layout.pinDigitSize * 1.2,
                decoration: BoxDecoration(
                  color: AppConfig.colors.backgroundLight,
                  borderRadius:
                      BorderRadius.circular(AppConfig.layout.pinDigitRadius),
                  border: Border.all(
                    color: AppConfig.colors.primary.withOpacity(0.3),
                    width: AppConfig.layout.pinDigitBorderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: AppConfig.textStyles.pinDigit,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCopyButton(BuildContext context, AuthStrings strings) {
    return ElevatedButton.icon(
      onPressed: () => _copyPinToClipboard(context, strings),
      icon: Icon(
        Icons.copy,
        color: AppConfig.colors.textPrimary,
      ),
      label: Text(
        strings.copyPin,
        style: AppConfig.textStyles.buttonMedium,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConfig.colors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppConfig.layout.spacingLarge,
          vertical: AppConfig.layout.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
        ),
      ),
    );
  }

  Widget _buildStartGameButton(BuildContext context, AuthStrings strings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.colors.secondary,
          padding: EdgeInsets.symmetric(
            vertical: AppConfig.layout.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
          ),
        ),
        child: Text(
          strings.startNextGame,
          style: AppConfig.textStyles.buttonLarge,
        ),
      ),
    );
  }

  void _copyPinToClipboard(BuildContext context, AuthStrings strings) {
    // PIN in die Zwischenablage kopieren
    Clipboard.setData(ClipboardData(text: widget.pin));

    // Zeige eine Bestätigung an
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.pinCopied),
        duration: AppConfig.timing.tooltipDuration,
        backgroundColor: AppConfig.colors.success,
      ),
    );

    // Setze den Timer zurück bei Interaktion
    _onUserInteraction();
  }
}
