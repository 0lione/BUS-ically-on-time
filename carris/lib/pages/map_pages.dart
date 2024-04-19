import 'dart:async';
import 'package:carris/pages/mymarkers.dart';
import 'package:carris/pages/mypanel.dart';
import 'package:carris/pages/routes.dart';
import 'package:carris/pages/shape.dart';
import 'package:carris/pages/stops.dart';
import 'package:carris/pages/vehicles.dart';
import 'package:carris/pages/patterns.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';



class MapPage extends StatefulWidget {
  final Stops stops;
  final Map<String,Routes> routes;
  const MapPage({super.key, required this.stops, required this.routes});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late double lat, lon;
  late LatLng? point;
  late int idStop;
  final MapController mapController = MapController();
  // 1Km radius
  final double radius = 0.01;
  late String tripId;
  late bool clicked = false;
  late Future<Shape> futureShape;
  late Future<Vehicles> futureVehicles;
  late Timer? vehicleTimer;
  late Pattern pattern;
  late String patternId;
  late Set<Stop>? inRadiusStops;

  @override
  void initState() {
    super.initState();
    point = null;
    idStop = -1;
    tripId = "";
    patternId = "";
    clicked = false;
    inRadiusStops = null;
    vehicleTimer = Timer.periodic(const Duration(seconds: 15), (Timer t) => _updateVehicles());
    _updateVehicles();
  }

  _updateMyVehicle(String? newTripId, Future<Pattern> futurePattern) async {
    Pattern temp = await futurePattern;
    setState(() {
      futureShape = fetchShape(temp.shapeId);
      if(newTripId != null) {
        tripId = newTripId;
      } else {
        tripId = "";
      }
      if (patternId != temp.id) {
        clicked = true;
      } else {
        clicked = !clicked;
      }
      patternId = temp.id;
      pattern = temp;
    });
  }

  _updateVehicles() {
    setState(() {
      futureVehicles = fetchVehicles();
    });
  }




  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    } 
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    vehicleTimer?.cancel();
    super.dispose();
  }


  


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SlidingUpPanel(
        renderPanelSheet: false,
        minHeight: 60,
        panel: MyPanel(idStop: idStop, callback: _updateMyVehicle,routes: widget.routes,),
        body:
          Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                initialCenter: LatLng(38.7368162642364, -9.138718322972395),
                initialZoom: 17.0,
                ),
              children: [
                TileLayer(
                  urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                if(point != null) MarkerLayer(markers: [MyLocationMarker(point!)]),
                if(clicked) 
                  FutureBuilder<Shape>(
                    future: futureShape,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PolylineLayer(
                            polylines: [
                              Polyline(
                                points: snapshot.data!.points.where((point) => point != null).map((point) => point!).toList(),
                                strokeWidth: 4.0,
                                color: Colors.deepPurpleAccent,
                              ),
                            ]
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                if (point != null)
                  for (var stop in inRadiusStops!)
                    GestureDetector(
                      onTap: () => {
                        setState(() {
                          if (idStop == stop.id) {
                            idStop = -1;
                            return;
                          }
                          idStop = stop.id;
                        })
                      },
                      child:
                         MarkerLayer(
                           markers: [
                              if(stop.id != idStop)
                                StopsMarker(LatLng(stop.lat, stop.lon), true, false)
                              else
                                MyStopMarker(LatLng(stop.lat, stop.lon)),
                           ],
                         )
                    ),
                if(clicked)
                  Stack(
                    children: [
                      MarkerLayer(
                        markers: [
                          for(var stop in pattern.path.stops)
                            if(stop.id != idStop)
                              StopsMarker(LatLng(stop.lat, stop.lon), 
                              inRadiusStops!.where((e) => e.id == stop.id).isNotEmpty, true)
                        ],
                      ),
                      FutureBuilder<Vehicles>(
                        future: futureVehicles,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return MarkerLayer(
                                  markers: [
                                    if(tripId != "")
                                        if(snapshot.data!.vehicles[tripId] != null)
                                          BusMarker(LatLng(snapshot.data!.vehicles[tripId]!.lat, snapshot.data!.vehicles[tripId]!.lon)),
                                  ],
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
              ],
              ),
            Positioned(
              top: 50,
              right: 10,
              child: 
                ElevatedButton(
                  onPressed: () {
                    _getLocation().then((value) => {
                      setState(() {
                        lat = value.latitude;
                        lon = value.longitude;
                        point = LatLng(lat, lon);
                        mapController.move(point!, 20.0);
                        inRadiusStops = widget.stops.getInRadius(lat, lon, radius);
                      })
                    });
                  }, 
                  child: const Icon(Icons.location_on_outlined, color: Colors.deepPurpleAccent, size: 40.0)
                ),
            ),
          ],
        ),
      ),
    );
  }
}
