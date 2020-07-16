# cosmos_db_dart
Dart class for handling connection to Azure Cosmos DB

## Usage  
**Import the class**  
`import 'package:{your_project}/cosmos_db_dart/cosmos.dart';`  

**Instantiate the class with your Cosmos Db Master Key**  
`Cosmos cosmos = Cosmos( documentDBMasterKey:'{your_cosmos_db_master_key}');`  

**Query Cosmos Db by calling queryCosmos method (GET, PUT, POST or DEL). Pass 'url', 'method', and an optional 'body' as parameters**  
```
// GET Example
    () async {
       Map<String, dynamic> get_dbs = await cosmos.queryCosmos(
         url: 'https://{your_base_url}.documents.azure.com:443/dbs', method: 'GET');
       print(get_dbs);
    }

// POST Example (Query)
    () async {
    final Map<String, dynamic> body = {
      "query":
          "SELECT * FROM Faults f WHERE f.FaultId = @faultId",
      "parameters": [
        {"name": "@faultId", "value": 306000}
      ]
    };
    Map<String, dynamic> get_fault = await cosmos.queryCosmos(
        url:
            'https://{your_base_url}.documents.azure.com:443/dbs/{your_db}/colls/{your_collection}/docs',
        method: 'POST',
        body: body);
    print('Get fault $get_fault');
    }
```
