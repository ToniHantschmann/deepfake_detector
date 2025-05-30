import 'package:deepfake_detector/config/localization/string_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../blocs/game/game_language_extension.dart';
import '../blocs/game/game_bloc.dart';
import '../config/app_config.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/progress_bar.dart';
import '../widgets/common/navigaton_buttons.dart';
import '../utils/session_id_generator.dart';
import 'base_game_screen.dart';

class QrCodeScreen extends BaseGameScreen {
  const QrCodeScreen({Key? key}) : super(key: key);

  @override
  bool shouldRebuild(GameState previous, GameState current) {
    return previous.currentScreen != current.currentScreen ||
        previous.status != current.status ||
        previous.locale != current.locale;
  }

  @override
  Widget buildGameScreen(BuildContext context, GameState state) {
    final strings = AppConfig.getStrings(context.currentLocale).qrCode;

    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: Column(
        children: [
          ProgressBar(currentScreen: state.currentScreen),
          Expanded(
            child: Stack(
              children: [
                FutureBuilder<String?>(
                  future: _getSessionIdForCurrentPlayer(context, state),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingScreen(strings);
                    }

                    final sessionId = snapshot.data;
                    final studyUrl = sessionId != null
                        ? SessionIdGenerator.generateSoSciSurveyUrl(sessionId)
                        : 'https://survey.ifkw.lmu.de/deepfakeDetectionGame/'; // Fallback

                    return _buildQrCodeScreen(
                        context, strings, studyUrl, sessionId);
                  },
                ),
                // Navigation Buttons
                NavigationButtons.forGameScreen(
                  onNext: () => handleNextNavigation(context),
                  onBack: () => handleBackNavigation(context),
                  currentScreen: state.currentScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getSessionIdForCurrentPlayer(
      BuildContext context, GameState state) async {
    if (state.playerId == null) return null;

    try {
      final repository = context.read<GameBloc>().internalStatsRepository;
      final stats = await repository.getStatistics();
      final player = stats.players.firstWhere(
        (p) => p.id == state.playerId,
        orElse: () => throw Exception('Player not found'),
      );
      return player.sessionId;
    } catch (e) {
      debugPrint('Error loading session ID: $e');
      return null;
    }
  }

  Widget _buildLoadingScreen(QrCodeScreenStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppConfig.colors.primary,
          ),
          SizedBox(height: AppConfig.layout.spacingLarge),
          Text(
            strings.loadingSessionId,
            style: AppConfig.textStyles.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeScreen(BuildContext context, QrCodeScreenStrings strings,
      String studyUrl, String? sessionId) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConfig.layout.screenPaddingHorizontal,
          vertical: AppConfig.layout.screenPaddingVertical,
        ),
        child: Column(
          children: [
            SizedBox(height: AppConfig.layout.spacingLarge),

            // Header
            Text(
              strings.title,
              style: AppConfig.textStyles.h2,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppConfig.layout.spacingLarge),

            // Beschreibung
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConfig.layout.spacingMedium,
              ),
              child: Text(
                strings.description,
                style: AppConfig.textStyles.bodyLarge.copyWith(
                  color: AppConfig.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: AppConfig.layout.spacingXLarge * 2),

            // QR-Code
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppConfig.layout.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: EdgeInsets.all(AppConfig.layout.spacingXLarge),
              child: QrImageView(
                data: studyUrl,
                version: QrVersions.auto,
                size: 300,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            SizedBox(height: AppConfig.layout.spacingXLarge * 3),

            SizedBox(height: AppConfig.layout.spacingXLarge),

// Zwei Buttons nebeneinander
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // End Game Button (links, weniger prominent)
                SizedBox(
                  width: 280,
                  height: 80,
                  child: ElevatedButton.icon(
                    onPressed: () => handleEndGame(context),
                    icon: const Icon(Icons.home, color: Colors.white, size: 28),
                    label: Text(
                      strings.endGameButton,
                      style: AppConfig.textStyles.buttonLarge
                          .copyWith(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.colors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: AppConfig.layout.spacingXLarge),

                // Continue Game Button (rechts, prominent)
                SizedBox(
                  width: 400,
                  height: 80,
                  child: ElevatedButton.icon(
                    onPressed: () => handleNextNavigation(context),
                    icon: const Icon(Icons.play_arrow,
                        color: Colors.white, size: 32),
                    label: Text(
                      strings.continueToNextGame,
                      style: AppConfig.textStyles.buttonLarge,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
