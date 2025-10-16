import 'package:flutter/material.dart';
import 'dart:io';
import '../services/relawan_service.dart';

class RelawanWargaScreen extends StatefulWidget {
  const RelawanWargaScreen({super.key});

  @override
  State<RelawanWargaScreen> createState() => _RelawanWargaScreenState();
}

class _RelawanWargaScreenState extends State<RelawanWargaScreen> {
  bool _loading = true;
  String? _error;
  PaginatedWarga? _data;
  String _search = '';
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await RelawanService.listWarga(search: _search, page: page);
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showAssignDialog() async {
    final ctl = TextEditingController();
    final res = await showDialog<List<int>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Warga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan ID warga, pisahkan dengan koma.'),
            const SizedBox(height: 8),
            TextField(
              controller: ctl,
              decoration: const InputDecoration(hintText: 'cth: 12, 45, 78'),
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () {
            final raw = ctl.text.trim();
            if (raw.isEmpty) { Navigator.pop(ctx); return; }
            final parts = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            final ids = <int>[];
            for (final p in parts) {
              final n = int.tryParse(p);
              if (n != null) ids.add(n);
            }
            Navigator.pop(ctx, ids);
          }, child: const Text('Assign')),
        ],
      ),
    );

    if (res != null && res.isNotEmpty) {
      try {
        final r = await RelawanService.assignWarga(wargaIds: res);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil assign: ${r['data']?['assigned_count'] ?? 0}. Dilewati: ${(r['data']?['skipped_already_assigned'] as List?)?.length ?? 0}')),
        );
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal assign: $e')));
      }
    }
  }

  Future<void> _showCreateWargaDialog() async {
    final namaCtl = TextEditingController();
    final nikCtl = TextEditingController();
    final alamatCtl = TextEditingController();
    final fotoCtl = TextEditingController(); // sementara: path file lokal opsional

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Warga Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nikCtl,
                decoration: const InputDecoration(labelText: 'No KTP (NIK)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: alamatCtl,
                decoration: const InputDecoration(labelText: 'Alamat'),
                keyboardType: TextInputType.streetAddress,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fotoCtl,
                decoration: const InputDecoration(
                  labelText: 'Path Foto KTP (opsional)',
                  hintText: '/storage/emulated/0/Download/ktp.jpg',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catatan: pemilihan file langsung belum tersedia. Isi path file jika diperlukan.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (res == true) {
      try {
        final filePath = fotoCtl.text.trim();
        final file = filePath.isNotEmpty ? File(filePath) : null;
        final r = await RelawanService.createWarga(
          namaLengkap: namaCtl.text.trim(),
          nik: nikCtl.text.trim(),
          alamat: alamatCtl.text.trim(),
          ktpFoto: file,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warga berhasil ditambahkan')),
        );
        _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah warga: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFff5001), Color(0xFFe64100)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Warga Binaan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: _showCreateWargaDialog,
                      icon: const Icon(Icons.person_add_rounded, color: Colors.white),
                      tooltip: 'Tambah Warga',
                    ),
                    IconButton(
                      onPressed: _showAssignDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                      tooltip: 'Assign Warga',
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: TextField(
                          controller: _searchCtl,
                          decoration: InputDecoration(
                            hintText: 'Cari nama/nik/alamat/email/telepon',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search_rounded),
                              onPressed: () { setState(() { _search = _searchCtl.text.trim(); }); _load(); },
                            ),
                          ),
                          onSubmitted: (_) { setState(() { _search = _searchCtl.text.trim(); }); _load(); },
                        ),
                      ),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }
    final data = _data!;
    if (data.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Colors.grey[500], size: 40),
              const SizedBox(height: 8),
              const Text('Belum ada warga binaan'),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        itemCount: data.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final w = data.items[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFff5001).withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_rounded, color: Color(0xFFff5001))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(w.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                    if (w.profile != null && (w.profile!['nik'] != null || w.profile!['alamat'] != null))
                      Text('${w.profile!['nik'] ?? '-'} • ${w.profile!['alamat'] ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
