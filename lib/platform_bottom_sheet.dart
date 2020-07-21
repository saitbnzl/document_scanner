import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformBottomSheet {
  static showForIos(context,child) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => child);
  }

  static showForAndroid(context,child) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return child;
        });
  }
  static show(context, child){
    if(Theme.of(context).platform == TargetPlatform.iOS){
      showForIos(context, child);
    }else if(Theme.of(context).platform == TargetPlatform.android){
      showForAndroid(context, child);
    }
  }
}