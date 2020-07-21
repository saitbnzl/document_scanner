import 'dart:io';
import 'package:document_scanner/document_scanner.dart';
import 'package:document_scanner/edit_image_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImageScreen extends StatefulWidget {
  @override
  _PickImageScreenState createState() => _PickImageScreenState();
}

class _PickImageScreenState extends State<PickImageScreen> {
  DocumentScanner documentScanner = DocumentScanner();
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle =
        TextStyle(color: Colors.white, fontSize: 16);
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            color: Colors.red,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Take a Photo",
                    style: titleTextStyle,
                  )
                ],
              ),
            ),
            onPressed: () => this.takePhoto(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: MaterialButton(
              color: Colors.red,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.photo_library,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Pick from Gallery",
                      style: titleTextStyle,
                    )
                  ],
                ),
              ),
              onPressed: () => this.pickImage(),
            ),
          )
        ],
      )),
    );
  }

  pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    _goToEditScreen(pickedFile);
  }

  _goToEditScreen(pickedFile) {
    Navigator.push(
      context,
      Platform.isAndroid
          ? MaterialPageRoute(
              builder: (context) => EditImageScreen(
                image: File(pickedFile.path),
              ),
            )
          : CupertinoPageRoute(
              builder: (context) => EditImageScreen(
                image: File(pickedFile.path),
              ),
            ),
    );
  }

  takePhoto() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _goToEditScreen(pickedFile);
  }
}
