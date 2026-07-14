import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/altyazi.dart';

class AsrService {
  // Groq API key (doğrudan burada)
  static const String _apiKey = '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';
  static const String _groqUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';

  static Future<List<Altyazi>> transcribe({
    required String filePath,
  }) async {
    final file = File(filePath);
    final request = http.MultipartRequest('POST', Uri.parse(_groqUrl))
      ..headers['Authorization'] = 'Bearer $_apiKey'
      ..fields['model'] = 'whisper-large-v3'
      ..fields['response_format'] = 'verbose_json'
      ..fields['timestamp_granularities[]'] = 'segment'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(
          'Transkript başarısız (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final segments = (json['segments'] as List<dynamic>?) ?? [];

    final List<Altyazi> liste = [];
    int id = 0;
    for (final seg in segments) {
      final s = seg as Map<String, dynamic>;
      final text = (s['text'] as String? ?? '').trim();
      if (text.isEmpty) continue;
      final startMs = ((s['start'] as num?)?.toDouble() ?? 0.0) * 1000;
      final endMs = ((s['end'] as num?)?.toDouble() ?? 0.0) * 1000;
      liste.add(Altyazi(
        id: ++id,
        metin: text,
        baslangic: startMs.toInt(),
        bitis: endMs.toInt(),
      ));
    }
    return liste;
  }
}
