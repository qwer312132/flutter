import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // new
import 'package:cloud_firestore/cloud_firestore.dart'; // new
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'dart:io';

void main() {
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => Locate();
}

class Locate extends State<MyHomePage> {
  List<Marker> mak = [];
  String str = "";
  Future<Position> getLoc() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return pos;
  }

  var allData = [];
  void fun() async {
    Firebase.initializeApp();
    await Geolocator.requestPermission();
    Position tmp;
    List temp;
    while (true) {
      //sleep(const Duration(seconds: 10));
      tmp = await getLoc();
      await setlocation(tmp);
      temp = await getData();

      setState(() {
        allData = temp;
        str = tmp.toString();
      });
      //break;
    }
  }

  Future<void> setlocation(Position message) async {
    return FirebaseFirestore.instance
        .collection('user')
        .doc('id')
        .set(<String, dynamic>{
      'locationla': message.latitude,
      'locationlo': message.longitude,
      'name': "qwer",
    });
  }

  Future<List> getData() async {
    // Get docs from collection reference
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('user');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    debugPrint('$allData');
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    fun();
    return FlutterMap(
      options: MapOptions(
        center: latLng.LatLng(51.5, -0.09),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return const Text(" ");
          },
        ),
        MarkerLayerOptions(
          markers: [
            for (var item in allData)
              Marker(
                width: 80.0,
                height: 80.0,
                point: latLng.LatLng(
                    double.parse(item["locationla"].toString()),
                    double.parse(item["locationlo"].toString())),
                builder: (ctx) => Container(
                  child: const Icon(Icons.add_location),
                ),
              ),

            // Marker(
            //   width: 80.0,r
            //   height: 80.0,
            //   point: latLng.LatLng(51.5, -0.09),
            //   builder: (ctx) => Container(
            //     child: Icon(Icons.add),
            //   ),
            // ),
            // Marker(
            //   width: 80.0,
            //   height: 80.0,
            //   point: latLng.LatLng(51.6, 0.09),
            //   builder: (ctx) => Container(
            //     child: Icon(Icons.add),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  // success to get the data from firebase
  /*Widget build(BuildContext context) {
    //int x,y;
    return Scaffold(
      appBar: AppBar(
        title: const Text("qwer"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            for (var item in allData) Text(item['locationla'].toString()),
            Text(str),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fun,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }*/
}


/*Widget build(BuildContext context) {
  return FlutterMap(
    options: MapOptions(
      center: LatLng(51.5, -0.09),
      zoom: 13.0,
    ),
    layers: [
      TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c'],
        attributionBuilder: (_) {
          return Text("© OpenStreetMap contributors");
        },
      ),
      MarkerLayerOptions(
        markers: [
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(51.5, -0.09),
            builder: (ctx) => Container(
              child: FlutterLogo(),
            ),
          ),
        ],
      ),
    ],
  );
}*/
/*class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
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
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }*/

