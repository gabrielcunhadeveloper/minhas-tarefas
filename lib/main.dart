import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Tarefas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Minhas Tarefas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List _tasks = [];
  TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();

//  Após termino da leitura dos dados do arquivo, irá chamar a função
//  anônima passando a string retornada para o parâmetro data.
    _readData().then((data) {
      setState(() {
        _tasks = json.decode(data);
      });
    });
  }

  void _addTasks() {
    setState(() {
      Map<String, dynamic> newTask = Map();
      newTask["title"] = _taskController.text;
      _taskController.text = "";
      newTask["ok"] = false;
      _tasks.add(newTask);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    child: Text(
                      "Add",
                    ),
                    textColor: Colors.white,
                    onPressed: _addTasks,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_tasks[index]["title"]),
                    value: _tasks[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(
                        _tasks[index]["ok"] ? Icons.check : Icons.error
                      ),
                    ),
                    onChanged: (checked) {
                      setState(() {
                        _tasks[index]["ok"] = checked;
                        _saveData();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _getFile() async {
    final path = await getApplicationDocumentsDirectory();
    return File("${path.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_tasks);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
