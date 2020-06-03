import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:hex/hex.dart';


class Cosmos{
  String documentDBMasterKey;

  Cosmos({this.documentDBMasterKey});

 Future queryCosmos({url, method, body}) async{
    String auth;
    String documentDBMasterKey = this.documentDBMasterKey;
    print("mastKey: $documentDBMasterKey");

    method = method.trim(); //GET, POST, PUT or DEL
    url = url.trim();
    String utcString = HttpDate.format(DateTime.now());
    
    print('RFC1123time: $utcString');
    print('request url = ' + url);

    String strippedurl =
        url.replaceAllMapped(RegExp(r'^https?://[^/]+/'), (match) {
      return '/';
    });

    print('stripped Url: $strippedurl');


    List strippedparts = strippedurl.split('/');
    int truestrippedcount = strippedparts.length - 1;
    print('$truestrippedcount');

  String resourceId;
  String resType;
  
    if (truestrippedcount % 2 != 0){
      print('odd');
      resType = strippedparts[truestrippedcount];
      print('$resType');

      if (truestrippedcount > 1){
        int  lastPart = strippedurl.lastIndexOf('/');
        resourceId = strippedurl.substring(1, lastPart);
        print('ResourceId: ' + resourceId); 
      }

    }
    else{
      print('even');
      resType = strippedparts[truestrippedcount -1];
      print('resType: $resType');
      strippedurl = strippedurl.substring(1);
      print('strippedurl $strippedurl');
      resourceId = strippedurl;
      print('ResourceId: ' + resourceId);
    }

  String verb = method.toLowerCase();
  String date = utcString.toLowerCase();
  
  Base64Codec base64 = const Base64Codec(); 
  var key = base64.decode(documentDBMasterKey); //Base64Bits --> BITS
  print('key = ${HEX.encode(key)}');
  print('masterKey = $documentDBMasterKey');

  String text = (verb ?? '').toLowerCase() + '\n' + 
                (resType ?? '').toLowerCase() + '\n' +
                (resourceId ?? '').toLowerCase() + '\n' +
                (date ?? '').toLowerCase() + '\n' +
                '' + '\n';

  print('text: $text');

  var hmacSha256 = Hmac(sha256, key);
  List<int> utf8Text = utf8.encode(text);
  var hashSignature = hmacSha256.convert(utf8Text);
  String base64Bits = base64.encode(hashSignature.bytes);


//Format our authentication token and URI encode it.
var masterToken = "master";
var tokenVersion = "1.0";
auth = Uri.encodeComponent('type=' + masterToken + '&ver=' + tokenVersion + '&sig=' + base64Bits);
print('auth= $auth');

  final headers = {
    'Accept': 'application/json',
    'x-ms-version': '2016-07-11',
    'Authorization': auth,
    'x-ms-date': utcString
  };
  
  var response;
  if (method=='GET'){
    response = await http.get(url, headers: headers);
  }
  else if (method=='POST'){
    response = await http.post(url, headers: headers, body: body);
  }
  else if (method=='PUT'){
    response = await http.put(url, headers: headers, body: body);
  }
  else if (method=='DEL'){
    response = await http.delete(url, headers: headers);
  }
  String data = response.body;
  return data;
  }
}

