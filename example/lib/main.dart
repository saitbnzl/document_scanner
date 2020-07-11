import 'package:flutter/material.dart';
import 'package:document_scanner/document_scanner.dart';

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
          body: Center(
              child: ScanButton())),
    );
  }
}

class ScanButton extends StatelessWidget {
  DocumentScanner _documentScanner = DocumentScanner();

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.red,
          child: Text("Scan Document",style: TextStyle(color: Colors.white, fontSize: 16),),
        ),
        onPressed: () => _documentScanner.show(context));
  }
}

