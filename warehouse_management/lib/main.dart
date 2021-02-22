import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/magazineItem.dart';
import 'package:gsheets/gsheets.dart';
import 'home.dart';

// your google auth credentials
final credentials = r'''
{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": ""
}
''';
// your spreadsheets id
const magazine7SpreadsheetId = '';
const magazineTotaleSpreadsheetId = '';
const magazineScortaSpreadsheetId = '';
const magazineSalaSpreadsheetId = '';
const magazine4SpreadsheetId = '';
const magazine3SpreadsheetId = '';
const magazine1SpreadsheetId = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GsheetsSelector(),
    );
  }
}

class GsheetsSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Seleziona un magazzino')),
        body: ListView(
          children: [
            ListTile(
              title: Text('Magazzino Totale'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                        LoadGsheets(spreadsheetId: magazineTotaleSpreadsheetId,
                            sheetName: 'MagazzinoTotale')
                    ),
                  ),
            ),
            ListTile(
              title: Text('Magazzino Scorta'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                        LoadGsheets(spreadsheetId: magazineScortaSpreadsheetId,
                            sheetName: 'MagazzinoScorta')
                    ),
                  ),
            ),
            ListTile(
              title: Text('Magazzino 7'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                        LoadGsheets(spreadsheetId: magazine7SpreadsheetId,
                            sheetName: 'Magazzino7')
                    ),
                  ),
            ),
            ListTile(
              title: Text('Magazzino 4'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                        LoadGsheets(spreadsheetId: magazine4SpreadsheetId,
                            sheetName: 'Magazzino4')
                    ),
                  ),
            ),
            ListTile(
              title: Text('Magazzino 3'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                        LoadGsheets(spreadsheetId: magazine3SpreadsheetId,
                            sheetName: 'Magazzino3')
                    ),
                  ),
            ),
            ListTile(
              title: Text('Magazzino -1'),
              leading: Icon(Icons.description),
              trailing: Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) =>
                        LoadGsheets(spreadsheetId: magazine1SpreadsheetId,
                            sheetName: 'Magazzino-1')
                    ),
                  ),
            ),
          ],
        )
    );
  }
}



class LoadGsheets extends StatefulWidget {
  final spreadsheetId;
  final sheetName;

  const LoadGsheets({Key key, this.spreadsheetId, this.sheetName}) : super(key: key);
  @override
  _LoadGsheetsState createState() => _LoadGsheetsState();
}

class _LoadGsheetsState extends State<LoadGsheets> {
  //  magazine item
  List<MagazineItem> items = <MagazineItem>[];

  String title;

  // get already ALL attributes of object!

  // load gsheet from gdrive
  Future<List<MagazineItem>> _loadGsheet() async {
    // init GSheets
    final gsheets = GSheets(credentials);

    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(widget.spreadsheetId);

    // get worksheet by its title
    var sheet = ss.worksheetByTitle(widget.sheetName);

    // get title of sheet
    //title = await sheet.values.value(column: 3, row: 1);
    title = widget.sheetName;

    // get all rows
    //var cell = await sheet.values.row(3, fromColumn: 1);
    
    var rows = await sheet.values.allRows(fromRow: 3, fromColumn: 1);
    // iterate over row
    //int i = 3;
    for (var row in rows) {
   //   print("$i");
     // i++;
      // default value as ' '
      for (int j = row.length; j < 20; j++) {
        row.add('');
      }
      MagazineItem magazineItem = MagazineItem(
          row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8],
          row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16],
          row[17], row[18], row.length == 20 ? row[19] : '',
      );
      items.add(magazineItem);
    }
    items.sort((a, b) => a.description.compareTo(b.description));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<MagazineItem>>(
            future: _loadGsheet(),
            builder: (context, AsyncSnapshot<List<MagazineItem>> snapshot) {
              if (snapshot.hasData) {
                return HomePage(itemsDescription: items,
                    spreadsheetId: widget.spreadsheetId,
                    title: title,
                    sheet: widget.sheetName);
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Before insert your data..."),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: LinearProgressIndicator(),
                    )
                  ],
                );
              }
            })
    );
  }
}


