import 'package:flutter/material.dart';
import '../../config/config.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;

  const NumberPad({
    Key? key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppConfig.layout.numberPadMargin),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          SizedBox(height: AppConfig.layout.numberPadSpacing),
          _buildNumberRow(['4', '5', '6']),
          SizedBox(height: AppConfig.layout.numberPadSpacing),
          _buildNumberRow(['7', '8', '9']),
          SizedBox(height: AppConfig.layout.numberPadSpacing),
          _buildLastRow(),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConfig.layout.numberPadSpacing / 2,
          ),
          child: _buildButton(
            child: Text(number, style: AppConfig.textStyles.numberPadButton),
            onPressed: () => onNumberPressed(number),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: AppConfig.layout.numberPadButtonSize +
                AppConfig.layout.numberPadSpacing),
        _buildButton(
          child: Text('0', style: AppConfig.textStyles.numberPadButton),
          onPressed: () => onNumberPressed('0'),
        ),
        SizedBox(width: AppConfig.layout.numberPadSpacing),
        _buildButton(
          child: Icon(
            Icons.backspace_outlined,
            size: AppConfig.layout.numberPadIconSize,
            color: AppConfig.colors.textPrimary,
          ),
          onPressed: onBackspacePressed,
        ),
      ],
    );
  }

  Widget _buildButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: AppConfig.layout.numberPadButtonSize,
      height: AppConfig.layout.numberPadButtonSize,
      child: Material(
        color: AppConfig.colors.numberPadButton,
        borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConfig.layout.buttonRadius),
          highlightColor: AppConfig.colors.numberPadButtonPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}
