import 'dart:io';
import 'dart:typed_data';
import 'package:document_scanner/document_scanner.dart';
import 'package:document_scanner/resizable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as imageLib;
import 'package:flutter/foundation.dart';

Future<imageLib.Image> processImage(File _imageFile) async {
  Uint8List imageData = await _imageFile.readAsBytes();
  imageLib.Image _image = imageLib.decodeImage(imageData);
  imageLib.grayscale(_image);
  imageLib.contrast(_image, 125);
  return _image;
}

Future<imageLib.Image> clearImage(File _imageFile) async {
  Uint8List imageData = await _imageFile.readAsBytes();
  imageLib.Image _image = imageLib.decodeImage(imageData);
  return _image;
}

Uint8List computeEncodeJpg(imageLib.Image image) {
  Uint8List data = imageLib.encodeJpg(image);
  return data;
}

class EditImageScreen extends StatefulWidget {
  EditImageScreen({this.image});
  final File image;
  @override
  _EditImageScreenState createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen> {
  DocumentScanner documentScanner = DocumentScanner();
  imageLib.Image _image;
  Uint8List _imageData;
  GlobalKey imageKey = GlobalKey();
  Size screenSize;
  GlobalKey<ResizableWidgetState> resizeState = GlobalKey();
  Size fittedSize;
  bool inProgress = true;
  bool effectsApplied = true;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      init();
    });
    super.initState();
  }

  init() async {
    _image = await compute(processImage, widget.image);
    _imageData = await compute(computeEncodeJpg, _image);
    screenSize = MediaQuery.of(context).size;
    fittedSize = applyBoxFit(
            BoxFit.contain,
            Size(_image.width.toDouble(), _image.height.toDouble()),
            Size(screenSize.width, screenSize.height * .8))
        .destination;
    setState(() {
      inProgress = false;
    });
  }

  applyEffects() async {
    ResizableWidgetState resizableWidgetState = resizeState.currentState;
    setState(() {
      inProgress = true;
    });
    _image = await compute(processImage, widget.image);
    _imageData = await compute(computeEncodeJpg, _image);
    fittedSize = applyBoxFit(
        BoxFit.contain,
        Size(_image.width.toDouble(), _image.height.toDouble()),
        Size(screenSize.width, screenSize.height * .8))
        .destination;
    resizableWidgetState.top = 0;
    resizableWidgetState.left = 0;
    resizableWidgetState.width = fittedSize.width;
    resizableWidgetState.height = fittedSize.height;
    setState(() {
      inProgress = false;
      effectsApplied = true;
    });
  }

  clear() async {
    ResizableWidgetState resizableWidgetState = resizeState.currentState;
    setState(() {
      inProgress = true;
    });
    _image = await compute(clearImage, widget.image);
    _imageData = await compute(computeEncodeJpg, _image);
    fittedSize = applyBoxFit(
            BoxFit.contain,
            Size(_image.width.toDouble(), _image.height.toDouble()),
            Size(screenSize.width, screenSize.height * .8))
        .destination;
    resizableWidgetState.top = 0;
    resizableWidgetState.left = 0;
    resizableWidgetState.width = fittedSize.width;
    resizableWidgetState.height = fittedSize.height;
    setState(() {
      inProgress = false;
      effectsApplied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return inProgress
        ? Center(
            child: Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                )))
        : WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AppBar(
                    title: Text("Resmi Düzenle"),
                  ),
                  Expanded(
                    child: Stack(
                      fit: StackFit.loose,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: screenSize.width,
                          height: screenSize.height * .8,
                          child: Image.memory(
                            _imageData,
                            key: imageKey,
                            height: _image.height.toDouble(),
                            width: _image.width.toDouble(),
                            fit: BoxFit.contain,
                          ),
                        ),
                        ResizableWidget(
                          key: resizeState,
                          minHeight: 50,
                          minWidth: 50,
                          width: fittedSize.width,
                          height: fittedSize.height,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey.withOpacity(.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            ResizableWidgetState resizableWidgetState =
                                resizeState.currentState;
                            setState(() {
                              final scale = _image.width / fittedSize.width;
                              _image = imageLib.copyCrop(
                                  _image,
                                  (resizableWidgetState.left * scale).toInt(),
                                  (resizableWidgetState.top * scale).toInt(),
                                  (resizableWidgetState.width * scale).toInt(),
                                  (resizableWidgetState.height * scale).toInt());

                              _imageData = imageLib.encodeJpg(_image);

                              resizableWidgetState.top = 0;
                              resizableWidgetState.left = 0;
                              fittedSize = applyBoxFit(
                                      BoxFit.contain,
                                      Size(resizableWidgetState.width,
                                          resizableWidgetState.height),
                                      Size(screenSize.width,
                                          screenSize.height * .8))
                                  .destination;
                              resizableWidgetState.width = fittedSize.width;
                              resizableWidgetState.height = fittedSize.height;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            width: 96,
                            alignment: Alignment.center,
                            color: Colors.grey.withOpacity(.5),
                            child: Text(
                              "Crop",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            if (effectsApplied){
                              clear();
                            }else{
                              applyEffects();
                            }
                          },
                          child: Container(
                            width: 96,
                            padding: EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            color: Colors.grey.withOpacity(.5),
                            child: Text(
                              effectsApplied?"Clear All":"Scan",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
