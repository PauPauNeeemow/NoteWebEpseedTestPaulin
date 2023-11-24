import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoNotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ToDoNotes Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(227, 246, 245, 1.0),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: MediaQuery.of(context).size.width / 2.5,
            child: Visibility(
              visible: true,
              child: Container(
                height: 400,
                color: Color.fromRGBO(255, 255, 254, 1.0),
                child: Center(
                  child: Text(
                    'Div 1',
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2,
            right: 0,
            child: Visibility(
              visible: false,
              child: Container(
                height: 150,
                color: Colors.green,
                child: Center(
                  child: Text(
                    'Div 1.1',
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: MediaQuery.of(context).size.width / 2,
            child: Visibility(
              visible: false,
              child: Container(
                height: 150,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'Div 2',
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: MediaQuery.of(context).size.width / 2.5,
            right: 0,
            child: Visibility(
              visible: true,
              child: Container(
                height: 400,
                color: Color.fromRGBO(255, 255, 254, 1.0),
                child: Center(
                  child: Text(
                    'Div 2.1',
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}