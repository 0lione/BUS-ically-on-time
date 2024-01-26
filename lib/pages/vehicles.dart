import 'dart:convert';
import 'package:http/http.dart' as http;

class Vehicles {
  final Map<String, Vehicle> vehicles; 

  Vehicles({required this.vehicles});
}

class Vehicle {
  final String id;
  final double lat;
  final double lon;
  final double? speed;
  final double? heading;
  final String? trip_id;
  final String? pattern_id;
  final int? timestamp;

  const Vehicle({
    required this.id,
    required this.lat,
    required this.lon,
    required this.speed,
    required this.heading,
    required this.trip_id,
    required this.pattern_id,
    required this.timestamp,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      speed: json['speed'] != null ? double.parse(json['speed'].toString()) : null,
      heading: json['heading'] != null ? double.parse(json['heading'].toString()) : null,
      trip_id: json['trip_id'],
      pattern_id: json['pattern_id'],
      timestamp: json['timestamp'],
    );
  }

}

Future<Vehicles> fetchVehicles() async {
  final response = await http.get(Uri.parse('https://api.carrismetropolitana.pt/vehicles'));

  if (response.statusCode == 200) {
    Map<String, Vehicle> vehicles = {};
    for (var vehicle in jsonDecode(response.body)) {
      vehicles[vehicle['id']] = Vehicle.fromJson(vehicle);
    }
    return Vehicles(vehicles: vehicles);
  } else {
    throw Exception('Failed to load vehicles');
  }
}
