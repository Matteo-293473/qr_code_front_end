import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String qrCode = 'unkown';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('images/logo.png')),
              Container(
                height: 75,
                child: Card(
                  color: Colors.white,
                  margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  child: ListTile(
                    leading: Icon(Icons.camera_alt, color: Colors.blue),
                    title: Text(
                      'Scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue,
                          fontFamily: 'sansPro',
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () => scanQRCode(),
                  ),
                ),
              ),
              /*FlatButton(
                  color: Colors.white,
                  onPressed: () {
                    //setState(() {
                    numeroStringa++;
                  }),
              Text(stringhe[numeroStringa])*/
            ],
          ),
        ),
      ),
    );
  }

  scanQRCode() {
    print("hello");
  }
}
