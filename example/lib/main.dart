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
  Uint8List imageData,imageData1,imageData2, imageData3;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {}
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  ScanButton(
                    onCompleted: (data) {
                      setState(() {
                        imageData = data;
                      });
                    },
                  ),
                  if (imageData != null) Container(child: Image.memory(imageData),height: 50,width: 50,),
                ],
              ),
              Column(
                children: [
                  ScanButton(
                    onCompleted: (data) {
                      setState(() {
                        imageData1 = data;
                      });
                    },
                  ),
                  if (imageData1 != null) Container(child: Image.memory(imageData1),height: 50,width: 50,),
                ],
              ),
              Column(
                children: [
                  ScanButton(
                    onCompleted: (data) {
                      setState(() {
                        imageData2 = data;
                      });
                    },
                  ),
                  if (imageData2 != null) Container(child: Image.memory(imageData2),height: 50,width: 50,),
                ],
              ),
              Column(
                children: [
                  ScanButton(
                    onCompleted: (data) {
                      setState(() {
                        imageData3 = data;
                      });
                    },
                  ),
                  if (imageData3 != null) Container(child: Image.memory(imageData3),height: 50,width: 50,),
                ],
              ),
            ],
          ))),
    );
  }
}

class ScanButton extends StatelessWidget {
  ScanButton({this.onCompleted});
  final DocumentScanner _documentScanner = DocumentScanner();
  final Function onCompleted;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (Platform.isAndroid) {
          _documentScanner.showMaterialPopup(context,
              onCompleted: (Uint8List imageData, Size _) {
            onCompleted(imageData);
          });
        } else if (Platform.isIOS) {
          _documentScanner.showCupertinoPopup(context,
              onCompleted: (Uint8List imageData, Size _) {
            onCompleted(imageData);
          });
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
