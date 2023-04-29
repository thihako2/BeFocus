import 'dart:convert';

import 'package:befocus/grammar_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:http/http.dart' as http;

class GrammarCheck extends StatefulWidget {
  const GrammarCheck({super.key});

  @override
  State<GrammarCheck> createState() => _GrammarCheckState();
}

class _GrammarCheckState extends State<GrammarCheck> {
  static const String url = "services.gingersoftware.com";
  static const String apiKey = "6ae0c3a0-afdc-4532-a810-82ded0054236";
  static const String apiVersion = "2.0";
  static const String lang = "US";
  static const String path = "Ginger/correct/jsonSecured/GingerTheTextFull";
  String _result = "Result will be show here";

  List corrections = [];
  final sentencecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BeFocus'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: TextField(
                controller: sentencecontroller,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    labelText: 'Enter english sentence',
                    hintText: 'Sentence to check grammar'),
                maxLines: null,
                expands: true,
                textInputAction: TextInputAction.go,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () {
                  Future result = parse(sentencecontroller.text);
                  print(result);
                },
                child: Text(
                  "Check Grammar",
                  style: TextStyle(color: Colors.white),
                )),
            SizedBox(
              height: 20,
            ),
            Text(
              _result,
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: corrections.length,
                itemBuilder: (BuildContext ctxt, int Index) {
                  return ListTile(
                    title: Container(
                        child: Row(
                      children: [
                        Text(
                          corrections[Index]['correct'] != ''
                              ? 'what the correct word is '
                              : "We don't need this",
                          style: TextStyle(
                              color: corrections[Index]['correct'] != ''
                                  ? Colors.grey
                                  : Colors.black,
                              fontWeight: corrections[Index]['correct'] != ''
                                  ? FontWeight.normal
                                  : FontWeight.bold),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          corrections[Index]['correct'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
                    subtitle: Container(
                        child: Row(
                      children: [
                        Text(
                          'what the wrong word u write',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          corrections[Index]['text'],
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
      ),
    );
  }

  Future<Map<String, dynamic>> parse(String text) async {
    var params = {
      "lang": lang,
      "apiKey": apiKey,
      "clientVersion": apiVersion,
      "text": text,
    };

    var response = await http.get(
      Uri.https(url, path, params),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var data = json.decode(response.body);
    return _processData(text, data);
  }

  Map<String, dynamic> _processData(String text, Map<String, dynamic> data) {
    var result = text;
    corrections = [];

    for (var suggestion in data['Corrections'].reversed) {
      var start = suggestion['From'];
      var end = suggestion['To'];

      if (suggestion['Suggestions'].isNotEmpty) {
        var suggest = suggestion['Suggestions'][0];
        result = changeChar(result, start, end, suggest['Text']);

        corrections.add({
          'start': start,
          'text': text.substring(start, end + 1),
          'correct': suggest['Text'],
          'definition': suggest['Definition'],
        });
      }
    }

    print(corrections);

    _result = result;
    setState(() {});

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
}
