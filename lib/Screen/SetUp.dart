import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Loading.dart';
import 'package:http/http.dart' as http;

import 'package:qr_code2/Screen/HomeScreen.dart';

class SetUp extends StatefulWidget {


  @override
  State<SetUp> createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {
  var _ipServer = TextEditingController();
  var _portServer = TextEditingController();
  bool loading = false;
  bool connessione = false;
  late String rispostaServer;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold( // se loading è false allora ritorna lo scaffold
        backgroundColor: Colors.lightBlue,
        appBar: AppBar(
          title: const Text('Set up connection'),
        ),
        body: Container(
            child: ListView(
                children: <Widget>[
                  Center(
                    child: Container(
                        padding: EdgeInsets.all(20.0),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          style: TextStyle(color: Colors.white, fontSize: 30),
                          controller: _ipServer,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlueAccent),
                              ),
                              hintText: 'Server IP',
                              hintStyle: TextStyle(
                                  color: Colors.lightBlueAccent),
                              suffixIcon: IconButton(
                                onPressed: _ipServer.clear,
                                icon: Icon(Icons.clear),
                              )
                          ),
                          keyboardType: TextInputType.number,
                        )
                    ),
                  ),
                  Center(

                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          style: TextStyle(color: Colors.white, fontSize: 30),
                          controller: _portServer,
                          decoration: InputDecoration(

                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.lightBlueAccent),
                              ),
                              hintText: 'Server port',
                              hintStyle: TextStyle(
                                  color: Colors.lightBlueAccent),
                              suffixIcon: IconButton(
                                onPressed: _portServer.clear,
                                icon: Icon(Icons.clear),
                              )
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      )
                  ),
                  InkWell(
                    // Qui avviene la chiamata al metodo
                    onTap: () => TestConnessione(),
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
                            'Connect',
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
                ]
            )
        )
    );
  }


  Future<void> checkConnessione() async {
    try {
      // proviamo a vedere se c'è connessione nel server cercato
      var localHost = 'http://' + _ipServer.text + ':' + _portServer.text;
      final result = await http.head(Uri.parse(localHost));
      if(_ipServer.text == '')
        throw SocketException;
      if (result.statusCode == 200 || result.statusCode == 404 ) {
        setState(() {
          connessione =  true;
          loading = false;
          // andiamo alla schermata successiva
          Future.delayed(Duration.zero, () {
            Navigator.pop(context,localHost);
          });

          //Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()));
        });
      }
    } on SocketException catch (e) {
      print(e);
      setState(() {
        connessione = false;
        loading = false;
        // far vedere la stessa schermata
        print("far vedere la stessa schermata");
        rispostaServer = "Connessione al server non riuscita ❌";
      });
    } on TimeoutException {
      throw HttpException("TIMEOUT");
    }  catch (error) {
      print(error);
    }
  }


  void TestConnessione() async {
    setState(() {
      loading = true;
      checkConnessione();
    });

  }
}

