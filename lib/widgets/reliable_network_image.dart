import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';

class ReliableNetworkImage extends StatefulWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ReliableNetworkImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ReliableNetworkImage> createState() => _ReliableNetworkImageState();
}

class _ReliableNetworkImageState extends State<ReliableNetworkImage> {
  int _currentUrlIndex = 0;
  List<String> _urlsToTry = [];

  @override
  void initState() {
    super.initState();
    _generateUrls();
  }

  void _generateUrls() {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      _urlsToTry = [];
      return;
    }

    final path = widget.imagePath!;
    if (path.startsWith('http')) {
      _urlsToTry = [path];
      return;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // Use ApiService.storageUrl untuk menggunakan konfigurasi yang sama
    if (cleanPath.startsWith('news_images/')) {
      _urlsToTry = [
        '${ApiService.storageUrl}/$cleanPath',
      ];
    } else if (cleanPath.startsWith('complaint_images/')) {
      _urlsToTry = [
        '${ApiService.storageUrl}/$cleanPath',
      ];
    } else {
      // Try both news and complaint directories as fallback
      _urlsToTry = [
        '${ApiService.storageUrl}/complaint_images/$cleanPath',
        '${ApiService.storageUrl}/news_images/$cleanPath',
      ];
    }

    print('=== Reliable Image URLs ===');
    for (int i = 0; i < _urlsToTry.length; i++) {
      print('${i + 1}. ${_urlsToTry[i]}');
    }
    print('===========================');
  }

  void _tryNextUrl() {
    if (_currentUrlIndex < _urlsToTry.length - 1) {
      setState(() {
        _currentUrlIndex++;
      });
      print('=== Trying URL ${_currentUrlIndex + 1}: ${_urlsToTry[_currentUrlIndex]} ===');
    }
  }

  Widget _buildErrorWidget() {
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

  @override
  Widget build(BuildContext context) {
    if (_urlsToTry.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      key: Key('${_urlsToTry[_currentUrlIndex]}_$_currentUrlIndex'),
      imageUrl: _urlsToTry[_currentUrlIndex],
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => widget.placeholder ?? 
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          ),
        ),
      errorWidget: (context, url, error) {
        print('=== Image Error URL ${_currentUrlIndex + 1} ===');
        print('URL: $url');
        print('Error: $error');
        print('====================================');
        
        if (_currentUrlIndex < _urlsToTry.length - 1) {
          // Try next URL
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tryNextUrl();
          });
          
          // Show loading while trying next URL
          return widget.placeholder ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              ),
            );
        } else {
          // All URLs failed, show error widget
          return _buildErrorWidget();
        }
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}