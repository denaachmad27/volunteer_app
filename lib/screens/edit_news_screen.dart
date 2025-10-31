import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/news_service.dart';
import '../services/anggota_legislatif_service.dart';

class EditNewsScreen extends StatefulWidget {
  final NewsItem news;

  const EditNewsScreen({super.key, required this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _kontenController;
  late final TextEditingController _tagsController;

  late String _selectedKategori;
  late bool _isPublished;
  File? _selectedImage;
  bool _isLoading = false;

  // Anggota Legislatif
  List<AnggotaLegislatif> _alegList = [];
  AnggotaLegislatif? _selectedAleg;
  bool _isLoadingAleg = false;

  final List<String> _categories = [
    'Pengumuman',
    'Kegiatan',
    'Bantuan',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _judulController = TextEditingController(text: widget.news.judul);
    _kontenController = TextEditingController(text: widget.news.konten);
    _tagsController = TextEditingController(text: widget.news.tags.join(', '));
    _selectedKategori = widget.news.kategori;
    _isPublished = widget.news.isPublished;

    _loadAnggotaLegislatif();
  }

  Future<void> _loadAnggotaLegislatif() async {
    setState(() {
      _isLoadingAleg = true;
    });

    try {
      final alegList = await AnggotaLegislatifService.getOptions();
      setState(() {
        _alegList = alegList;
        _isLoadingAleg = false;
        // TODO: Set selected aleg based on widget.news.anggotaLegislatifId if available
      });
    } catch (e) {
      setState(() {
        _isLoadingAleg = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar anggota legislatif: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags from comma-separated string
      List<String> tags = [];
      if (_tagsController.text.isNotEmpty) {
        tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }

      final response = await NewsService.updateNews(
        id: widget.news.id,
        judul: _judulController.text,
        konten: _kontenController.text,
        kategori: _selectedKategori,
        isPublished: _isPublished,
        tags: tags,
        gambarUtama: _selectedImage,
        anggotaLegislatifId: _selectedAleg?.id,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berita berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui berita: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Berita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFff5001),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Judul
            _buildSectionTitle('Judul Berita'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul berita',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                if (value.length < 10) {
                  return 'Judul minimal 10 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Kategori
            _buildSectionTitle('Kategori'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedKategori = newValue;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Anggota Legislatif
            _buildSectionTitle('Anggota Legislatif (Opsional)'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _isLoadingAleg
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<AnggotaLegislatif>(
                      value: _selectedAleg,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        hintText: 'Pilih Anggota Legislatif',
                      ),
                      items: [
                        const DropdownMenuItem<AnggotaLegislatif>(
                          value: null,
                          child: Text('Tidak ada'),
                        ),
                        ..._alegList.map((AnggotaLegislatif aleg) {
                          return DropdownMenuItem<AnggotaLegislatif>(
                            value: aleg,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                aleg.displayName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        }),
                      ],
                      onChanged: (AnggotaLegislatif? newValue) {
                        setState(() {
                          _selectedAleg = newValue;
                        });
                      },
                    ),
            ),

            const SizedBox(height: 24),

            // Konten
            _buildSectionTitle('Konten Berita'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kontenController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Tulis konten berita di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konten tidak boleh kosong';
                }
                if (value.length < 50) {
                  return 'Konten minimal 50 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Tags
            _buildSectionTitle('Tags (opsional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Pisahkan dengan koma, contoh: bantuan, sosial, kesehatan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Gambar
            _buildSectionTitle('Gambar Utama'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImage == null && widget.news.gambarUtama != null
                                ? 'Tap untuk mengganti gambar'
                                : 'Tap untuk memilih gambar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Maksimal 2MB, format: JPG, PNG',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (widget.news.gambarUtama != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Gambar saat ini akan dipertahankan jika tidak diganti',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Status Publish
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Publikasikan berita',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isPublished
                      ? 'Berita akan langsung muncul di aplikasi'
                      : 'Berita disimpan sebagai draft',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                value: _isPublished,
                activeColor: const Color(0xFFff5001),
                onChanged: (bool value) {
                  setState(() {
                    _isPublished = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff5001),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Update Berita',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }
}
