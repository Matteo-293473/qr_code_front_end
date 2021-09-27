// @dart=2.9
import 'package:flutter/material.dart';
import 'package:qr_code2/constant/Constant.dart';
import 'package:qr_code2/screen/HomeScreen.dart';
import 'package:qr_code2/screen/SplashScreen.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        title: 'QR Scanner',
        routes: <String, WidgetBuilder>{
          HOME_SCREEN: (BuildContext context) => HomeScreen(),
        },
        home: SplashScreen(),
      ),
    );
