import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const GET_FINANCE =
    "https://api.hgbrasil.com/finance?format=json-cors&key=b63a4d8b";

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Currency Converter \$",
            style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return getTextCenter("Loading data");
            default:
              if (snapshot.hasError) {
                return getTextCenter("Error loading data :(");
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 160.0,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Real", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólar", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euro", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
    ;
  }
}

Center getTextCenter(String text) {
  return Center(
    child: Text(
      "Loading data",
      style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget buildTextField(String text, String prefix,
    TextEditingController editingController, Function function) {
  return TextField(
    decoration: InputDecoration(
      labelText: text,
      labelStyle: TextStyle(color: Colors.amber),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Color(0xFFFFD54F)),
      border: OutlineInputBorder(),
    ),
    style: TextStyle(color: Color(0xFFFFD54F), fontSize: 18.0),
    controller: editingController,
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}

/**
 * Return data finance
 */
Future<Map> getData() async {
  http.Response response = await http.get(GET_FINANCE);
  return json.decode(response.body);
}
