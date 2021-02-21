import 'package:flutter/material.dart';
import 'package:video_stream/screen/lending.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Lending(),
    );
  }
}
