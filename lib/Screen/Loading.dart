import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Loading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.lightBlue,
        child: Center(
            child: SpinKitDualRing(
                color: Colors.white,
                size: 50.0
            )
        )
    );
  }
}

