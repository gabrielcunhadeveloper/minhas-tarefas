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
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPosition;

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
                  return buildItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem (BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_tasks[index]);
          _lastRemovedPosition = index;
          _tasks.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _tasks.insert(_lastRemovedPosition, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);

        });
      },
      child: CheckboxListTile(
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
      )
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
