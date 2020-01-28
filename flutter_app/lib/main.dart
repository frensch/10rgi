import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Registry {
  int id;
  String status = "none";
  String name = "none";

  Registry(this.id);

  Map<String, dynamic> toJson() => {
        '\"id\"': id.toString(),
        '\"status\"': "\"" + status + "\"",
        '\"name\"': "\"" + name + "\"",
      };

  Registry.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        status = json['status'];
}

List<String> _fromListRegistry2ListString(List<Registry> registry) {
  List<String> list = new List<String>();
  for (int index = 0; index < registry.length; ++index) {
    list.add(registry[index].toJson().toString());
  }
  return list;
}

List<Registry> _fromListString2ListRegistry(List<String> list) {
  List<Registry> _registry = new List<Registry>();
  for (int index = 0; index < list.length; ++index) {
    Map<String, dynamic> ret = jsonDecode(list[index]);
    _registry.add((Registry.fromJson(ret)));
  }
  return _registry;
}

Future<bool> _saveList(List<String> list) async {
  var prefs = await SharedPreferences.getInstance();
  bool ret = await prefs.setStringList("key", list);
  return ret;
}

Future<List<String>> _getList() async {
  var prefs = await SharedPreferences.getInstance();
  var ret = prefs.getStringList("key");
  return ret;
}

List<Registry> registry = new List<Registry>();

Future<dynamic> onSelectNotification(String payload) async {
  print("notificação recebida");
  print(payload);
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future _showNotificationWithSound(Registry reg) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max,
      priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    "Mudança de Posição RGI: " + reg.id.toString(),
    "Posição do RGI: " + reg.id.toString() + " mudou para " + reg.status,
    platformChannelSpecifics,
    /*payload: 'Custom_Sound',*/
  );
}

void _sendNotification(Registry reg) {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('mipmap/ic_launcher');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

  _showNotificationWithSound(reg);
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    List<String> list = await _getList();
    if (list != null) {
      registry = _fromListString2ListRegistry(list);

      for (int i = 0; i < registry.length; ++i) {
        Response response = await Dio().post(
            "http://www.10ri-rj.com.br/Consultas.asp",
            data: {
              "tipo": "registro",
              "txtregistro": registry[i].id.toString()
            },
            options: Options(contentType: Headers.formUrlEncodedContentType));
        var document = parse(response.data.toString());
        var posicao = document.querySelector('[ name="posicao" ]');
        var apresentante = document.querySelector('[ name="apresentante" ]');
        registry[i].name = apresentante.attributes["value"];
        String value = posicao.attributes["value"];
        print(value);
        if (registry[i].status != value) {
          registry[i].status = value;
          _sendNotification(registry[i]);
        }
        List<String> list = _fromListRegistry2ListString(registry);
        _saveList(list);
      }
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<String> list = await _getList();
  if (list != null) {
    registry = _fromListString2ListRegistry(list);
  } else {
    registry = <Registry>[new Registry(387949), Registry(388384)];
    List<String> list = _fromListRegistry2ListString(registry);
    await _saveList(list);
  }

  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  //Workmanager.registerOneOffTask("1", "simpleTask"); //Android only (see below)
  Workmanager.registerPeriodicTask(
    "2",
    "requestRGIPeriodicTask",
    // When no frequency is provided the default 15 minutes is set.
    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    frequency: Duration(minutes: 15),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '10º Registro de Imóveis',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '10º Registro de Imóveis'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _removeItem(int index) {
    setState(() async {
      List<String> list = await _getList();
      if (list != null) {
        registry = _fromListString2ListRegistry(list);
      }
      registry.removeAt(index);
      list = _fromListRegistry2ListString(registry);
      _saveList(list);
    });
  }

  void _addItem() async {
    setState(() async {
      List<String> list = await _getList();
      if (list != null) {
        registry = _fromListString2ListRegistry(list);
      }
      _counter++;
      registry.add(new Registry(_counter));
      list = _fromListRegistry2ListString(registry);
      _saveList(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: registry.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                color: Colors.amber[500],
                child: Center(
                    child: Row(children: <Widget>[
                  GestureDetector(
                    child: Text(
                        'Registro: ${registry[index].id} | Posição: ${registry[index].status} | \n Nome: ${registry[index].name}'),
                    onTap: () async {
                      List<String> list = await _getList();
                      if (list != null) {
                        registry = _fromListString2ListRegistry(list);
                      }

                      return Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Registro: ${registry[index].id} | Posição: ${registry[index].status} | Nome: ${registry[index].name}')));},
                  ),
                  GestureDetector(
                      child: Icon(Icons.remove),
                      onTap: () => _removeItem(index))
                ])),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Adicionar',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
