import 'package:flutter/material.dart';
import '../../models/deepfake_indicator_model.dart';
import '../../config/app_config.dart';

class DeepfakeIndicatorCard extends StatelessWidget {
  final int index;
  final DeepfakeIndicator indicator;

  const DeepfakeIndicatorCard({
    Key? key,
    required this.index,
    required this.indicator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.colors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConfig.layout.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator header with number and text - more compact
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConfig.layout.spacingMedium,
              vertical:
                  AppConfig.layout.spacingSmall, // Reduced vertical padding
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Changed to center for better alignment
              children: [
                // More compact reason number badge
                Container(
                  width: 24, // Reduced from 32
                  height: 24, // Reduced from 32
                  decoration: BoxDecoration(
                    color: AppConfig.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Reduced from 16
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConfig.layout.spacingSmall),
                // Indicator description with smaller text
                Expanded(
                  child: Text(
                    indicator.description,
                    style: AppConfig.textStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15, // Reduced font size
                    ),
                    maxLines: 2, // Limit to 2 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Screenshots section if available
          if (indicator.screenshotUrls.isNotEmpty)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppConfig.layout.spacingMedium,
                  right: AppConfig.layout.spacingMedium,
                  bottom: AppConfig.layout.spacingSmall, // Reduced
                ),
                child: _buildScreenshotSection(indicator),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenshotSection(DeepfakeIndicator indicator) {
    if (indicator.screenshotUrls.isEmpty) return const SizedBox.shrink();

    if (indicator.screenshotUrls.length == 1) {
      // Nur ein Bild - komplett anzeigen
      return _buildScreenshotWithCaption(
        indicator.screenshotUrls.first,
        indicator.screenshotCaptions?.firstOrNull,
      );
    } else {
      // Mehrere Bilder - im Raster anzeigen
      return LayoutBuilder(builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 300 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: indicator.screenshotUrls.length,
          itemBuilder: (context, index) {
            return _buildScreenshotWithCaption(
              indicator.screenshotUrls[index],
              indicator.screenshotCaptions != null &&
                      index < indicator.screenshotCaptions!.length
                  ? indicator.screenshotCaptions![index]
                  : null,
            );
          },
        );
      });
    }
  }

  Widget _buildScreenshotWithCaption(String url, String? caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Screenshot with error handling
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppConfig.layout.cardRadius / 2),
            child: Image.asset(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppConfig.colors.backgroundDark,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppConfig.colors.textSecondary,
                      size: 28, // Smaller icon
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Caption if provided - more compact
        if (caption != null) ...[
          SizedBox(height: 4), // Smaller spacing
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 2, // Reduced vertical padding
              horizontal: 6, // Reduced horizontal padding
            ),
            decoration: BoxDecoration(
              color: AppConfig.colors.backgroundDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              caption,
              style: TextStyle(
                fontSize: 12, // Smaller font size
                color: AppConfig.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Limit to 1 line
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
