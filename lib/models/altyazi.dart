class Altyazi {
  final int id;
  String metin;
  int baslangic;
  int bitis;

  Altyazi({
    required this.id,
    required this.metin,
    required this.baslangic,
    required this.bitis,
  });

  bool iceriyorMu(int pozisyonMs) {
    return pozisyonMs >= baslangic && pozisyonMs < bitis;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'metin': metin,
        'baslangic': baslangic,
        'bitis': bitis,
      };
}