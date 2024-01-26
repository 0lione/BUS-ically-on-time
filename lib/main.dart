import 'package:app/pages/map_pages.dart';
import 'package:app/pages/stops.dart';
import 'package:app/pages/vehicles.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  late Future<Stops> futureStops;
  late Future<Vehicles> futureVehicles;

  @override
  void initState() {
    super.initState();
    futureStops = fetchStops();
    futureVehicles = fetchVehicles();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FutureBuilder(
        future: futureStops,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
              future: futureVehicles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const MapPage();
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ) 
    );
  }
}