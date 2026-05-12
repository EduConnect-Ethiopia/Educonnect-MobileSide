import 'package:flutter/material.dart';

class EduConnectLoadingIndicator extends StatelessWidget {
  const EduConnectLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 28,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}
