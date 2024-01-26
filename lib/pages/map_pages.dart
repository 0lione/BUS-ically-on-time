import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late double lat, lon;
  late LatLng? point;

  @override
  void initState() {
    super.initState();
    point = null;
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    } 
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(38.7368162642364, -9.138718322972395),
          initialZoom: 20.0,),
         children: [
          ElevatedButton(
            onPressed: () {
              _getLocation().then((value) => {
                setState(() {
                  lat = value.latitude;
                  lon = value.longitude;
                  point = LatLng(lat, lon);
                })
              });
            },
            child: const Text('Get Current Location'),
          ),
          if (point != null) MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: point!,
                child: const Icon(
                  Icons.location_on,
                  size: 80.0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
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