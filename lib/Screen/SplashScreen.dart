import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code2/Constant/Constant.dart';

// Schermata dedicata alla semplice animazione del logo iniziale
// viene mostrata e poi si passa subito alla schermata successiva, la SetUp.

// La divisione della dichiarazione in due classi permette di avere un widget
// immutabile con uno stato mutabile
class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();

}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, navigationPage);
  }

  // navigazione alla pagina di SET_UP
  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(SET_UP);
  }


  @override
  void initState() {
    super.initState();
    // usiamo la classe che permette le animazioni
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 2),
    );
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 30.0),
              )
            ],
          ),
          new Column(
            // posizione del logo
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                'assets/images/logo.png',
                width: animation.value * 300,
                height: animation.value * 300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
