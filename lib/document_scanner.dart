import 'dart:io';

import 'package:document_scanner/edit_image_screen.dart';
import 'package:document_scanner/image_picker_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentScanner {
  final picker = ImagePicker();

  showMaterialPopup(context){
    ImagePickerModal.showForAndroid(context);
  }

  showCupertinoPopup(context){
    ImagePickerModal.showForIos(context);
  }

  pickImage(context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    if (pickedFile.path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditImageScreen(
            image: File(pickedFile.path),
          ),
        ),
      );
    }
  }

  takePhoto(context) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile.path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditImageScreen(
            image: File(pickedFile.path),
          ),
        ),
      );
    }
  }
}
