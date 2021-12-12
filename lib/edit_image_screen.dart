import 'dart:io';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:document_scanner/copy_rotate.dart';
import 'package:document_scanner/document_scanner.dart';
import 'package:document_scanner/flip.dart';
import 'package:document_scanner/resizable_widget.dart';
import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as imageLib;
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';

const encodingQuality = 85;

Future<imageLib.Image> processImage(imageLib.Image _image) async {
  imageLib.grayscale(_image);
  imageLib.contrast(_image, 125);
  return _image;
}

Future<imageLib.Image> clearImage(File _imageFile) async {
  Uint8List imageData = await _imageFile.readAsBytes();
  return imageLib.decodeJpg(imageData);
}

Uint8List computeEncodeJpg(Map map) {
  return imageLib.encodeJpg(map["image"],
      quality: map.containsKey("quality") ? map["quality"] : encodingQuality);
}

imageLib.Image computeDecodeJpg(Uint8List _data) {
  return imageLib.decodeJpg(_data);
}

class EditImageScreen extends StatefulWidget {
  EditImageScreen({this.image, this.onCompleted, this.context});
  final Function onCompleted;
  final File image;
  final BuildContext context;
  @override
  _EditImageScreenState createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen>
    with WidgetsBindingObserver {
  DocumentScanner documentScanner = DocumentScanner();
  imageLib.Image _image;
  Uint8List _imageData;
  GlobalKey imageKey = GlobalKey();
  Size screenSize;
  GlobalKey<ResizableWidgetState> resizeState = GlobalKey();
  Size fittedSize;
  bool inProgress = true;
  bool effectsApplied = false;
  bool shouldCrop = false;
  CancelableOperation initOp;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      initOp = CancelableOperation.fromFuture(
        init(),
        onCancel: () => {debugPrint('onCancel')},
      );
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    initOp.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _imageData = null;
    _image = null;
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    AlertDialog alert = AlertDialog(
      title: Text("Uyarı"),
      content: Text(
          "Düşük bellek tespit edildi. İşleminiz devam edemezse uygulamayı kapatıp yeniden açmayı deneyin."),
      actions: [
        FlatButton(
          child: Text("Tamam"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ],
    );
    CupertinoAlertDialog cupertinoAlertDialog = CupertinoAlertDialog(
      title: Text("Uyarı"),
      content: Text("Düşük bellek tespit edildi. İşleminiz devam edemezse uygulamayı kapatıp yeniden açmayı deneyin."),
      actions: [
        CupertinoButton(
          child: Text("Tamam"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ],
    );
    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return alert;
          });
    } else {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return cupertinoAlertDialog;
          });
    }
  }

  bakeOrientation(int orientation, imageLib.Image _image) {
    switch (orientation) {
      case 2:
        return flipHorizontal(_image);
      case 3:
        return copyRotate(_image, 180);
      case 4:
        return flipHorizontal(copyRotate(_image, 180));
      case 5:
        return flipHorizontal(copyRotate(_image, 90));
      case 6:
        return copyRotate(_image, 90);
      case 7:
        return flipHorizontal(copyRotate(_image, -90));
      case 8:
        return copyRotate(_image, -90);
      default:
        return _image;
    }
  }

  init({File file}) async {
    if (!inProgress) {
      setState(() {
        inProgress = true;
        shouldCrop = false;
      });
    }
    File preferredFile = file == null ? widget.image : file;
    _imageData = await preferredFile.readAsBytes();
    preferredFile=null;
    _image = imageLib.decodeImage(_imageData);
 /*   Map<String, IfdTag> exif = await readExifFromBytes(_imageData);
    final orientationVal = exif == null
        ? null
        : exif.values
            .firstWhere((element) => element.tag == 274, orElse: () => null);
    int orientation = orientationVal?.values?.first;
    if (orientation != null && orientation != 1) {
      _image = bakeOrientation(orientation, _image);
    }*/

    //_image = await compute(processImage, _image);
    //_imageData = await compute(computeEncodeJpg, {"image": _image});
    print("size: ${(_imageData.lengthInBytes / 1000000)}");
    bool isSizeOverLimit = ((_imageData.lengthInBytes / 1000000) > 2.99);
    if (isSizeOverLimit) {
      double scaleFactor = 3 / (_imageData.lengthInBytes / 1000000);
      if (scaleFactor < 0.3) {
        scaleFactor = 0.3;
      }
      _imageData = await compute(computeEncodeJpg, {
        "image": _image,
        "quality": (encodingQuality * scaleFactor).toInt()
      });
    }

    screenSize = MediaQuery.of(this.context).size;
    fittedSize = applyBoxFit(
            BoxFit.contain,
            Size(_image.width.toDouble(), _image.height.toDouble()),
            Size(screenSize.width, screenSize.height * .8))
        .destination;

    if (mounted) {
      setState(() {
        inProgress = false;
      });
    }
  }

  applyEffects() async {
    ResizableWidgetState resizableWidgetState = resizeState.currentState;
    setState(() {
      inProgress = true;
    });

    _image = await compute(processImage, _image);
    _imageData = await compute(computeEncodeJpg, {"image": _image});

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

    _image = imageLib.decodeImage(widget.image.readAsBytesSync());
    Map<String, IfdTag> exif =
        await readExifFromBytes(await widget.image.readAsBytes());
    final orientationVal = exif == null
        ? null
        : exif.values
            .firstWhere((element) => element.tag == 274, orElse: () => null);
    int orientation = orientationVal?.values?.first;
    if (orientation != null && orientation != 1) {
      _image = bakeOrientation(orientation, _image);
    }

    _imageData = await compute(computeEncodeJpg, {"image": _image});
    print("size: ${(_imageData.lengthInBytes / 1000000)}");
    bool isSizeOverLimit = ((_imageData.lengthInBytes / 1000000) > 2.99);
    if (isSizeOverLimit) {
      double scaleFactor = 3 / (_imageData.lengthInBytes / 1000000);
      if (scaleFactor < 0.3) {
        scaleFactor = 0.3;
      }
      _imageData = await compute(computeEncodeJpg, {
        "image": _image,
        "quality": (encodingQuality * scaleFactor).toInt()
      });
    }

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

  crop() async {
    ResizableWidgetState resizableWidgetState = resizeState.currentState;
    final scale = _image.width / fittedSize.width;
    _image = imageLib.copyCrop(
        _image,
        (resizableWidgetState.left * scale).toInt(),
        (resizableWidgetState.top * scale).toInt(),
        (resizableWidgetState.width * scale).toInt(),
        (resizableWidgetState.height * scale).toInt());

/*    Map<String, IfdTag> data =
        await readExifFromBytes(await widget.image.readAsBytes());
    final orientation = data.values
        .firstWhere((element) => element.tag == 274, orElse: () => null);
    if (orientation?.values?.first != null) {
      _image = bakeOrientation(orientation.values[0], _image);
    }*/

    _imageData = imageLib.encodeJpg(_image, quality: encodingQuality);

    resizableWidgetState.top = 0;
    resizableWidgetState.left = 0;
    fittedSize = applyBoxFit(
            BoxFit.contain,
            Size(resizableWidgetState.width, resizableWidgetState.height),
            Size(screenSize.width, screenSize.height * .8))
        .destination;
    resizableWidgetState.width = fittedSize.width;
    resizableWidgetState.height = fittedSize.height;
    setState(() {
      shouldCrop = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Platform.isIOS
                  ? CupertinoNavigationBar(
                      middle: Text("Resmi Düzenle"),
                    )
                  : AppBar(
                      title: Text("Resmi Düzenle"),
                    ),
            ),
            inProgress
                ? Expanded(
                    child: Center(
                        child: Container(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ))),
                  )
                : Expanded(
                    child: Stack(
                      fit: StackFit.loose,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: screenSize.width,
                            height: screenSize.height * .8,
                            child: Image.memory(
                              _imageData,
                              key: imageKey,
                              width: fittedSize.width,
                              height: fittedSize.height,
                              cacheWidth: fittedSize.width.toInt(),
                              cacheHeight: fittedSize.height.toInt(),
                              filterQuality: FilterQuality.low,
                              scale: 1,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Center(
                          child: ResizableWidget(
                            key: resizeState,
                            minHeight: 50,
                            minWidth: 50,
                            width: fittedSize.width,
                            height: fittedSize.height,
                            onChange: () {
                              setState(() {
                                shouldCrop = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
              color: Colors.blueGrey.withOpacity(.2),
              padding: EdgeInsets.only(top: 4),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (!inProgress) {
                            if (Platform.isAndroid) {
                              documentScanner.showMaterialPopup(context,
                                  onCompleted: (File file) {
                                init(file: file);
                              }, noEdit: true);
                            } else if (Platform.isIOS) {
                              documentScanner.showCupertinoPopup(context,
                                  onCompleted: (File file) {
                                init(file: file);
                              }, noEdit: true);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                size: 16,
                                color: Colors.white,
                              ),
                              Container(
                                width: 1,
                              ),
                              AutoSizeText(
                                "Yeni Resim",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (!inProgress) {
                            if (effectsApplied) {
                              clear();
                            } else {
                              applyEffects();
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                effectsApplied ? Icons.restore : Icons.brush,
                                size: 16,
                                color: Colors.white,
                              ),
                              Container(
                                width: 1,
                              ),
                              AutoSizeText(
                                effectsApplied
                                    ? "Orjinale Dön"
                                    : "Belgeyi Tara",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (!inProgress) {
                            if (shouldCrop) {
                              crop();
                            } else {
                              if ((_imageData.lengthInBytes / 1000000) > 2.99) {
                                AlertDialog alert = AlertDialog(
                                  title: Text("Hata"),
                                  content: Text(
                                      "Dosya boyutu en fazla 3MB olmalıdır."),
                                  actions: [
                                    FlatButton(
                                      child: Text("Tamam"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                                CupertinoAlertDialog cupertinoAlertDialog =
                                    CupertinoAlertDialog(
                                  title: Text("Hata"),
                                  content: Text(
                                      "Dosya boyutu en fazla 3MB olmalıdır."),
                                  actions: [
                                    CupertinoButton(
                                      child: Text("Tamam"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                                if (Platform.isAndroid) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return alert;
                                      });
                                } else {
                                  showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return cupertinoAlertDialog;
                                      });
                                }
                              } else {
                                widget.onCompleted(_imageData, fittedSize);
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.done, size: 16, color: Colors.white),
                              Container(
                                width: 1,
                              ),
                              AutoSizeText(
                                shouldCrop ? "Kırp" : "Tamam",
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
