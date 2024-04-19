import 'dart:convert';
import 'package:http/http.dart' as http;

class StopEstimation {
  final String line;
  final String pattern;
  final String route;
  final String trip;
  final String destination;
  late String? estimatedTime;
  late String scheduledTime;
  final String? vehicle;


  StopEstimation({
    required this.line,
    required this.pattern,
    required this.route,
    required this.trip,
    required this.destination,
    required this.estimatedTime,
    required this.vehicle,
    required this.scheduledTime,
  });

  factory StopEstimation.fromJson(Map<String, dynamic> json) {
    return StopEstimation(
      line: json['line_id'],
      pattern: json['pattern_id'],
      route: json['route_id'],
      trip: json['trip_id'],
      destination: json['headsign'],
      estimatedTime: json['estimated_arrival'],
      vehicle: json['vehicle_id'],
      scheduledTime: json['scheduled_arrival'] ,
    );
  }
}

Future<List<StopEstimation>> fetchStopEstimation(int idStop) async {
  final response = await http.get(Uri.parse('https://api.carrismetropolitana.pt/stops/$idStop/realtime'));

  if (response.statusCode == 200) {
    List<StopEstimation> stopEstimation = [];
    for (var stop in jsonDecode(response.body)) {
      stopEstimation.add(StopEstimation.fromJson(stop));
    }
    return stopEstimation;
  } else {
    throw Exception('Failed to load stop estimation');
  }
}