import 'package:dep_app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    getPermission() async {
      var isGranted = await Permission.manageExternalStorage.isGranted;
      if (!isGranted) {
        Permission.manageExternalStorage.request();
      }
    }

    getPermission();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorSchemeSeed: Colors.teal),
      home: const Homepage(),
    );
  }
}
