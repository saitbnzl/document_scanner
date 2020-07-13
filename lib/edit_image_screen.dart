import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:document_scanner/document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

class EditImageScreen extends StatefulWidget {
  EditImageScreen({this.image});
  final File image;
  @override
  _EditImageScreenState createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  DocumentScanner documentScanner = DocumentScanner();
  image.Image _image;
  Uint8List _imageData;
  @override
  void initState() {
    _imageData = widget.image.readAsBytesSync();
    _image = image.decodeImage(_imageData);
    image.grayscale(_image);
    image.contrast(_image, 125);
    _imageData = image.encodeJpg(_image);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Document'),
      ),
      body: Center(
          child: Image.memory(
        _imageData,
      )),
    );
  }
}
