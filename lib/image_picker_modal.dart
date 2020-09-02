import 'package:document_scanner/document_scanner.dart';
import 'package:flutter/material.dart';

class ImagePickerModal extends StatefulWidget {
  ImagePickerModal({this.onCompleted, this.context, this.noEdit = false});

  final Function onCompleted;
  final BuildContext context;
  final bool noEdit;
  @override
  _ImagePickerModalState createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal> {
  DocumentScanner _documentScanner = DocumentScanner();
  static Color greyColor = Color(0xff747474);
  TextStyle textStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: greyColor);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Belge Yükle",
                style: textStyle,
                textAlign: TextAlign.left,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    _documentScanner.pickImage(this.context,
                        onCompleted: widget.onCompleted, noEdit: widget.noEdit);
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.photo_library,
                        size: 48,
                        color: greyColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text("Galeri", style: textStyle),
                      )
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    _documentScanner.takePhoto(this.context,
                        onCompleted: widget.onCompleted, noEdit: widget.noEdit);
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: greyColor,
                      ),
                      Text("Kamera", style: textStyle)
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
