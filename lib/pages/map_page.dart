import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    var initialPosition = LatLng(38.7368162642364, -9.138718322972395);


    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(38.7368162642364, -9.138718322972395),
          initialZoom: 20.0,),
         children: [
          TileLayer(
            urlTemplate:'https://api.mapbox.com/styles/v1/0lione/clrta0gi6005z01pd0c1b5n1i/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiMGxpb25lIiwiYSI6ImNscnQ5cmYyYzA0djYyaXRlazBtZWZnYTEifQ.Pg91wldCJcGiuM73GPQ9hA' ,
            additionalOptions:const {
              'accessToken': 'pk.eyJ1IjoiMGxpb25lIiwiYSI6ImNscnRiOGNjZzA1ZjIya21yaHo3YnU4MnUifQ.sQvn6gR95wxsed9XMu_D1A',
              'id' : 'mapbox.mapbox-streets-v8'
            } ,),
         ]),
    );
  }
}