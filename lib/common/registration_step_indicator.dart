import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/core/theme/theme_cubit.dart';

enum RegistrationStep {
  register(0),
  verify(1),
  complete(2);

  const RegistrationStep(this.step);
  @override
  final int step;
}

class RegistrationStepIndicator extends StatelessWidget {

  const RegistrationStepIndicator({
    super.key,
  });

  @override
Widget build(BuildContext context) {
  final stepIndex = context.watch<RegistrationStepCubit>().state;

  final themeState = context.watch<ThemeCubit>().state;
  final colors = themeState.tokens.colors;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(
      color: colors.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        _buildStep(
          context,
          index: 0,
          title: _getStepTitle(context, 0),
          isActive: stepIndex >= 0,
          isCompleted: stepIndex > 0,
        ),
        _buildDivider(context, isActive: stepIndex >= 1),
        _buildStep(
          context,
          index: 1,
          title: _getStepTitle(context, 1),
          isActive: stepIndex >= 1,
          isCompleted: stepIndex > 1,
        ),
        _buildDivider(context, isActive: stepIndex >= 2),
        _buildStep(
          context,
          index: 2,
          title: _getStepTitle(context, 2),
          isActive: stepIndex >= 2,
          isCompleted: stepIndex > 2,
        ),
      ],
    ),
  );
}
  String _getStepTitle(BuildContext context, int step) {
    // You can add localization keys for these
    switch (step) {
      case 0:
        return 'Register';
      case 1:
        return 'Verify';
      case 2:
        return 'Complete';
      default:
        return '';
    }
  }

  Widget _buildStep(
    BuildContext context, {
    required int index,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final isDark = themeState.isDark;

    Color getStepColor() {
      if (isCompleted) return colors.primary;
      if (isActive) return colors.primary;
      return colors.border;
    }

    final stepColor = getStepColor();
    final textColor = isActive || isCompleted ? colors.primary : colors.body;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive 
                  ? stepColor 
                  : Colors.transparent,
              border: Border.all(
                color: stepColor,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : stepColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // Step title
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(
    BuildContext context, {
    required bool isActive,
  }) {
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 2,
        color: isActive ? colors.primary : colors.border,
      ),
    );
  }
}