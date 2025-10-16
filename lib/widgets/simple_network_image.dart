import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';

class SimpleNetworkImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SimpleNetworkImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;

    if (imagePath.startsWith('http')) return imagePath;

    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // Use ApiService.storageUrl untuk menggunakan konfigurasi yang sama
    if (cleanPath.startsWith('news_images/')) {
      return '${ApiService.storageUrl}/$cleanPath';
    }

    return '${ApiService.storageUrl}/news_images/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl(imagePath);
    
    if (imageUrl == null) {
      return errorWidget ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey,
              size: 32,
            ),
          ),
        );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          ),
        ),
      errorWidget: (context, url, error) => errorWidget ?? 
        Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: Colors.grey,
              size: 32,
            ),
          ),
        ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 600,
    );
  }
}