import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/altyazi.dart';
import '../services/srt_exports.dart';

class EditorEkrani extends StatefulWidget {
  const EditorEkrani({super.key});
  @override
  State<EditorEkrani> createState() => _EditorEkraniState();
}

class _EditorEkraniState extends State<EditorEkrani> {
  VideoPlayerController? _kontrolcu;
  List<Altyazi> _altyazilar = [];
  int _sonId = 0;

  String _yeniMetin = '';
  int? _baslangicMs;
  int _aktifPozisyonMs = 0;

  bool get _videoHazir => _kontrolcu?.value.isInitialized ?? false;

  Future<void> _videoSec() async {
    final sonuc = await FilePicker.platform.pickFiles(type: FileType.video);
    if (sonuc == null) return;
    final dosya = sonuc.files.first;
    final yedek = _kontrolcu;
    _kontrolcu = VideoPlayerController.file(File(dosya.path!));
    await _kontrolcu!.initialize();
    yedek?.dispose();
    _kontrolcu!.addListener(_dinleyici);
    setState(() {});
  }

  void _dinleyici() {
    if (!_videoHazir) return;
    final p = _kontrolcu!.value.position.inMilliseconds;
    if (p != _aktifPozisyonMs) {
      setState(() => _aktifPozisyonMs = p);
    }
  }

  @override
  void dispose() {
    _kontrolcu?.removeListener(_dinleyici);
    _kontrolcu?.dispose();
    super.dispose();
  }

  Altyazi? get _aktifAltyazi {
    for (final a in _altyazilar) {
      if (a.iceriyorMu(_aktifPozisyonMs)) return a;
    }
    return null;
  }

  void _baslaYakala() {
    if (!_videoHazir) return;
    setState(() {
      _baslangicMs = _baslangicMs == null ? _aktifPozisyonMs : null;
    });
  }

  void _bitirVeEkle() {
    if (!_videoHazir || _baslangicMs == null || _yeniMetin.isEmpty) return;
    final bitis = _aktifPozisyonMs;
    if (bitis <= _baslangicMs!) return;
    setState(() {
      _altyazilar.add(Altyazi(
        id: ++_sonId,
        metin: _yeniMetin,
        baslangic: _baslangicMs!,
        bitis: bitis,
      ));
      _yeniMetin = '';
      _baslangicMs = null;
    });
  }

  Future<void> _srtDisaAktar() async {
    if (_altyazilar.isEmpty) return;
    final yol = await srtKaydet(_altyazilar);
    await Share.shareXFiles([XFile(yol)], text: 'Altyazı dosyası');
  }

  String _sureYaz(int ms) {
    final s = (ms / 1000).toStringAsFixed(1);
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Altyazı Stüdyosu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _altyazilar.isEmpty ? null : _srtDisaAktar,
            tooltip: 'SRT dışa aktar',
          ),
        ],
      ),
      body: _kontrolcu == null ? _bosEkran() : _editorEkran(),
    );
  }

  Widget _bosEkran() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _videoSec,
        icon: const Icon(Icons.video_library),
        label: const Text('Video Seç'),
      ),
    );
  }

  Widget _editorEkran() {
    final aktif = _aktifAltyazi;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: _kontrolcu!.value.aspectRatio,
              child: VideoPlayer(_kontrolcu!),
            ),
            if (aktif != null)
              Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Text(
                  aktif.metin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_kontrolcu!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
              iconSize: 40,
              onPressed: () => setState(() => _kontrolcu!.value.isPlaying
                  ? _kontrolcu!.pause()
                  : _kontrolcu!.play()),
            ),
            Text('  Pozisyon: ${_sureYaz(_aktifPozisyonMs)}'),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Altyazı metni',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _yeniMetin = v,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _baslaYakala,
                      child: Text(_baslangicMs == null
                          ? '▶ BAŞLA'
                          : 'Başla: ${_sureYaz(_baslangicMs!)}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _bitirVeEkle,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('⏹ BİTİR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _altyazilar.length,
            itemBuilder: (_, i) {
              final a = _altyazilar[i];
              return ListTile(
                leading: Text('${i + 1}'),
                title: Text(a.metin),
                subtitle:
                    Text('${_sureYaz(a.baslangic)} → ${_sureYaz(a.bitis)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      setState(() => _altyazilar.removeAt(i)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
