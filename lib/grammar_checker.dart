import 'dart:convert';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

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
}
