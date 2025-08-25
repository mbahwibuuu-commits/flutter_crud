import 'package:flutter/material.dart';

void main() {
  runApp(const MobilApp());
}

class MobilApp extends StatelessWidget {
  const MobilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Mobil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      home: const MobilHomePage(),
    );
  }
}

class Mobil {
  final int id;
  final String namaMobil;
  final String nomorRangka;
  final String warna;
  final DateTime tanggal;

  Mobil({
    required this.id,
    required this.namaMobil,
    required this.nomorRangka,
    required this.warna,
    required this.tanggal,
  });

  Mobil copyWith({
    int? id,
    String? namaMobil,
    String? nomorRangka,
    String? warna,
    DateTime? tanggal,
  }) {
    return Mobil(
      id: id ?? this.id,
      namaMobil: namaMobil ?? this.namaMobil,
      nomorRangka: nomorRangka ?? this.nomorRangka,
      warna: warna ?? this.warna,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}

class MobilHomePage extends StatefulWidget {
  const MobilHomePage({super.key});

  @override
  State<MobilHomePage> createState() => _MobilHomePageState();
}

class _MobilHomePageState extends State<MobilHomePage> {
  final List<Mobil> _items = [];
  int _autoId = 0;
  String _search = '';

  List<Mobil> get _filteredItems {
    if (_search.isEmpty) return _items;
    return _items.where((m) {
      final q = _search.toLowerCase();
      return m.namaMobil.toLowerCase().contains(q) ||
          m.nomorRangka.toLowerCase().contains(q) ||
          m.warna.toLowerCase().contains(q) ||
          _fmtDate(m.tanggal).contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Mobil'),
        actions: [
          IconButton(
            tooltip: 'Hapus semua',
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final ok = await _confirm(context,
                        'Hapus semua data?', 'Tindakan ini tidak bisa dibatalkan.');
                    if (ok) setState(_items.clear);
                  },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari (nama/nomor rangka/warna/tanggal)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100, left: 8, right: 8),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final m = _filteredItems[index];
                      return Dismissible(
                        key: ValueKey(m.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline),
                        ),
                        confirmDismiss: (_) async {
                          return _confirm(context, 'Hapus data?', m.namaMobil);
                        },
                        onDismissed: (_) {
                          setState(() => _items.removeWhere((e) => e.id == m.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Terhapus: ${m.namaMobil}')),
                          );
                        },
                        child: _MobilCard(
                          mobil: m,
                          onEdit: () => _openForm(editing: m),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Future<void> _openForm({Mobil? editing}) async {
    final result = await showModalBottomSheet<Mobil>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _MobilForm(initial: editing),
      ),
    );

    if (result == null) return;

    setState(() {
      if (editing == null) {
        _items.add(result.copyWith(id: _autoId++));
      } else {
        final idx = _items.indexWhere((e) => e.id == editing.id);
        if (idx != -1) _items[idx] = result.copyWith(id: editing.id);
      }
    });
  }

  static Future<bool> _confirm(BuildContext context, String title, String msg) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );
    return result ?? false;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_filled, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            const Text('Belum ada data mobil'),
            const SizedBox(height: 4),
            Text(
              'Tekan tombol Tambah untuk membuat data baru',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobilCard extends StatelessWidget {
  final Mobil mobil;
  final VoidCallback onEdit;
  const _MobilCard({required this.mobil, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mobil.namaMobil,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Labeled('Nomor Rangka', mobil.nomorRangka),
              const SizedBox(height: 6),
              _Labeled('Warna', mobil.warna),
              const SizedBox(height: 6),
              _Labeled('Tanggal', _fmtDate(mobil.tanggal)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final String value;
  const _Labeled(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: style?.copyWith(color: Colors.grey[700])),
        ),
        Expanded(
          child: Text(value, style: style),
        )
      ],
    );
  }
}

class _MobilForm extends StatefulWidget {
  final Mobil? initial;
  const _MobilForm({this.initial});

  @override
  State<_MobilForm> createState() => _MobilFormState();
}

class _MobilFormState extends State<_MobilForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _rangkaCtrl = TextEditingController();
  final _warnaCtrl = TextEditingController();
  DateTime? _tanggal;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _namaCtrl.text = i.namaMobil;
      _rangkaCtrl.text = i.nomorRangka;
      _warnaCtrl.text = i.warna;
      _tanggal = i.tanggal;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _rangkaCtrl.dispose();
    _warnaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit Data Mobil' : 'Tambah Data Mobil',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Mobil *', hintText: 'Contoh: Avanza 1.3 G'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _rangkaCtrl,
              decoration: const InputDecoration(labelText: 'Nomor Rangka *', hintText: 'Contoh: MHKA1234567890'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor rangka wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _warnaCtrl,
              decoration: const InputDecoration(labelText: 'Warna *', hintText: 'Contoh: Putih Metallic'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Warna wajib diisi' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(now.year - 10),
                        lastDate: DateTime(now.year + 10),
                        initialDate: _tanggal ?? now,
                      );
                      if (picked != null) setState(() => _tanggal = picked);
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(_tanggal == null ? 'Pilih Tanggal *' : _fmtDate(_tanggal!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal wajib dipilih')));
      return;
    }

    final data = Mobil(
      id: widget.initial?.id ?? -1,
      namaMobil: _namaCtrl.text.trim(),
      nomorRangka: _rangkaCtrl.text.trim(),
      warna: _warnaCtrl.text.trim(),
      tanggal: _tanggal!,
    );

    Navigator.pop(context, data);
  }
}

String _fmtDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd-$mm-$yyyy';
}
