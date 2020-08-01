import 'dart:io';
import 'dart:typed_data';
import 'package:document_scanner/document_scanner.dart';
import 'package:document_scanner/resizable_widget.dart';
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
  Size _size, screenSize;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _imageData = widget.image.readAsBytesSync();
        _image = image.decodeImage(_imageData);
        double ratio = _image.width / _image.height;
        screenSize = MediaQuery.of(context).size;
        _size = Size(screenSize.width * .8, ratio * screenSize.width * .8);
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
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  AppBar(
                    title: Text("Resmi Düzenle"),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
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
                        Positioned.fill(
                          child: Center(
                            child: ResizableWidget(
                              minHeight: 50,
                              minWidth: 50,
                              width: _size.width,
                              height: _size.height,
                              child: Container(
                                width: _size.width,
                                height: _size.height,
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
                  ),
                ],
              ),
            ),
          );
  }
}
