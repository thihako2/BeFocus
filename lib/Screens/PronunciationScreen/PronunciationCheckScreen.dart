import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
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

class PronunciationCheck extends StatefulWidget {
  const PronunciationCheck({super.key});

  @override
  State<PronunciationCheck> createState() => _PronunciationCheckState();
}

class _PronunciationCheckState extends State<PronunciationCheck> {
  @override
  late stt.SpeechToText _speech;
  GoogleTranslator translator = GoogleTranslator();
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  String _text2 = "pronunciation check true or false will be here";
  double _confidence = 1.0;
  List<String> wrongwords = [];
  List<String> speechwrongwords = [];
  final FlutterTts ftts = FlutterTts();
  final tool = LanguageTool();
  static const String url = "services.gingersoftware.com";
  static const String apiKey = "6ae0c3a0-afdc-4532-a810-82ded0054236";
  static const String apiVersion = "2.0";
  static const String lang = "US";

  final soundex = RefinedSoundex.defaultEncoder;
  // String _selectectedlocale = 'my_MM';
  final _selectectedlocale = 'en-US';
  speak(String text) async {
    await ftts.setLanguage(_selectectedlocale);
    await ftts.setPitch(1);
    await ftts.speak(text);
  }

  final Map<String, HighlightedWord> _highlight = {
    'flutter': HighlightedWord(
      onTap: () => print('flutter'),
      textStyle:
          const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),
    'voice': HighlightedWord(
        onTap: () => print('flutter'),
        textStyle:
            const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)} %')),
        body: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                Text(
                  _text,
                  style: const TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  _text2.toString(),
                  style: const TextStyle(
                    fontSize: 32.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: wrongwords.length,
                    itemBuilder: (BuildContext ctxt, int Index) {
                      return ListTile(
                        onTap: () {
                          speak(wrongwords[Index]); // Print to console
                        },
                        title: Container(
                            child: Row(
                          children: [
                            Text(
                              'what the real word is ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              wrongwords[Index],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
                        subtitle: Container(
                            child: Row(
                          children: [
                            Text(
                              'what the word u speak',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              speechwrongwords[Index],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
                        trailing: Icon(Icons.edit),
                      );
                      ;
                    }),
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ));
  }

  void _listen() async {
    // _printTokens('TOKENIZE PARAGRAPHS', await _tokenizeParagraphs(exampleText));
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('OnStatus: $val'),
        onError: (val) {
          print('OnError: $val');
        },
        debugLogging: true,
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        // var locales = await _speech.locales();

        // var selectedLocale = locales[0];
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });

            translate();
          },
          // localeId: _selectedlocale,
          localeId: _selectectedlocale,
        );
      }
    } else {
      setState(() {
        _isListening = false;
      });
      // translate();
      _speech.stop();
    }
  }

  Future<void> translate() async {
    var words = _text.split(' ');
    var encodewords = words.map((e) => soundex.encode(e)?.primary);
    // var encoding = soundex.encode(_text);
    // var hellotext = "The quick brown fox jumps over the lazy dog";
    var hellotext = "I is love";
    var hellowords = hellotext.split(' ');
    // var helloencode =
    //     soundex.encode("The quick brown fox jumps over the lazy dog");
    var encodehellowords = hellowords.map((e) => soundex.encode(e)?.primary);

    if (encodewords.length == encodehellowords.length) {
      wrongwords = [];
      for (var i = 0; i < encodewords.length; i++) {
        if (encodewords.elementAt(i) == encodehellowords.elementAt(i)) {
          _text2 = "True";
          var headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          };
        } else {
          _text2 = "False";
          wrongwords.add(hellowords.elementAt(i));
          speechwrongwords.add(words.elementAt(i));
        }
      }
    }

    setState(() {});
  }
}
