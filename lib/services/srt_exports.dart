import '../models/altyazi.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Milisaniyeyi SRT zaman formatına çevir: 2500 -> "00:00:02,500"
String _msSrtFormat(int ms) {
  final saniyeTam = ms ~/ 1000;
  final msKalan = ms % 1000;
  final saat = saniyeTam ~/ 3600;
  final dakika = (saniyeTam % 3600) ~/ 60;
  final saniye = saniyeTam % 60;
  return '${saat.toString().padLeft(2, '0')}:'
         '${dakika.toString().padLeft(2, '0')}:'
         '${saniye.toString().padLeft(2, '0')},'
         '${msKalan.toString().padLeft(3, '0')}';
}

// Tüm altyazıları SRT metnine çevir
String srtUret(List<Altyazi> liste) {
  final buf = StringBuffer();
  final sirali = List<Altyazi>.from(liste)
    ..sort((a, b) => a.baslangic.compareTo(b.baslangic));

  for (var i = 0; i < sirali.length; i++) {
    final a = sirali[i];
    buf.writeln('${i + 1}');
    buf.writeln('${_msSrtFormat(a.baslangic)} --> ${_msSrtFormat(a.bitis)}');
    buf.writeln(a.metin);
    buf.writeln(); // boş satır
  }
  return buf.toString();
}

// SRT dosyasını kaydet ve yolunu döndür
Future<String> srtKaydet(List<Altyazi> liste) async {
  final dir = await getApplicationDocumentsDirectory();
  final dosya = File('${dir.path}/altyazi.srt');
  await dosya.writeAsString(srtUret(liste));
  return dosya.path;
}