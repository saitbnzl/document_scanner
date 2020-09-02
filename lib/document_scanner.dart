import 'dart:io';

import 'package:document_scanner/edit_image_screen.dart';
import 'package:document_scanner/image_picker_modal.dart';
import 'package:document_scanner/platform_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DocumentScanner {
  final picker = ImagePicker();

  showMaterialPopup(context, {Function onCompleted, bool noEdit = false}) {
    PlatformBottomSheet.showForAndroid(
        context,
        ImagePickerModal(
          onCompleted: onCompleted,
          noEdit: noEdit,
        ));
  }

  showCupertinoPopup(context, {Function onCompleted, bool noEdit = false}) {
    PlatformBottomSheet.showForIos(
        context,
        ImagePickerModal(
          onCompleted: onCompleted,
          noEdit: noEdit,
        ));
  }

  pickImage(context, {Function onCompleted, bool noEdit = false}) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    Navigator.of(context).pop();
    if (pickedFile?.path != null) {
      if (noEdit) {
        onCompleted(File(pickedFile.path));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditImageScreen(
                context: context,
                image: File(pickedFile.path),
                onCompleted: onCompleted),
          ),
        );
      }
    }
  }

  takePhoto(context, {Function onCompleted, bool noEdit = false}) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    Navigator.of(context).pop();
    if (pickedFile?.path != null) {
      if (noEdit) {
        onCompleted(File(pickedFile.path));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditImageScreen(
                context: context,
                image: File(pickedFile.path),
                onCompleted: onCompleted),
          ),
        );
      }
    }
  }
}
