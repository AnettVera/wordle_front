import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle',
      theme: wordleTheme,
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
