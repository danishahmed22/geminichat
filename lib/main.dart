import 'package:flutter/material.dart';
import 'package:workshop_project/consts.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'home_page.dart';

void main() {
  Gemini.init(
      apiKey: gemini_api_key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
      ),
      home: homepage(),
    );
  }
}