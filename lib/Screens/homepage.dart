import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:http/http.dart';
import 'package:voice_navigation_example/Operations/voiceOperations.dart';
import 'package:voice_navigation_example/Widgets/imageWidget.dart';

class Homepage extends StatelessWidget {
  final String? title;

  const Homepage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title!)), body: const VoiceRecognition());
  }
}

class VoiceRecognition extends StatefulWidget {
  const VoiceRecognition({super.key});

  @override
  State<VoiceRecognition> createState() => _VoiceRecognitionState();
}

class _VoiceRecognitionState extends State<VoiceRecognition> {
  bool isRecording = false;
  SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  bool _speechEnabled = false;
  VoiceOperations voiceOperations = VoiceOperations();
  String? pokemonUrl;
  String? pokemonName;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageWidget(
            url: pokemonUrl,
            name: pokemonName,
            key: const ValueKey('pokemon image'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(_lastWords),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: GestureDetector(
              onTap: onMicIconTap,
              child: Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: (_speechToText.isListening)
                          ? Colors.red
                          : Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      border:
                          Border.all(color: const Color.fromARGB(92, 0, 0, 0))),
                  child: const Icon(Icons.mic, size: 20)),
            ),
          ),
        ],
      ),
    );
  }

  //functions

  void onMicIconTap() {
    (isRecording) ? _stopListening() : _startListening();

    setState(() {
      isRecording = !isRecording;
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (status.contains('done')) {
            setState(() {});
          }
        },
        debugLogging: true);

    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        listenMode: ListenMode.dictation,
        sampleRate: 44100);
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    if (result.finalResult) {
      //make the api call to the backend service
      Map<String, dynamic> response =
          await voiceOperations.detectIntent(_lastWords);
      setState(() {
        _lastWords = response['responseText'];
      });

      if (response['pokemonNumber'] != null) {
        getPokemonImage(response['pokemonNumber']);
      }
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void getPokemonImage(pokemonNumber) async {
    Response response = await get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonNumber'));
    Map<String, dynamic> body = jsonDecode(response.body);
    if (mounted) {
      setState(() {
        pokemonUrl = body['sprites']['front_default'];
        pokemonName = body['name'];
      });
    }
  }
}
