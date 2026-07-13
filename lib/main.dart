import 'package:flutter/material.dart';
import 'screens/editor_ekrani.dart';

void main() => runApp(const Uygulama());

class Uygulama extends StatelessWidget {
  const Uygulama({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Altyazı Stüdyosu',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const EditorEkrani(),
    );
  }
}