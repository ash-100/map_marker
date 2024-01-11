import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
                                        markerId: MarkerId(argument.toString()),
                                        position: argument,
                                        onTap: () {
                                          setState(() {
                                            print('trigger 2');
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text(
                                                          _labelController
                                                              .text),
                                                      content: Container(
                                                        height: 100,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text("Latitude: " +
                                                                  argument
                                                                      .latitude
                                                                      .toString()),
                                                              Text("Longitude: " +
                                                                  argument
                                                                      .longitude
                                                                      .toString())
                                                            ]),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _markers.removeWhere((element) =>
                                                                    element
                                                                        .markerId ==
                                                                    MarkerId(
                                                                        argument
                                                                            .toString()));
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              'Remove Marker',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            )),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('OK'))
                                                      ],
                                                    ));
                                          });
                                          print('tapped');
                                        },
                                      ),
                                    );
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
        onPressed: () {},
        child: Icon(Icons.location_searching),
      ),
    );
  }
}
