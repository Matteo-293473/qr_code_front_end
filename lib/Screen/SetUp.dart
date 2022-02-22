import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code2/Constant/Constant.dart';
import 'Loading.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code2/Screen/HomeScreen.dart';
import 'package:qr_code2/Storage.dart';

class SetUp extends StatefulWidget {
  final Storage storage;

  SetUp({Key? key,required this.storage}): super(key: key);

  @override
  State<SetUp> createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {

  final formKey = GlobalKey<FormState>();
  var _ipServer = TextEditingController();
  var _portServer = TextEditingController();
  bool loading = false;
  bool connessione = false;
  late String rispostaServer;
  late String prova;

  @override
  void initState() {
    super.initState();

    widget.storage.readData().then((String value) {
      if(value != ""){
        setState(() {
          List<String> list = value.split(' ');
          _ipServer.text = list[0];
          _portServer.text = list[1];
        });
      }
    });
  }

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
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(10.0),
          child: Form(
            key: formKey,
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                //SizedBox(height: height*0.05),
                TextFormField(
                  maxLength: 15,
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
                  validator: (value){
                    if(value!.isEmpty){
                      return "enter a valid ip number";
                    }
                  },
                ),
                TextFormField(
                    maxLength: 5,
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
                    validator: (value){
                      if(value!.isEmpty){
                          return "enter a valid port number";
                        }
                      }
                ),
                InkWell(
                  // Qui avviene la chiamata al metodo
                  onTap: () => formKey.currentState!.validate()? TestConnessione() : null,
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
          List<String> list = [_ipServer.text, _portServer.text];
          connessione =  true;
          loading = false;
          // andiamo alla schermata successiva
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacementNamed(HOME_SCREEN, arguments: localHost);
          });
          widget.storage.writeData(list[0] + ' ' + list[1]);


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

