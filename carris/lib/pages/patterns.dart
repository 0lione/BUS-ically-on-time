import 'dart:convert';
import 'package:carris/pages/stops.dart';
import 'package:http/http.dart' as http;

class Pattern {
  final String id;
  final String? color;
  final String? textColor;
  final String shapeId;
  final Stops path;

  const Pattern({
    required this.id,
    required this.color,
    required this.textColor,
    required this.shapeId,
    required this.path,
  });

  factory Pattern.fromJson(Map<String, dynamic> json) {
    Set<Stop> temp = {};
    for (var stop in json['path']) {
      temp.add(Stop.fromJson(stop['stop']));
    }
    return Pattern(
      id: json['id'],
      color: json['color'],
      textColor: json['text_color'],
      shapeId: json['shape_id'],
      path: Stops(stops: temp),
    );
  }
}

Future<Pattern> fetchPattern(String patternId) async {
  final response = await http.get(Uri.parse('https://api.carrismetropolitana.pt/patterns/$patternId'));

  if (response.statusCode == 200) {
    return Pattern.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load pattern');
  }
}