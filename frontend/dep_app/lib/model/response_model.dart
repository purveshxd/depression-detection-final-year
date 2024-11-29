import 'dart:typed_data';

class ResponseModel {
  Uint8List imageData;
  String result;

  ResponseModel({required this.imageData, required this.result});
}
