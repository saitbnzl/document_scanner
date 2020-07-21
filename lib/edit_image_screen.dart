import 'dart:io';
import 'dart:typed_data';
import 'package:document_scanner/document_scanner.dart';
import 'package:document_scanner/draggable_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  GlobalKey imageKey = GlobalKey();
  Size _size;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _imageData = widget.image.readAsBytesSync();
        _image = image.decodeImage(_imageData);
        double ratio = _image.width / _image.height;
        Size screenSize = MediaQuery.of(context).size;
        _size = Size(screenSize.width, ratio * screenSize.width);
        image.grayscale(_image);
        image.contrast(_image, 125);
        _imageData = image.encodeJpg(_image);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _size == null
        ? Container()
        : WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Column(
              children: <Widget>[
                AppBar(
                  title: Text("Resmi Düzenle"),
                ),
                Center(
                    child: Stack(
                  children: <Widget>[
                    Container(
                      width: _size.width,
                      height: _size.height,
                      child: Image.memory(
                        _imageData,
                        key: imageKey,
                        height: _image.height.toDouble(),
                        width: _image.width.toDouble(),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    DraggableDot(
                      size: _size,
                      alignment: Alignment.topLeft,
                    ),
                    DraggableDot(size: _size, alignment: Alignment.topRight),
                    DraggableDot(
                      size: _size,
                      alignment: Alignment.bottomRight,
                    ),
                    DraggableDot(
                      size: _size,
                      alignment: Alignment.bottomLeft,
                    ),
                  ],
                )),
              ],
            ),
          );
  }

  _buildDot() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(15)),
    );
  }
}
