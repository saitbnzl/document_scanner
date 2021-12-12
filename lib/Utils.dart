import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  static Future showDialog(context, child){
    if (Platform.isAndroid) {
      return showGeneralDialog(
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
    } else if (Platform.isIOS) {
      return showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return child;
          });
    }
  }

  static showProgress(ctx){
    Utils.showDialog(
        ctx,
        Platform.isAndroid
            ? AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: Container(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Lütfen bekleyiniz..."),
              )
            ],
          ),
        )
            : CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: Container(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Lütfen bekleyiniz..."),
              )
            ],
          ),
        ));
  }

}
