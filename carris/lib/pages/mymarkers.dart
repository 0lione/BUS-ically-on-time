import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BusMarker extends Marker {
  const BusMarker(LatLng point)
    : super(
      point: point,
      child: const Icon(
        Icons.directions_bus,
        size: 30.0,
        color: Colors.deepOrangeAccent,
      ),
      width: 80,
      height: 80,
      );
}

class StopsMarker extends Marker {
  StopsMarker(LatLng point, bool inRadius, bool inPath) 
    : super(
      point: point,
      child: Icon(
          inRadius ? Icons.location_on : Icons.circle,
          size: inRadius ? 30.0 : 15.0,
          color: inPath ? Colors.yellowAccent: Colors.blueAccent,
        ),
      width: 80,
      height: 80,
      );
}

class MyStopMarker extends Marker {
  const MyStopMarker(LatLng point) 
    : super(
      point: point,
      child: const Icon(
        Icons.location_on,
        size: 35,
        color: Colors.deepOrangeAccent,
      ),
      width: 80,
      height: 80,
    );
}


class MyLocationMarker extends Marker {
  const MyLocationMarker(LatLng point)
  : super (
    point: point,
    child: const Icon(
      Icons.location_on_sharp,
      size : 20.0,
      color: Colors.deepPurpleAccent,
    ),
    height: 80.0,
    width: 80.0,
  );
}

