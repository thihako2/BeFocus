import 'dart:convert';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gmconsult_dev/gmconsult_dev.dart';
import 'package:http/http.dart' as http;
import 'package:text_analysis/text_analysis.dart';

class GrammarChecker extends StatefulWidget {
  const GrammarChecker({super.key});

  @override
  State<GrammarChecker> createState() => _GrammarCheckerState();
}

class _GrammarCheckerState extends State<GrammarChecker> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  static const String url = "services.gingersoftware.com";
  static const String apiKey = "6ae0c3a0-afdc-4532-a810-82ded0054236";
  static const String apiVersion = "2.0";
  static const String lang = "US";

  static const exampleText = ['The quick brown fox jumps over the lazy dog'];
  Future<Map<String, dynamic>> parse(String text) async {
    var params = {
      "lang": lang,
      "apiKey": apiKey,
      "clientVersion": apiVersion,
      "text": text,
    };

    var response = await http.get(
      Uri.https(url, "Ginger/correct/jsonSecured/GingerTheTextFull", params),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var data = json.decode(response.body);
    return _processData(text, data);
  }

  Map<String, dynamic> _processData(String text, Map<String, dynamic> data) {
    var result = text;
    var corrections = [];

    for (var suggestion in data['Corrections'].reversed) {
      var start = suggestion['From'];
      var end = suggestion['To'];

      if (suggestion['Suggestions'].isNotEmpty) {
        var suggest = suggestion['Suggestions'][0];
        // result = changeChar(result, start, end, suggest['Text']);

        corrections.add({
          'start': start,
          'text': text.substring(start, end + 1),
          'correct': suggest['Text'],
          'definition': suggest['Definition'],
        });
      }
    }

    print(corrections);

    return {
      'text': text,
      'result': result,
      'corrections': corrections,
    };
  }

  String changeChar(String originalText, int fromPosition, int toPosition,
      String changeWith) {
    return originalText.replaceRange(fromPosition, toPosition + 1, changeWith);
  }

  //no need but for more confortable
  Future<List<Token>> _tokenizeParagraphs(Iterable<String> paragraphs) async {
    //

    // Initialize a StringBuffer to hold the source text
    final sourceBuilder = StringBuffer();

    // Concatenate the elements of [text] using line-endings
    for (final src in exampleText) {
      sourceBuilder.writeln(src);
    }

    // convert the StringBuffer to a String
    final source = sourceBuilder.toString();

    // tokenize the source
    final tokens = await English.analyzer.tokenizer(source);

    return tokens;
  }

  void _printTokens(String title, Iterable<Token> tokens) {
    //

    // map the tokens to a list of JSON documents
    final results = tokens
        .map(
            (e) => {'term': e.term, 'zone': e.zone, 'position': e.termPosition})
        .toList();

    // print the results
    Console.out(title: title, results: results);

    //
  }
}
