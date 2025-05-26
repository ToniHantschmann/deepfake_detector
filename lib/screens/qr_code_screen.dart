import 'package:flutter/material.dart';
import '../blocs/game/game_language_extension.dart';
import '../config/app_config.dart';
import '../blocs/game/game_state.dart';
import '../widgets/common/progress_bar.dart';
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
    return Scaffold(
      backgroundColor: AppConfig.colors.background,
      body: Column(
        children: [
          ProgressBar(currentScreen: GameScreen.qrCode),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Padding(
                      padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
                      child: Text(
                        'Scannen Sie diesen QR-Code für unsere Studie',
                        style: AppConfig.textStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConfig.layout.screenPaddingHorizontal,
                        vertical: AppConfig.layout.spacingMedium,
                      ),
                      child: Text(
                        'Bitte nehmen Sie an unserer kurzen Umfrage teil, um uns Feedback zur Deepfake-Erkennung zu geben.',
                        style: AppConfig.textStyles.bodyMedium.copyWith(
                          color: AppConfig.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: AppConfig.layout.spacingXLarge),

                    // QR Code with border
                    Container(
                      decoration: BoxDecoration(
                        color: Colors
                            .white, // White background for QR code visibility
                        borderRadius:
                            BorderRadius.circular(AppConfig.layout.cardRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(AppConfig.layout.spacingLarge),
                      child: Image.asset(
                        'assets/images/qr-code.png', // Path to your QR code image
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: AppConfig.layout.spacingXLarge),

                    // Back button
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        'Zurück',
                        style: AppConfig.textStyles.buttonMedium,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.colors.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConfig.layout.buttonPadding * 2,
                          vertical: AppConfig.layout.buttonPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.layout.buttonRadius),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
