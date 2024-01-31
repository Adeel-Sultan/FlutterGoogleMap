import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String mapStyle = '';
  Location location = Location();

  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.6941, 72.9734),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();

    DefaultAssetBundle.of(context)
        .loadString('asset/day_style.json')
        .then((string) {
      mapStyle = string;
    }).catchError((error) {
      debugPrint("error$error");
    });
    location.onLocationChanged.listen((LocationData locationData) {
      _updateCurrentLocationMarker(
          locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        actions: <Widget>[
          // This button presents popup menu items.
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString('asset/day_style.json')
                              .then((string) {
                            setState(() {});
                            value.setMapStyle(string);
                          });
                        }).catchError((error) {
                          debugPrint("error$error");
                        });
                      },
                      value: 1,
                      child: const Text("Day"),
                    ),
                    PopupMenuItem(
                      onTap: () async {
                        _controller.future.then((value) {
                          DefaultAssetBundle.of(context)
                              .loadString('asset/night_style.json')
                              .then((string) {
                            setState(() {});
                            value.setMapStyle(string);
                          });
                        }).catchError((error) {
                          debugPrint("error$error");
                        });
                      },
                      value: 2,
                      child: const Text("Night"),
                    )
                  ])
        ],
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            controller.setMapStyle(mapStyle);
            _controller.complete(controller);
          },
          markers: <Marker>{currentLocationMarker},
        ),
      ),
    );
  }

  Marker currentLocationMarker = Marker(
    markerId: const MarkerId('current_location'),
    position: const LatLng(0.0, 0.0),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  );

  void _updateCurrentLocationMarker(double latitude, double longitude) {
    setState(() {
      currentLocationMarker = currentLocationMarker.copyWith(
        positionParam: LatLng(latitude, longitude),
      );
    });
  }
}
