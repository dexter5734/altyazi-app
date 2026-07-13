// Tek bir altyazı satırı. Tüm zamanlar MİLİSANİYE.
class Altyazi {
  final int id;
  String metin;
  int baslangic;  // ms
  int bitis;      // ms

  Altyazi({
    required this.id,
    required this.metin,
    required this.baslangic,
    required this.bitis,
  });

  // Verilen zaman bu satırın içinde mi?
  bool iceriyorMu(int pozisyonMs) {
    return pozisyonMs >= baslangic && pozisyonMs < bitis;
  }

  // Kayıt için JSON'a çevir
  Map<String, dynamic> toJson() => {
    'id': id,
    'metin': metin,
    'baslangic': baslangic,
    'bitis': bitis,
  };
}