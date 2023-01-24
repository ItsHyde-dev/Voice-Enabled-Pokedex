import 'dart:convert';

import 'package:http/http.dart';
import '../Constants/url.dart';

class VoiceOperations {
  Future<Map<String, dynamic>> detectIntent(text) async {
    Response response = await post(
        Uri.parse('$backendBaseUrl/voice/detectIntent'),
        body: {"text": text});

    Map<String, dynamic> body = jsonDecode(response.body);

    Map<String, dynamic> responseObject = {
      "responseText": body['data']['responseText'],
      "intent": body['data']['intent']
    };

    if (body['data']['intent'] == 'Open page') {
      responseObject['pageNumber'] = body['data']['pageNumber'];
    }

    if (body['data']['intent'] == 'Show Pokemon') {
      responseObject['pokemonNumber'] = body['data']['pokemonNumber'];
    }

    return responseObject;
  }
}
