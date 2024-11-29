// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageView extends StatelessWidget {
  final Uint8List imageData;
  const ImageView({
    super.key,
    required this.imageData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.memory(imageData),
      ),
    );
  }
}
