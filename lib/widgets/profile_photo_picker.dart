import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/profile_service.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final String? currentPhotoUrl;
  final String? currentPhotoUpdatedAt;
  final Function(File?) onPhotoSelected;
  final double size;

  const ProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    this.currentPhotoUpdatedAt,
    required this.onPhotoSelected,
    this.size = 120,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Foto Profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFff5001),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFff5001).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildPhotoContent(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(
            Icons.camera_alt,
            color: Color(0xFFff5001),
            size: 18,
          ),
          label: Text(
            _selectedImage != null || widget.currentPhotoUrl != null
                ? 'Ganti Foto'
                : 'Tambah Foto',
            style: const TextStyle(
              color: Color(0xFFff5001),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoContent() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else if (widget.currentPhotoUrl != null && widget.currentPhotoUrl!.isNotEmpty) {
      final imageUrl = ProfileService.getProfilePhotoUrl(
        widget.currentPhotoUrl!,
        version: widget.currentPhotoUpdatedAt,
      );
      print('ProfilePhotoPicker: Loading image from URL: $imageUrl');
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff5001)),
          ),
        ),
        errorWidget: (context, url, error) {
          print('ProfilePhotoPicker: Error loading image from URL: $url, Error: $error');
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFff5001),
            Color(0xFF764ba2),
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  if (_selectedImage != null || widget.currentPhotoUrl != null)
                    _buildSourceOption(
                      icon: Icons.delete,
                      label: 'Hapus',
                      onTap: _removeImage,
                      isDestructive: true,
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : const Color(0xFFff5001).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : const Color(0xFFff5001).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFFff5001),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.red : const Color(0xFFff5001),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final original = File(image.path);
        try {
          // Copy to app-managed temp directory to avoid ephemeral cache deletion
          final tempDir = await getTemporaryDirectory();
          final ext = p.extension(image.path).isNotEmpty ? p.extension(image.path) : '.jpg';
          final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
          final savedPath = p.join(tempDir.path, fileName);
          final persistent = await original.copy(savedPath);

          setState(() {
            _selectedImage = persistent;
          });
          widget.onPhotoSelected(_selectedImage);
        } catch (copyError) {
          // Fallback: use original path
          setState(() {
            _selectedImage = original;
          });
          widget.onPhotoSelected(_selectedImage);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onPhotoSelected(null);
  }
}
