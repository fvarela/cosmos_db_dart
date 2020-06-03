# cosmos_db_dart
Dart class for handling connection to Azure Cosmos DB using Dart

## Usage  
**Import the class**  
`import 'package:{your_project}/cosmos_db_dart/cosmos.dart';`  

**Instantiate the class with your Cosmos Db Master Key**  
`Cosmos cosmos = Cosmos( documentDBMasterKey:'{your_cosmos_db_master_key}');`  

**Query Cosmos Db by calling queryCosmos method (GET, PUT, POST or DEL). Pass 'url', 'method', and an optional 'body' as parameters**  
```
() async {
      var data = await cosmos.queryCosmos(
            url: 'https:{your_base_url}.documents.azure.com:443/dbs', method: 'GET');
      print(data);
      );
}
```
