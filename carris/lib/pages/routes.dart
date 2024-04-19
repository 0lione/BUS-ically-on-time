import 'dart:convert';
import 'package:http/http.dart' as http;

class Routes {
  final String line_id;
  final String color;
  final String text_color;


  Routes({
    required this.line_id,
    required this.color,
    required this.text_color,
  });

  factory Routes.fromJson(Map<String, dynamic> json) {
    return Routes(
      line_id: json['line_id'],
      color: json['color'],
      text_color: json['text_color'],
    );
  }
}

Future<Map<String,Routes>> fetchRoute() async {
  final response = await http.get(Uri.parse('https://api.carrismetropolitana.pt/routes'));


  if (response.statusCode == 200) {
    Map<String,Routes> routes = {};
    for (var route in jsonDecode(response.body)) {
      routes[route['line_id']] = Routes.fromJson(route);
    }
    return routes;
  } else {
    throw Exception('Failed to load route');
  }
}