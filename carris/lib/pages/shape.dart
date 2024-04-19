import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';


class Shape {
  final Map<String,dynamic> geojson;
  final String id;
  final List<LatLng?> points;

  const Shape({
    required this.geojson,
    required this.id,
    required this.points,
  });

  factory Shape.fromJson(Map<String, dynamic> json) {
    final List<LatLng?> points = [];
    for (var point in json['points']) {
      points.add(LatLng(point['shape_pt_lat'], point['shape_pt_lon']));
      // points are received as 0: shape_pt_lat: 38.7369, shape_pt_lon: -9.1428
    }
    return Shape(
      geojson: json['geojson'],
      id: json['id'],
      points: points,
    );
  }
}



Future<Shape> fetchShape(String shapeId) async {
  final response = await http.get(Uri.parse('https://api.carrismetropolitana.pt/shapes/$shapeId'));

  if (response.statusCode == 200) {
    var test = Shape.fromJson(jsonDecode(response.body));
    return test;
  } else {
    throw Exception('Failed to load shape');
  }
}