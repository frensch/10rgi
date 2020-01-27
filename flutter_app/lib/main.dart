import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

List<int> registry = <int>[387949, 387949, 387949, 387949];

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    int totalItems = registry.length;
    print("Native called background task: $totalItems"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
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
    setState(() {
      registry.removeAt(index);
    });
  }
  void _addItem() {
    setState(() {
      _counter++;
      registry.add(_counter);
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
      body: Center(child: ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: registry.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          color: Colors.amber[500],
          child: Center(child:  Row( children: <Widget>[
            GestureDetector(
            child: Text('Registro: ${registry[index]}'),
            onTap: () => Scaffold
                .of(context)
                .showSnackBar(SnackBar(content: Text('Registro: ${registry[index]}'))),
          ),
            GestureDetector(
                child: Icon(Icons.remove),
                onTap: () => _removeItem(index))])),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Adicionar',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
