import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo_leveling/config/constatnts.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconOnRight;
  final bool isLoading;
  final Size size;
  final bool enableSound;

  // Button sizes
  static const Size smallSize = Size(120, 36);
  static const Size mediumSize = Size(160, 44);
  static const Size largeSize = Size(200, 52);

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.iconOnRight = false,
    this.isLoading = false,
    this.size = mediumSize,
    this.enableSound = true,
  });

  @override
  Widget build(BuildContext context) {
    // Disable button when loading or onPressed is null
    final bool isDisabled = isLoading || onPressed == null;

    // Define text style based on button size
    final TextStyle textStyle = size == smallSize
        ? AppConstants.buttonTextSmall
        : size == mediumSize
            ? AppConstants.buttonTextMedium
            : AppConstants.buttonTextLarge;

    // Icon size based on button size
    final double iconSize = size == smallSize
        ? 16
        : size == mediumSize
            ? 20
            : 24;

    // Spacing between icon and text
    final double spacing = size == smallSize ? 6 : 8;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                // Optional haptic feedback
                HapticFeedback.lightImpact();

                // Call the provided callback
                onPressed?.call();
              },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? AppConstants.disabledBorderColor
                  : AppConstants.primaryColor,
              width: 2,
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null && !iconOnRight) ...[
                        Icon(
                          icon,
                          size: iconSize,
                          color: isDisabled
                              ? AppConstants.disabledTextColor
                              : AppConstants.primaryColor,
                        ),
                        SizedBox(width: spacing),
                      ],
                      Text(
                        text,
                        style: textStyle.copyWith(
                          color: isDisabled
                              ? AppConstants.disabledTextColor
                              : AppConstants.primaryColor,
                        ),
                      ),
                      if (icon != null && iconOnRight) ...[
                        SizedBox(width: spacing),
                        Icon(
                          icon,
                          size: iconSize,
                          color: isDisabled
                              ? AppConstants.disabledTextColor
                              : AppConstants.primaryColor,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
