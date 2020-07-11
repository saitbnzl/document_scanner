import 'package:flutter/material.dart';

class Utils{
  static showDialog(context,child){
    showGeneralDialog(
      context: context,
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget _child) {
        final height = MediaQuery.of(context).size.height;
        return Transform.translate(
            offset: Offset(0, -animation.value * height + height),
            child: _child);
      },
      barrierColor: Colors.black12.withOpacity(0.6), // background color
      barrierDismissible:
      false, // should dialog be dismissed when tapped outside
      barrierLabel: "Dialog", // label for barrier
      transitionDuration: Duration(
          milliseconds:
          400), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return child;
      },
    );
  }
}