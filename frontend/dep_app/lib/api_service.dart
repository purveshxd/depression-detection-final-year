import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dep_app/model/response_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // upload files to server
  static Future<ResponseModel> uploadFile(File file, String ipAdd) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('http://$ipAdd:5001/upload'));

      request.headers.addAll({'Accept': '*/*'});

      // Adding file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.path.split('/').last,
        contentType: MediaType('application', 'octet-stream'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // log(jsonEncode(response.body));
        String imageData = jsonDecode(response.body)['image'];
        Uint8List bytes = base64Decode(imageData);

        String result = (jsonDecode(response.body)['result']);
        final fromServer = ResponseModel(imageData: bytes, result: result);
        return fromServer;
      } else {
        log("Not200 ==> " + response.body.toString());
        throw Exception(response.reasonPhrase);
      }
    } catch (error) {
      log("Error == " + error.toString());
      rethrow;
    }
  }

  // get data
  static Future<String?> getData() async {
    try {
      http.Response res = await http.get(Uri.parse('http://192.168.1.13:5000/'),
          headers: {'Content-type': 'application/json'});
      final body = res.body;
      log(body.toString());
      log(res.headers.toString());
      return body;
    } catch (e) {
      throw Exception(e);
    }
  }
}
