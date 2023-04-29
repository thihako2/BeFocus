import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:befocus/Screens/PronunciationScreen/PronunciationCheckScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:language_tool/language_tool.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:dart_phonetics/dart_phonetics.dart';
import 'package:http/http.dart' as http;

/// Import the text_analysis package.

import 'package:text_analysis/text_analysis.dart';

/// Import the extensions if you prefer the convenience of calling an extension.
import 'package:text_analysis/extensions.dart';

/// Private import for formatted printing to the console.
import 'package:gmconsult_dev/gmconsult_dev.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PronunciationCheck(),
    );
  }
}
