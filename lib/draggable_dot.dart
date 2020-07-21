import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:interpolate/interpolate.dart';

class DraggableDot extends StatefulWidget {
  DraggableDot({this.size, this.alignment});
  final Size size;
  final Alignment alignment;
  @override
  _DraggableDotState createState() => _DraggableDotState();
}

class _DraggableDotState extends State<DraggableDot> {
  double top, left;
  Interpolate interpolate = Interpolate(
    inputRange: [10, 20, 30],
    outputRange: [1, 0, 1],
    extrapolate: Extrapolate.clamp,
  );

  @override
  void initState() {
    top = widget.alignment.y;
    left = widget.alignment.x;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(left, top),
            child: GestureDetector(
                onPanUpdate: (tapInfo) {
                  setState(() {
                    left += tapInfo.delta.dx / widget.size.width * 2;
                    top += tapInfo.delta.dy / widget.size.height * 2;
                    left = left < -1 ? -1 : left;
                    left = left > 1 ? 1 : left;
                    top = top < -1 ? -1 : top;
                    top = top > 1 ? 1 : top;
                  });
                },
                child: _buildDot()),
          ),
        ],
      ),
    );
  }

  _buildDot({double opacity = 1}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
          color: Colors.red.withOpacity(opacity),
          borderRadius: BorderRadius.circular(15)),
    );
  }
}
