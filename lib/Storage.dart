import 'dart:async';
import 'package:path_provider/path_provider.dart'; // libreria per salvare i dati
import 'dart:io';

class Storage {

  Future<String> get localPath async{
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async{
    final path = await localPath;
    return File('$path/valori.txt');
  }

  Future<String> readData() async{
    try{
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    }catch (e){
      return "";
    }
  }

  Future<File> writeData(String data) async{
    final file = await localFile;
    return file.writeAsString("$data");
  }
}