import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart'; // pack per ricavare identificativo
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';


// schermata che è il cuore dell'applicazione.
// Una volta connessi al server si accede a questa schermata che dà la
// possibilità di scannerizzare il QR. L'utente cliccherà il tasto con la
// dicitura "SCAN", così da aprire la fotocamera. Una volta effettutata la
// scansione, verranno presi i dati quali il contenuto del qr e un id univoco del
// dispositivo e verranno inviati al server sopracitato che restituirà una risposta.
// Questa verrà mostrata nel box sopra il tasto "SCAN".
// E' presente anche un led in alto a sinistra dedicato allo stato della
// connessione, che viene verificata ogni 5 secondi attraverso una funzione
// periodica.

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
  bool connessione = true;
  String messaggio = "";


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();

    // funzione per il controllo della connessione che viene eseguita
    // ogni 5 secondi
    Timer.periodic(Duration(seconds:5), (Timer t) => checkConnessione());
  }

  @override
  Widget build(BuildContext context) {

    // recuperiamo la stringa localhost dalla schermata precedente SET_UP
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
              // led di stato della connessione
              CircleAvatar(backgroundColor : connessione == true ? Colors.green : Colors.red)),
            SizedBox(
              width: 250,
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
              // Qui avviene la chiamata al metodo per leggere il qr
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
      // queste istruzioni devono avvenire in ordine e quindi
      // usiamo il costrutto await

      // si verifica prima la connessione
      if(await connessione)
      {

        // si apre lo scanner
        await _openQRScanner();
        // prendiamo il codice del device
        String deviceId = await _getId();
        // inviamo tutti i dati al server attraverso la POST
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
      // messaggio dal server
      messaggio = risposta.body;
    });

  }


  // funzione che si occupa di scannerizzare il QR usando la libreria apposita
  Future _openQRScanner() async {
    try {
      ScanResult qrScanResult = await BarcodeScanner.scan();
      String qrResult = qrScanResult.rawContent;
      setState(() {
        qrInfo = qrResult; // i dati del QR sono inseriti in qrInfo
      });
      // controllo dei possibili errori
    } on PlatformException catch (ex) {
      // se siamo qui significa che non è stata concessa l'autorizzazione
      // di accedere alla camera
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
      // se siamo qui significa che l'utente è tornato indietro e non ha
      // scannerizzato nulla
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
