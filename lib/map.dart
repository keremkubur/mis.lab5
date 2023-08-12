import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});


  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  LatLng _currentPosition = LatLng(41.99646, 21.43141);
  bool _isLoading = true;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  void initState() {
    super.initState();
    getLocation();
  }
  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps"),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right:5.0),
            child: Container(
              color: Colors.white,
              child:IconButton(
                onPressed: () {
                  onDirectionClicked();
                },
                icon: Icon(
                  Icons.directions,
                  color: Colors.blue,
                ),
                iconSize: 20.0,
              ),),),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 12.0,
        ),
        markers: {
          const Marker(
            markerId: const MarkerId("FINKI"),
            position: LatLng(42.00423999005344, 21.409542876011876),
            infoWindow: InfoWindow(
              // given title for marker
              title: 'Faculty of Computer Science & Engineering',
            ),
          ), // Marker
        }, // markers
      ),
    );
  }
  onDirectionClicked(){
    String url = 'https://www.google.com/maps/dir/?api=1&origin=' +
        _currentPosition.latitude.toString() +
        ',' +
        _currentPosition.longitude.toString() +
        ' &destination=' +
        "42.00423999005344" +
        ',' +
        "21.409542876011876" +
        '&travelmode=driving&dir_action=navigate';

    _launchURL(url);
  }
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}