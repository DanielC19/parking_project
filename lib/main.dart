import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danilax Parqueaderos',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Danilax Parqueaderos'),
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
  Color? a1;
  Color? a2;
  int available = 0;

  @override
  void initState() {
    super.initState();
    _getData('65495d7d21573a000d5cf9a8', 1);
    _getData('65495d8421573a000d5cf9a9', 2);
  }

  void _refresh() async {
    _getData(dotenv.env['A1'], 1);
    _getData(dotenv.env['A2'], 2);
  }

  void _getData(String? key, int cell) async {
    final response = await http.get(
      Uri.parse(
          'https://industrial.api.ubidots.com/api/v1.6/variables/$key/values'),
      // Send authorization headers to the backend.
      headers: {
        'X-Auth-Token': dotenv.get('TOKEN', fallback: ''),
      },
    );
    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (cell == 1) {
        if (res['results'] == []) {
          setState(() {
            a1 = Colors.green;
          });
        } else {
          setState(() {
            a1 = Colors.red;
          });
        }
      } else {
        if (res['results'] != []) {
          setState(() {
            a2 = Colors.green;
          });
        } else {
          setState(() {
            a2 = Colors.red;
          });
        }
      }
      setState(() {
        available = 0;
        if (a1 == Colors.green) {
          available = available + 1;
        }
        if (a2 == Colors.green) {
          available = available + 1;
        }
      });
    } else {
      throw Exception('Failed to load answer');
    }
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
      backgroundColor: Color(0xFFEBEBEB),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Image(
          image: AssetImage('assets/eafit-logo.png'),
          width: 185,
        ),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 60,
                right: 60,
                top: 40,
                bottom: 40,
              ),
              child: Text(
                'Parqueadero Danilax',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xFF000066),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Celdas disponibles: $available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 60,
                bottom: 60,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: a1,
                    radius: 30,
                    child: Text(
                      'A1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  CircleAvatar(
                    backgroundColor: a2,
                    radius: 30,
                    child: Text(
                      'A2',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _refresh();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF000066),
                padding: EdgeInsets.all(20),
                shape: StadiumBorder(),
              ),
              child: Text(
                'Actualizar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}
