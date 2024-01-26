import 'dart:convert';
import 'package:http/http.dart' as http;

class Stops {
  final Set<Stop> stops;

  Stops({required this.stops});
}


class Stop {
  final int id;
  final double lat;
  final double lon;
  final String? locality;
  final List<dynamic>? lines;
  final List<dynamic>? routes;
  final List<dynamic>? patterns;

  const Stop({
    required this.id,
    required this.lat,
    required this.lon,
    required this.locality,
    required this.lines,
    required this.routes,
    required this.patterns,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: int.parse(json['id'].toString()),
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      locality: json['locality'],
      lines: json['lines'],
      routes: json['routes'],
      patterns: json['patterns'],
    );
  }

}

Future<Stops> fetchStops() async {
  final response = await http.get(Uri.parse('https://api.carrismetropolitana.pt/stops'));

  if (response.statusCode == 200) {
    Set<Stop> stops = {};
    for (var stop in jsonDecode(response.body)) {
      stops.add(Stop.fromJson(stop));
    }
    return Stops(stops: stops);
  } else {
    throw Exception('Failed to load stops');
  }
}