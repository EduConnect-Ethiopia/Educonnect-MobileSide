import 'package:flutter/material.dart';

import '../../core/widgets/educonnect_loading_indicator.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const EduConnectLoadingIndicator()
        : Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    if (icon == null || isLoading) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: buttonChild,
    );
  }
}
