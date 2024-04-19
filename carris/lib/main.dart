import 'package:carris/pages/map_pages.dart';
import 'package:carris/pages/routes.dart';
import 'package:carris/pages/stops.dart';
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
  late Future<Map<String,Routes>> routes;

  @override
  void initState() {
    super.initState();
    routes = fetchRoute();
    futureStops = fetchStops();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Stack(
        children:[
          FutureBuilder(
          future: futureStops,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Stops stops = snapshot.data as Stops;
              return FutureBuilder(
                future: routes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String,Routes> routes = snapshot.data as Map<String,Routes>;
                    return MapPage(stops: stops, routes: routes);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ), 
      ],
      ),
    );
  }
}