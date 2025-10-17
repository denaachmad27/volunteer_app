import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';

class RobustNetworkImage extends StatefulWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const RobustNetworkImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<RobustNetworkImage> createState() => _RobustNetworkImageState();
}

class _RobustNetworkImageState extends State<RobustNetworkImage> {
  final int _currentUrlIndex = 0;
  bool _hasError = false;
  List<String> _urlsToTry = [];

  @override
  void initState() {
    super.initState();
    _generateUrlsToTry();
  }

  void _generateUrlsToTry() {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      _urlsToTry = [];
      return;
    }

    final path = widget.imagePath!;
    _urlsToTry = [];

    // If it's already a full URL, use it directly
    if (path.startsWith('http')) {
      _urlsToTry.add(path);
      return;
    }

    // Use ApiService.storageUrl untuk menggunakan konfigurasi yang sama
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    if (cleanPath.startsWith('news_images/')) {
      _urlsToTry.add('${ApiService.storageUrl}/$cleanPath');
    } else {
      _urlsToTry.add('${ApiService.storageUrl}/news_images/$cleanPath');
    }

    // Remove duplicates
    _urlsToTry = _urlsToTry.toSet().toList();
    
    print('=== RobustNetworkImage URLs to try ===');
    for (int i = 0; i < _urlsToTry.length; i++) {
      print('${i + 1}. ${_urlsToTry[i]}');
    }
    print('=====================================');
  }

  void _tryNextUrl() {
    // Since we only have one URL now, just mark as error
    setState(() {
      _hasError = true;
    });
    print('=== Image failed to load: ${widget.imagePath} ===');
  }

  @override
  Widget build(BuildContext context) {
    if (_urlsToTry.isEmpty || _hasError) {
      return widget.errorWidget ?? 
        Container(
          width: widget.width,
          height: widget.height,
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

    return _buildImageWithTimeout();
  }

  Widget _buildImageWithTimeout() {
    return FutureBuilder<bool>(
      future: _testImageAvailability(_urlsToTry[_currentUrlIndex]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
                ),
              ),
            );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return CachedNetworkImage(
            imageUrl: _urlsToTry[_currentUrlIndex],
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            httpHeaders: const {
              'Connection': 'keep-alive',
              'Cache-Control': 'max-age=3600',
            },
            placeholder: (context, url) => widget.placeholder ?? 
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
                  ),
                ),
              ),
            errorWidget: (context, url, error) {
              print('=== Image Error: $url - $error ===');
              
              // Mark as error immediately
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _tryNextUrl();
              });
              
              // Show simple no image icon
              return widget.errorWidget ?? 
                Container(
                  width: widget.width,
                  height: widget.height,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                );
            },
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 100),
            memCacheWidth: widget.width?.toInt(),
            memCacheHeight: widget.height?.toInt(),
            maxWidthDiskCache: 800,
            maxHeightDiskCache: 600,
          );
        }

        // If image test failed, try next URL
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryNextUrl();
        });

        return widget.errorWidget ?? 
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[100],
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 32,
              ),
            ),
          );
      },
    );
  }

  Future<bool> _testImageAvailability(String url) async {
    try {
      print('=== Testing image availability: $url ===');
      
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      client.idleTimeout = const Duration(seconds: 10);
      
      final request = await client.headUrl(Uri.parse(url));
      request.headers.set('Connection', 'keep-alive');
      
      final response = await request.close();
      final isAvailable = response.statusCode == 200 && 
                         (response.headers.contentType?.primaryType == 'image');
      
      print('=== Image test result: $isAvailable (${response.statusCode}) ===');
      
      client.close();
      return isAvailable;
    } catch (e) {
      print('=== Image test failed: $e ===');
      return false;
    }
  }
}
