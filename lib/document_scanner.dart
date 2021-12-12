import 'dart:io';

import 'package:document_scanner/Utils.dart';
import 'package:document_scanner/edit_image_screen.dart';
import 'package:document_scanner/image_picker_modal.dart';
import 'package:document_scanner/platform_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<XFile> computePickFile(context, ImageSource imageSource) async {
  String permText = '';
  Permission permission;
  PermissionStatus permissionStatus;
  if (imageSource == ImageSource.gallery) {
    permText =
        'Fotoğraflara erişim izni kalıcı olarak reddedildiği için ayarlara giderek bu uygulamaya fotoğraflara erişim izni vermeniz gerekmektedir.';
    permission = Permission.photos;
    permissionStatus = await permission.status;
  } else {
    permText =
        'Kameraya erişim izni kalıcı olarak reddedildiği için ayarlara giderek bu uygulamaya kameraya erişim izni vermeniz gerekmektedir.';
    permission = Permission.camera;
    permissionStatus = await permission.status;
  }
  final picker = ImagePicker();
  if (permissionStatus.isGranted||permissionStatus.isLimited) {
    if (imageSource == ImageSource.gallery){
      Utils.showProgress(context);
    }
    final file =  await picker.pickImage(source: imageSource, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (imageSource == ImageSource.gallery) {
      Navigator.of(context).pop();
    }
    return file;
  } else {
    if (permissionStatus.isPermanentlyDenied) {
      showPlatformDialog(
          context: context,
          builder: (_) {
            return PlatformAlertDialog(
              title: Text('İzin Gerekli'),
              content: Text(permText),
              actions: <Widget>[
                PlatformDialogAction(
                  child: PlatformText('İptal'),
                  onPressed: () => Navigator.pop(context),
                ),
                PlatformDialogAction(
                    child: PlatformText('Ayarlara Git'),
                    onPressed: () => openAppSettings()),
              ],
            );
          });
    } else if (permissionStatus.isDenied) {
      final status = await Permission.photos.request();
      if (status.isGranted||status.isLimited) {
        if (imageSource == ImageSource.gallery) {
          Utils.showProgress(context);
        }
        final file =  await picker.pickImage(source: imageSource, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
        if (imageSource == ImageSource.gallery) {
          Navigator.of(context).pop();
        }
        return file;
      }
    }
    return null;
  }
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


  pickImage(ctx, {Function onCompleted, bool noEdit = false}) async {
    final pickedFile = await computePickFile(ctx, ImageSource.gallery);
    if (pickedFile?.path != null) {
      if (noEdit) {
        onCompleted(File(pickedFile.path));
      } else {
        await Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (context) => EditImageScreen(
                context: ctx,
                image: File(pickedFile.path),
                onCompleted: (d, s){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  onCompleted(d,s);
                }),
          ),
        );
      }
    }
  }

  takePhoto(context, {Function onCompleted, bool noEdit = false}) async {
    final pickedFile = await computePickFile(context, ImageSource.camera);
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
                onCompleted: (d, s){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  onCompleted(d,s);
                }),
          ),
        );
      }
    }
  }
}
