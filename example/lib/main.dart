import 'dart:io';
import 'dart:typed_data';

import 'package:document_scanner/document_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(child: ScanButton())),
    );
  }
}

class ScanButton extends StatelessWidget {
  final DocumentScanner _documentScanner = DocumentScanner();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (Platform.isAndroid) {
          _documentScanner.showMaterialPopup(context,
              onCompleted: (Uint8List imageData,Size _) {});
        } else if (Platform.isIOS) {
          _documentScanner.showCupertinoPopup(context,
              onCompleted: (Uint8List imageData, Size _) {});
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.red,
        child: Text(
          "Scan Document",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
