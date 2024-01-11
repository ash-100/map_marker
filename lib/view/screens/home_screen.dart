import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_flutter/model/marker_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition initialPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14.0);

  static const CameraPosition targetPosition = CameraPosition(
      target: LatLng(37.43296265331129, -122.08832357078792),
      zoom: 14.0,
      bearing: 192.0,
      tilt: 60);

  String _text = "NULL";
  String _lat = "37.42796133580664", _long = "-122.085749655962";
  TextEditingController _labelController = TextEditingController();
  List<Marker> _markers = [];

  bool delete = false;
  @override
  @override
  void initState() {
    // TODO: implement initState

    // getMarkers(context as BuildContext);
    super.initState();
    getMarkers();
  }

  void getMarkers() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'marker_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE MarkerData(markerId TEXT PRIMARY KEY, latitude TEXT,longitude TEXT,labelName TEXT)',
        );
      },
      version: 1,
    );
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('MarkerData');
    List<MarkerData> m = List.generate(maps.length, (index) {
      return MarkerData(
          markerId: maps[index]['markerId'],
          latitude: maps[index]['latitude'],
          longitude: maps[index]['longitude'],
          labelName: maps[index]['labelName']);
    });

    List<Marker> temp = [];
    for (int i = 0; i < m.length; i++) {
      MarkerData _markerData = m[i];
      print(_markerData.labelName);
      temp.add(
        Marker(
          infoWindow: InfoWindow(
            title: _labelController.text,
            snippet: _markerData.latitude + "," + _markerData.longitude,
          ),
          markerId: MarkerId(_markerData.markerId),
          position: LatLng(double.parse(_markerData.latitude),
              double.parse(_markerData.longitude)),
          onTap: () {
            print(delete);
            if (delete) {
              print('delete');

              setState(() {
                _markers.removeWhere((element) =>
                    element.markerId == MarkerId(_markerData.markerId));
                deleteDataFromDB(_markerData.markerId);
              });
            }
            print('tapped');
          },
        ),
      );
    }
    setState(() {
      _markers = temp;
    });
  }

  Future<void> insertMarkerToDB(MarkerData markerData) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'marker_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE MarkerData(markerId TEXT PRIMARY KEY, latitude TEXT,longitude TEXT,labelName TEXT)',
        );
      },
      version: 1,
    );
    final db = await database;

    await db.insert('MarkerData', markerData.toMap());
  }

  void addData(String markerId, String latitude, String longitude,
      String labelName) async {
    var data = MarkerData(
        markerId: markerId,
        latitude: latitude,
        longitude: longitude,
        labelName: labelName);
    await insertMarkerToDB(data);
  }

  Future<void> deleteDataFromDB(String markerId) async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'marker_database.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE MarkerData(markerId TEXT PRIMARY KEY, latitude TEXT,longitude TEXT,labelName TEXT)',
        );
      },
      version: 1,
    );
    final db = await database;
    await db.delete(
      'MarkerData',
      where: 'markerId = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [markerId],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              markers: Set.from(_markers),
              mapType: MapType.normal,
              initialCameraPosition: initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: (position) {
                setState(() {
                  _text = position.target.toString();
                  _lat = position.target.latitude.toString();
                  _long = position.target.longitude.toString();
                });
              },
              onTap: (argument) {},
              onLongPress: (argument) {
                showDialog(
                    context: context,
                    builder: (context1) => AlertDialog(
                          title: Text('Add marker'),
                          content: TextField(
                            controller: _labelController,
                            decoration:
                                InputDecoration(hintText: "Enter label name"),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context1);
                                },
                                child: Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  // add in markers and database
                                  setState(() {
                                    _markers.add(
                                      Marker(
                                        infoWindow: InfoWindow(
                                          title: _labelController.text,
                                          snippet:
                                              argument.latitude.toString() +
                                                  "," +
                                                  argument.longitude.toString(),
                                        ),
                                        markerId: MarkerId(argument.toString()),
                                        position: argument,
                                        onTap: () {
                                          print(delete);
                                          if (delete) {
                                            print('delete');

                                            setState(() {
                                              _markers.removeWhere((element) =>
                                                  element.markerId ==
                                                  MarkerId(
                                                      argument.toString()));
                                              deleteDataFromDB(
                                                  argument.toString());
                                            });
                                          }
                                          print('tapped');
                                        },
                                      ),
                                    );
                                    addData(
                                        argument.toString(),
                                        argument.latitude.toString(),
                                        argument.longitude.toString(),
                                        _labelController.text);
                                  });
                                  Navigator.pop(context1);
                                },
                                child: Text('Add'))
                          ],
                        ));
              },
            ),
          ),
          Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  Text('Latitude: ' + _lat),
                  Text('Longitude: ' + _long),
                ],
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            delete = !delete;
          });
        },
        child: Icon(
          Icons.delete,
          color: delete ? Colors.red : Colors.black,
        ),
      ),
    );
  }
}
