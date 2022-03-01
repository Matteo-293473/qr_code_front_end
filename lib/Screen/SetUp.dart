import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code2/Constant/Constant.dart';
import 'Loading.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code2/Storage.dart';

// Questa schermata è dedicata all'impostazione della connessione.
// Si presenta all'utente un'interfaccia composta da due textbox le quali
// dovranno essere popolate dall'indirizzo e porta del server in cui gira node.
// Per facilitare l'uso dell'applicazione, una volta che si stabilisce
// la connessione, viene salvato il valore di IP e porta all'interno di un file,
// così che, ad un nuovo avvio, non ci sarà più bisogno di inserire i dati
// nei rispettivi campi.
// Le textbox inoltre sono dotate di controlli degli input attraverso il RegExp.
// Una volta inseriti i valori corretti si continua cliccando un tasto "CONNECT",
// che, mostrerà l'animazione di caricamento e verificherà che ci sia il server
// presso quella socket IP:Porta.
// Se tutto va a buon fine si passa alla schermata HomeScreen.dart.

class SetUp extends StatefulWidget {
  final Storage storage;

  // è richiesto un parametro storage (all'interno di un file)
  // che contiene i valori IP+PORTA che hanno funzionato nelle
  // sessioni precedenti.
  SetUp({Key? key,required this.storage}): super(key: key);

  @override
  State<SetUp> createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {

  final formKey = GlobalKey<FormState>();

  // variabili che prendono i valori dei campi
  var _ipServer = TextEditingController();
  var _portServer = TextEditingController();

  // inizialmente non c'è caricamento e connessione
  bool loading = false;
  bool connessione = false;

  late String rispostaServer;
  late String prova;

  @override
  void initState() {
    super.initState();

    // Cerchiamo se esiste il file contenente i valori della socket.
    // Se non esiste è perché probabilmente stiamo avviando l'applicazione
    // per la prima volta
    widget.storage.readData().then((String value) {
      if(value != ""){
        // Il file di testo non è vuoto, allora ricarichiamo il widget con i
        // valori trovati
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

    // quando settiamo lo stato con setState{}, viene ricaricato il widget
    // e viene valutato se loading è True o False. Nel qual caso fosse True,
    // viene creata la Loading(), classe che si trova in Loading.dart
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
              // dichiariamo dove il child deve trovarsi
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // usiamo TextFormField invece di TextField perché
                // è un oggetto più avanzato che permette anche la convalida
                // dell'input.
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
                    // se i valori inseriti sono vuoti o non rispettano l'espressione RegExp
                    if(value!.isEmpty ||
                        !RegExp(r'^((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])(\.(?!$)|$)){4}$')
                            .hasMatch(value)){
                      return "Enter a valid IP number";
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
                      // se i valori inseriti sono vuoti o non rispettano l'espressione RegExp
                      if(value!.isEmpty ||
                          !RegExp(r'^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$')
                              .hasMatch(value)){
                          return "Enter a valid port number";
                        }
                      }
                ),
                InkWell(
                  // Qui avviene la chiamata al metodo

                  // Se in questo stato del widget i valori inseriti nelle textbox sono validi
                  // allora viene eseguito TestConnessione()
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
                          'CONNECT',
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



  // si usa Future<void> invece di void perché così si può usare anche il costrutto
  // await davanti alla chiamata di funzione.
  Future<void> checkConnessione() async {
    try {
      // proviamo a vedere se c'è un server in ascolto nella destinazione inserita
      var localHost = 'http://' + _ipServer.text + ':' + _portServer.text;
      // il limite di attesa al server è impostato manualmente => 5 secondi
      final result = await http.head(Uri.parse(localHost)).timeout(Duration(seconds: 5));
      if (result.statusCode == 200 || result.statusCode == 404 ) {
        setState(() {
          // inserisco i valori che hanno funzionato in una lista
          List<String> list = [_ipServer.text, _portServer.text];
          connessione =  true;
          loading = false;
          // andiamo alla schermata successiva
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacementNamed(HOME_SCREEN, arguments: localHost);
          });
          // scrivo i valori della lista su file (salvataggio)
          widget.storage.writeData(list[0] + ' ' + list[1]);
        });

      }
    } catch (e) {
      print(e);
      // se siamo qui significa che la connessione non si è stabilita
      setState(() {
        connessione = false;
        loading = false;

        // rimaniamo su questa schermata
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No server found, check IP and Port'),
              backgroundColor: Colors.red),
        );

        rispostaServer = "Connessione al server non riuscita ❌";
      });
    }
  }


  void TestConnessione() async {
    setState(() {
      // viene aggiornato lo stato con loading = true quindi
      // verrà richiamata la schermata di caricamento
      loading = true;
      checkConnessione();
    });

  }
}

