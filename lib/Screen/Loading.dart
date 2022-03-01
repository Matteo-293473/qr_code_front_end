import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// usiamo un pacchetto dedicato per la creazione di una schermata di loading
import 'package:flutter_spinkit/flutter_spinkit.dart';


// classe semplice che ha il solo scopo di mostrare una schermata
// di loading
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

