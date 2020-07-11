import 'package:document_scanner/Utils.dart';
import 'package:document_scanner/pick_image_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocumentScanner {

  show(BuildContext context) {
    Utils.showDialog(context, PickImageScreen());
  }
}
