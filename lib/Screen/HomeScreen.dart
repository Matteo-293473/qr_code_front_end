import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart'; // pack per ricavare identificativo
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:qr_code2/Screen/SetUp.dart';



class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();

  }
}

class _HomeScreenState extends State<HomeScreen> {


  String localHostString = "";
  String _content = "";
  String serverResponse = "";
  String qrInfo = "";
  String deviceId = "";
  bool connessione = false;
  String messaggio = "";





  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    const dueSec = Duration(seconds:5);
    //final localHost = Navigator.push(context,MaterialPageRoute(builder: (context) => SetUp()));
    //localHostString = localHost as String;

    Timer.periodic(dueSec, (Timer t) => checkConnessione());
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments;
    localHostString = args.toString();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        elevation: 0.1, // Check Platform if android
        // backgroundColor: const Color(0xFFF6F8FA),
        title: new Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          SizedBox(
              width: 60,
              child:
              CircleAvatar(backgroundColor : connessione == true ? Colors.green : Colors.red)),
            SizedBox(
              width: 280,
              child:
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                child: Text(
                  'Connection',
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                ),
              ),
            )
            ],
          )

          ),
      ),
      body: Container(
        color: Colors.lightBlue,
        margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
        child: ListView(
          children: <Widget>[
            Center(
              child: Container(
                //width: 260.0,
                height: 220.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(
                    new Radius.circular(16.0),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/ic_scan.png',
                    width: 110.0,
                    height: 110.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 4.0),
                width: double.infinity,
                //height: 80.0,
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(
                    new Radius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    messaggio,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            InkWell(
              // Qui avviene la chiamata al metodo _openQRScanner()
              onTap: () => LetturaQr(),
              child: new Center(
                child: Container(
                  margin: EdgeInsets.only(top: 30.0),
                  width: 300.0,
                  height: 150.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    borderRadius: new BorderRadius.all(
                      new Radius.circular(24.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'SCAN',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> checkConnessione() async {
    try {


      final result = await http.head(Uri.parse(_localhost()));


      print(result.statusCode);


      if (result.statusCode == 200 ||result.statusCode == 404 ) {
        setState(() {
          connessione =  true;
        });


      }
    } on SocketException catch (e) {
      print(e);
      setState(() {
          connessione = false;
          messaggio = "Connessione al server non riuscita ❌";
        });
    } on TimeoutException {
      throw HttpException("TIMEOUT");
    }  catch (error) {
      print(error);
    }
  }


  void LetturaQr() async{
      if(await connessione)
      {
        // queste istruzioni devono avvenire in ordine e quindi
        // usiamo il costrutto await
        await _openQRScanner();
        String deviceId = await _getId();
        await PostData(deviceId);
      }else {
        setState((){
          messaggio = "Connessione al server non riuscita ❌";
        });
      }

  }

  Future<void> PostData(String deviceId) async {
    // su http.post( SITO DOVE POSTIAMO I DATI, DATI)
    var risposta = await http.post(Uri.parse(_localhost()),
        body: {
          "id": deviceId, // id univoco del device
          "qrInfo": qrInfo, // contenuto del qr
          // orario del device viene inserito dal server
        });
    print(risposta.body);
    setState(() {
      messaggio = risposta.body;
    });

  }




  Future _openQRScanner() async {
    try {
      ScanResult qrScanResult = await BarcodeScanner.scan();
      String qrResult = qrScanResult.rawContent;
      setState(() {
        qrInfo = qrResult;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          _content = "Camera was denied";
        });
      } else {
        setState(() {
          _content = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        _content = "You pressed the back button before scanning anything";
        print(_content);
      });
    } catch (ex) {
      setState(() {
        _content = "Unknown Error $ex";
      });
    }


  }



  String _localhost() {
    if (Platform.isAndroid)
      return localHostString;
    //return 'http://10.0.2.2:3000';
    else // for iOS simulator
      return 'http://localhost:3000';
  }


  void showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    );

    _scaffoldKey.currentState!.showSnackBar(snackBar);
  }


  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }


}
