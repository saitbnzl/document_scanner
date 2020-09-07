import 'dart:io';

import 'package:document_scanner/Utils.dart';
import 'package:document_scanner/edit_image_screen.dart';
import 'package:document_scanner/image_picker_modal.dart';
import 'package:document_scanner/platform_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<PickedFile> computePickFile(ImageSource imageSource) async {
  final picker = ImagePicker();
  final pickedFile = await picker.getImage(
      source: imageSource, imageQuality: 80, maxWidth: 3840, maxHeight: 3840);
  return pickedFile;
}

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
    Utils.showDialog(
        context,
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: Container(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Lütfen bekleyiniz..."),
              )
            ],
          ),
        ));
    final pickedFile = await computePickFile(ImageSource.gallery);
    Navigator.of(context).pop();
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
    final pickedFile = await computePickFile(ImageSource.camera);
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
