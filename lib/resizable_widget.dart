import 'package:document_scanner/clip_overlay_painter.dart';
import 'package:flutter/material.dart';

class ResizableWidget extends StatefulWidget {
  ResizableWidget(
      {Key key,
      this.child,
      this.onChange,
      this.width,
      this.height,
      this.minHeight = 0,
      this.minWidth = 0})
      : super(key: key);
  final double height;
  final double width;
  final double minHeight, minWidth;
  final Widget child;
  final Function onChange;

  @override
  ResizableWidgetState createState() => ResizableWidgetState();
}

const ballDiameter = 48.0;

class ResizableWidgetState extends State<ResizableWidget> {
  double height, width;
  double top = 0;
  double left = 0;
  bool showHint = true;

  @override
  void initState() {
    height = widget.height;
    width = widget.width;
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showHint = false;
      });
    });
    super.initState();
  }

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
  }

  clampRectangle() {
    widget.onChange();
    setState(() {
      if (top < 0) {
        top = 0;
      } else if (top > widget.height - height) {
        top = widget.height - height;
      }
      if (left < 0) {
        left = 0;
      } else if (left > widget.width - width) {
        left = widget.width - width;
      }
      if (height > widget.height) {
        height = widget.height;
      }
      if (width > widget.width) {
        width = widget.width;
      }
      if (height < widget.minHeight) {
        height = widget.minHeight;
      }
      if (width < widget.minWidth) {
        width = widget.minWidth;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              painter: ClipOverlayPainter(
                  top: top,
                  left: left,
                  height: height,
                  width: width,
                  outerHeight: widget.height,
                  outerWidth: widget.width),
            ),
          ),
          // top left
          Positioned(
            top: top - ballDiameter / 2,
            left: left - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;
                var newHeight = height - 2 * mid;
                var newWidth = width - 2 * mid;
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top + mid;
                left = left + mid;
                clampRectangle();
              },
            ),
          ),
          // top middle
          Positioned(
            top: top - ballDiameter / 2,
            left: left + width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = height - dy;
                height = newHeight > 0 ? newHeight : 0;
                top = top + dy;
                clampRectangle();
              },
            ),
          ),
          // top right
          Positioned(
            top: top - ballDiameter / 2,
            left: left + width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (dx + (dy * -1)) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
                clampRectangle();
              },
            ),
          ),
          // center right
          Positioned(
            top: top + height / 2 - ballDiameter / 2,
            left: left + width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = width + dx;
                width = newWidth > 0 ? newWidth : 0;
                clampRectangle();
              },
            ),
          ),
          // bottom right
          Positioned(
            top: top + height - ballDiameter / 2,
            left: left + width - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;

                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
                clampRectangle();
              },
            ),
          ),
          // bottom center
          Positioned(
            top: top + height - ballDiameter / 2,
            left: left + width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newHeight = height + dy;

                height = newHeight > 0 ? newHeight : 0;
                clampRectangle();
              },
            ),
          ),
          // bottom left
          Positioned(
            top: top + height - ballDiameter / 2,
            left: left - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var mid = ((dx * -1) + dy) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;

                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
                clampRectangle();
              },
            ),
          ),
          //left center
          Positioned(
            top: top + height / 2 - ballDiameter / 2,
            left: left - ballDiameter / 2,
            child: ManipulatingBall(
              onDrag: (dx, dy) {
                var newWidth = width - dx;

                width = newWidth > 0 ? newWidth : 0;
                left = left + dx;
                clampRectangle();
              },
            ),
          ),
          // center center
          Positioned(
            top: top + height / 2 - ballDiameter / 2,
            left: left + width / 2 - ballDiameter / 2,
            child: ManipulatingBall(
              center: true,
              onDrag: (dx, dy) {
                top = top + dy;
                left = left + dx;
                clampRectangle();
              },
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: showHint ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: IgnorePointer(
                ignoring: !showHint,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showHint = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(.5),
                      alignment: Alignment.center,
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Resmi kırpmak için mavi noktaları hareket ettirerek resmin sınırlarını belirleyin.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Daha sonra aşağıdaki \"Kırp\" butonuna dokunun.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key key, this.onDrag, this.center = false});

  final Function onDrag;
  final bool center;
  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        alignment: Alignment.center,
        width: ballDiameter,
        height: ballDiameter,
        color: Colors.transparent,
        child: Container(
          width: ballDiameter - 24,
          height: ballDiameter - 24,
          child: widget.center
              ? Icon(
                  Icons.open_with,
                  size: ballDiameter - 24,
                  color: Colors.blue.withOpacity(1),
                )
              : null,
          decoration: BoxDecoration(
            color: widget.center
                ? Colors.transparent
                : Colors.blue.withOpacity(0.4),
            shape: widget.center ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
