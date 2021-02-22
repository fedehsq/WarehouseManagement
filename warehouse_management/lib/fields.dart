import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/magazineItem.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';

import 'main.dart';


class Fields extends StatefulWidget {

  static const int CHARGE = 0;
  static const int DISCHARGE = 1;


  final MagazineItem magazineItem;
  final spreadsheetId;

  const Fields({Key key, this.magazineItem, this.spreadsheetId}) : super(key: key);

  @override
  _FieldsState createState() => _FieldsState();
}

class _FieldsState extends State<Fields> {
  var texts = [
   //
    "Ditta: ",
    "Categoria: ",
    "Prodotto: ",
    "Codice ESTAR: ",
    "Mag. :",
    "Soglia: ",
    "Quantità: ",
    "Scadenza: ",
    "Ultimo Controllo: ",
    /*
    "Descrizione: ",
    "Urgenza: ",
    "Note: ",
    "BarCode: ",
    "REF. : ",
    "Link Foto: ",
    "Scarichi: ",
    "Check: ",
    "Carichi: ",
    "Missing name: ",
    "Consumo 2020 mensile: "
     */
  ];

  var listItems = <Widget>[];

  _buildRow() {
    var itemAsList = widget.magazineItem.toFilteredList();
    for (int i = 0; i < itemAsList.length; i++) {
      listItems.add(
          ListTile(
            title: Text(
              texts[i], style: TextStyle(color: Colors.black54),
            ),
            subtitle: Text(itemAsList[i],
              style: TextStyle(fontSize: 20, color: Colors.black),),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildRow();
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.magazineItem.description,
          )),
      body: ListView(
          children: [
            if (widget.magazineItem.photoLink.isNotEmpty)
              Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(widget.magazineItem.photoLink,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Padding(
                          padding: const EdgeInsets.all(64.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ?
                              loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ]
              ),
            ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: listItems),
          ]
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FlatButton(
              color: Colors.blue,
              onPressed: () => {
                _showChargeDischargeDialog(widget.magazineItem, Fields.DISCHARGE)
              }, child: Text("Scarica", style: TextStyle(color: Colors.white),),

          ),
          FlatButton(
              color: Colors.blue,
              onPressed: () => {
                _showChargeDischargeDialog(widget.magazineItem, Fields.CHARGE)
              }, child: Text("Carica", style: TextStyle(color: Colors.white),),

          ),
          FlatButton(
              color: Colors.blue,
              onPressed: () => {
                _showInventoryDialog(widget.magazineItem)
              }, child: Text("Inventario", style: TextStyle(color: Colors.white),),

          ),
        ],
      ),
    );
  }

  _showChargeDischargeDialog(MagazineItem item, int operation) {
    return showDialog(
      context: context,
      builder: (context) {
        int quantity = 0;
        TextEditingController controller = TextEditingController();
        bool loading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Inserisci quantità'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (loading) Center(child: CircularProgressIndicator(),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Presidio:'),
                            Text(
                              item.description, style: TextStyle(fontWeight: FontWeight.bold),),
                            TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isNotEmpty) {
                                      quantity = int.parse(controller.text);
                                    }
                                  });
                                },
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(icon: Icon(Icons.remove),
                                          onPressed: () =>
                                          {
                                            setState(() {
                                              if (quantity > 0) {
                                                quantity--;
                                                controller.text = quantity.toString();
                                              }
                                            })
                                          }),
                                      IconButton(icon: Icon(Icons.add),
                                          onPressed: () =>
                                          {
                                            setState(() {
                                              quantity++;
                                              controller.text = quantity.toString();
                                            })
                                          }),
                                    ],
                                  ),
                                  errorText: controller.text.isEmpty
                                      ? 'Richiesto'
                                      : null,
                                  labelText: 'Quantità',
                                  // border: const OutlineInputBorder(),
                                )
                            ),
                          ],
                        )
                      ],
                    ),

                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text('Salva'),
                    onPressed: () {
                      setState(() {
                        loading = true;
                        if (quantity > 0) {
                          writeChargeDischargeToSheet(item, quantity, operation)
                              .then((value) => Navigator.of(context).pop());
                        }
                      });
                    }
                ),
              ],
            );
          },
        );
      },
    );
  }

  _showInventoryDialog(MagazineItem item) {
    return showDialog(
      context: context,
      builder: (context) {
        // for remaining in inventory
        TextEditingController quantityController = TextEditingController();
        // optionally insert out of date
        TextEditingController outOfDateController = TextEditingController();
        bool loading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Inserisci dati'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // saving on sheet
                        if (loading) Center(
                          child: CircularProgressIndicator(),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Presidio:'),
                            Text(item.description,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // availability remaining
                            TextFormField(
                                onChanged: (value) {
                                  if (value.length <= 1) {
                                    setState(() {});
                                  }
                                },
                                controller: quantityController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  errorText: quantityController.text.isEmpty
                                      ? 'Richiesto'
                                      : null,
                                  labelText: 'Rimanenza',
                                  // border: const OutlineInputBorder(),
                                )
                            ),
                            // out of date
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextFormField(
                                  showCursor: false,
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    setState(() {
                                        outOfDateController.text = picked == null? '':
                                        DateFormat('dd/MM/yyyy').format(picked);
                                      });
                                    },
                                  controller: outOfDateController,
                                  decoration: InputDecoration(
                                    hintText: 'Scadenza',
                                    // border: const OutlineInputBorder(),
                                  )
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text('Salva'),
                    onPressed: () {
                      if (quantityController.text.isNotEmpty) {
                        setState(() {
                          loading = true;
                          writeInventoryToSheet(item,
                              int.parse(quantityController.text),
                              outOfDateController.text)
                              .then((value) => Navigator.of(context).pop());
                        });
                      }
                    }
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> writeChargeDischargeToSheet(MagazineItem item, int quantity,
      int operation) async {
    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(widget.spreadsheetId);
    // get worksheet by its title
    var sheet = operation == Fields.DISCHARGE ? ss.worksheetByTitle('Scarichi') :
    ss.worksheetByTitle('Carichi');
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy kk.mm.ss').format(now);
    return await sheet.values.appendRow([formattedDate, item.description, quantity]);
  }

  Future<bool> writeInventoryToSheet(MagazineItem item, int remaining, String
  outOfDate) async {
    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(widget.spreadsheetId);
    // get worksheet by its title
    var sheet = ss.worksheetByTitle('Controllo');
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy kk.mm.ss').format(now);
    return await sheet.values.appendRow([formattedDate, item.description, remaining,
      outOfDate ]);
  }
}
