import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//fazer requisições na internet
import 'package:http/http.dart' as http;

//não deixar o app parar até receber a requisição
import 'dart:async';

//converter dados para JSON
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=0121c710";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintStyle: TextStyle(color: Colors.red),
      ),
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;
  double iene;

  void _realChanged(String imput) {
    if(imput.isEmpty) {
      _refresh();
      return;
    }
    double valor = double.parse(imput.replaceAll(",", "."));
    dolarController.text = (valor/dolar).toStringAsFixed(2);
    euroController.text = (valor/euro).toStringAsFixed(2);
    ieneController.text = (valor/iene).toStringAsFixed(2);
  }

  void _dolarChanged(String imput) {
    if(imput.isEmpty) {
      _refresh();
      return;
    }
    double valor = double.parse(imput.replaceAll(",", "."));
    realController.text = (valor*dolar).toStringAsFixed(2);
    euroController.text = ((valor*dolar)/euro).toStringAsFixed(2);
    ieneController.text = ((valor*dolar)/iene).toStringAsFixed(2);
  }

  void _euroChanged(String imput) {
    if(imput.isEmpty) {
      _refresh();
      return;
    }
    double valor = double.parse(imput.replaceAll(",", "."));
    realController.text = (valor*euro).toStringAsFixed(2);
    dolarController.text = ((valor*euro)/dolar).toStringAsFixed(2);
    ieneController.text = ((valor*euro)/iene).toStringAsFixed(2);
  }

  void _ieneChanged(String imput) {
    if(imput.isEmpty) {
      _refresh();
      return;
    }
    double valor = double.parse(imput.replaceAll(",", "."));
    realController.text = (valor*iene).toStringAsFixed(2);
    dolarController.text = ((valor*iene)/dolar).toStringAsFixed(2);
    euroController.text = ((valor*iene)/dolar).toStringAsFixed(2);
  }

  void _refresh(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    ieneController.text = "";
  }

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final ieneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Conversor de Moedas \$"),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapShot) {
          switch (snapShot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando",
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapShot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao Carregar",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapShot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapShot.data["results"]["currencies"]["EUR"]["buy"];
                iene = snapShot.data["results"]["currencies"]["JPY"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on,
                          size: 150, color: Colors.amber),
                      Divider(),
                      buildTextField("Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€ ", euroController, _euroChanged),
                      Divider(),
                      buildTextField("Ienes", "JP¥ ", ieneController, _ieneChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return jsonDecode(response.body);
}



Widget buildTextField(String title, String prefix,
    TextEditingController controller, Function changeValor) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: controller,
    style: TextStyle(color: Colors.amber, fontSize: 18),
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelText: title,
      labelStyle: TextStyle(color: Colors.amber),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.amber, fontSize: 18),
    ),
    //retorna string para a função
    onChanged: changeValor,
  );
}
