import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:crypto/crypto.dart';
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
                (resourceId ?? '') + '\n' +
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

  Map<String, String> headers = {
    'Accept': 'application/json',
    'x-ms-version': '2016-07-11',
    'Authorization': auth,
    'x-ms-date': utcString,
    'x-ms-documentdb-isquery' : 'true',
    'Content-Type' : 'application/query+json',
    'x-ms-documentdb-query-enablecrosspartition' : 'true',
  };
  
  Future<String> readResponse(HttpClientResponse response) {
  final completer = Completer<String>();
  final contents = StringBuffer();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));
  return completer.future;
}

  HttpClientRequest request;
  HttpClient httpClient = new HttpClient();
  if (method=='GET'){
    request = await httpClient.getUrl(Uri.parse(url));
  }
  else if(method=='POST'){
    request = await httpClient.postUrl(Uri.parse(url));
  }
  else if(method=='PUT'){
    request = await httpClient.putUrl(Uri.parse(url));
  }
  else if(method=='DEL'){
    request = await httpClient.deleteUrl(Uri.parse(url));
  }
    headers.forEach((key, value) {
      request.headers.set(key,value);
    });

    if(body != null) {
      request.add(utf8.encode(json.encode(body)));
    }

    HttpClientResponse aresponse = await request.close();
    httpClient.close();
  String aresponseString = await readResponse(aresponse);
  print('stop');
  
  return jsonDecode(aresponseString);

  }
}

