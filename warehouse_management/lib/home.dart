import 'package:flutter/material.dart';
import 'package:flutter_app/magazineItem.dart';
import 'fields.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  // description as string passed from main.dart
  // description of magazine item
  final List<MagazineItem> itemsDescription;
  final spreadsheetId;
  final sheet;
  final title;

  HomePage({Key key, this.itemsDescription, this.spreadsheetId, this.title,
    this.sheet }): super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final List<Widget> itemsDescription = <Widget>[];
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myControllerOne = TextEditingController();
  final myControllerTwo = TextEditingController();

  var search = false;

  final filtered = <MagazineItem>[];


  void initState() {
    super.initState();

    filtered.addAll(widget.itemsDescription);
    // Start listening to changes.
    myControllerOne.addListener(_filterList);
  }

  /// update list in UI showing searched parameters
  _filterList() {
    // clean the searched list
    filtered.clear();
    // search element
    for (var item in widget.itemsDescription) {
      if (item.category.toLowerCase().contains(myControllerOne.text.toLowerCase())
          || item.estarCode.toLowerCase().contains(myControllerOne.text.toLowerCase())
          || item.description.toLowerCase().contains(myControllerOne.text.toLowerCase())
          || item.product.toLowerCase().contains(myControllerOne.text.toLowerCase())
          || item.urgency.toLowerCase().contains(myControllerOne.text.toLowerCase())
          || item.owner.toLowerCase().contains(myControllerOne.text.toLowerCase())) {
        filtered.add(item);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerOne.dispose();
    myControllerTwo.dispose();
    super.dispose();
  }

  bool toCheck(String date) {
    if (date.isEmpty) {
      return false;
    }
    var splittedDate = date.split('/');
    String year = splittedDate[2];
    String month = splittedDate[1];
    String day = splittedDate[0];

    int lastCheckMs = DateTime.parse(year + month + day).millisecondsSinceEpoch;
    int nowMs = DateTime.now().millisecondsSinceEpoch;

    int weekMs = 604800000;

    // if > a week, check
    return nowMs - lastCheckMs > weekMs;

  }

  Widget _buildRow(MagazineItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: item.photoLink.isNotEmpty ? Image.network(
              item.photoLink,
              fit: BoxFit.cover,
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.error, color: Colors.red,)) : null,
          title: Text(
            item.description,
          ),
          trailing: toCheck(item.lastCheck) ? Icon(Icons.warning, color: Colors.yellow) : null,
          subtitle: Text(item.product),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                Fields(
                    magazineItem: item, spreadsheetId: widget.spreadsheetId)
            ));
          },
        ),
        Divider(
            thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: search ? IconButton(
          icon: Icon(Icons.arrow_back), onPressed: () {
          setState(() {
            myControllerOne.clear();
            filtered.clear();
            search = false;
          });
        },) : null,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (BuildContext context) =>
                    LoadGsheets(spreadsheetId: widget.spreadsheetId,
                        sheetName: widget.sheet)
                ),
                ModalRoute.withName('/')
            );
          }),
          IconButton(icon: Icon(Icons.search), onPressed: () {
            setState(() {
              search = !search;
            });
          })
        ],
        title: search ? TextField(
          cursorColor: Colors.white,
          controller: myControllerOne,
          decoration: InputDecoration(
            hintText: 'Prodotto, ESTAR, Categoria...',
          ),
        ) : Text(widget.title),
      ),
      // if is searching show the found else all
      body: filtered.isNotEmpty ? ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(filtered[index]);
        },
      ) : myControllerOne.text.isEmpty ? ListView.builder(
        itemCount: widget.itemsDescription.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(widget.itemsDescription[index]);
        },
      ) : Center(child: Text("Oggetto non presente")),
    );
  }
}

