import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';

class AuthenticatedImage extends ConsumerWidget {
  const AuthenticatedImage({
    required this.imageUrl,
    this.fit,
    this.width,
    this.height,
    super.key,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(tokenStorageProvider).accessToken;
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: headers,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        color: Colors.grey[300],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Failed to load image', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
