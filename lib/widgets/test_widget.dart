import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_project/test_controller.dart';

class LocationTestWidget2 extends StatefulWidget {
  final Position position;
  final User user;

  const LocationTestWidget2({
    Key? key,
    required this.user,
    required this.position,
  }) : super(key: key);

  @override
  State<LocationTestWidget2> createState() => _LocationTestWidget2State();
}

class _LocationTestWidget2State extends State<LocationTestWidget2> {
  late final LatLng _initialLatLng;
  final Completer<GoogleMapController> _completer = Completer();

  late GoogleMapController _gmapController;

  double lat = 0.0, long = 0.0;

  @override
  void initState() {
    lat = widget.position.latitude;
    long = widget.position.longitude;

    _initialLatLng = LatLng(
      lat,
      long,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locationController = Get.put(LocationController(user: widget.user));
    return GetX<LocationController>(
      builder: (c) {
        return Stack(
          children: [
            Animarker(
              mapId: _completer.future.then<int>((value) => value.mapId),
              useRotation: false,
              duration: const Duration(milliseconds: 2999),
              curve: Curves.linear,
              markers: {
                Marker(
                  markerId: const MarkerId("marker_id"),
                  position: LatLng(
                    locationController.lat,
                    locationController.long,
                  ),
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
                  zoom: 18.5,
                ),
                compassEnabled: false,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (controller) async {
                  locationController.startStream();

                  _completer.complete(controller);
                  _gmapController = controller;
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            locationController.address,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _gmapController.dispose();
    super.dispose();
  }
}
