import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants.dart';

class TestLocationWidget extends StatefulWidget {
  final Position position;
  final User user;

  const TestLocationWidget({
    Key? key,
    required this.user,
    required this.position,
  }) : super(key: key);

  @override
  State<TestLocationWidget> createState() => _TestLocationWidgetState();
}

class _TestLocationWidgetState extends State<TestLocationWidget> {
  late final LatLng _initialLatLng;
  final Completer<GoogleMapController> _completer = Completer();

  late GoogleMapController _gmapController;

  String _myLocationAddress = "";

  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 3,
    timeLimit: Duration(milliseconds: 888),
  );

  void updateLocationToFirebase(double lat, double long) {
    FirebaseFirestore.instance
        .collection("location")
        .doc(widget.user.uid)
        .update({
      "lat": lat.toString(),
      "long": long.toString(),
    });

    print("updating location to database");
  }

  @override
  void initState() {
    _initialLatLng = LatLng(
      widget.position.latitude,
      widget.position.longitude,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<Position>(
            stream: Geolocator.getPositionStream(
                locationSettings: locationSettings),
            initialData: widget.position,
            builder: (context, snapshot) {
              Position pos = snapshot.data!;

              double latitude = pos.latitude;
              double longitude = pos.longitude;

              updateLocationToFirebase(latitude, longitude);

              _getAddressFromCoord(latitude, longitude).then(
                (value) {
                  _myLocationAddress = value;
                },
              );

              return Animarker(
                mapId: _completer.future.then<int>((value) => value.mapId),
                useRotation: false,
                duration: const Duration(milliseconds: 1111),
                markers: {
                  Marker(
                    markerId: const MarkerId("marker_id"),
                    position: LatLng(latitude, longitude),
                    draggable: false,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
                },
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialLatLng,
                    tilt: 10,
                    zoom: 16,
                  ),
                  compassEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) async {
                    _completer.complete(controller);
                    _gmapController = controller;

                    _myLocationAddress =
                        await _getAddressFromCoord(latitude, longitude);

                    setState(() {});

                    print("on map created...");
                  },
                ),
              );
            }),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.transparent,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print("search bar");
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        _myLocationAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    print('my location button');
                    final position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.bestForNavigation,
                    );

                    // setState(() {});

                    _gmapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          tilt: 10,
                          zoom: 18,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _getAddressFromCoord(double lat, double long) async =>
      await placemarkFromCoordinates(lat, long).then((placemarks) =>
          "${placemarks[0].name} ${placemarks[0].subLocality}, ${placemarks[0].locality}");

  @override
  void dispose() {
    _gmapController.dispose();

    super.dispose();
  }
}
