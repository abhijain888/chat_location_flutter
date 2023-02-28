import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class LocationController extends GetxController {
  final User user;

  final loc.Location _location = loc.Location();

  final RxDouble _lat = 0.0.obs;
  final RxDouble _long = 0.0.obs;
  final RxString _address = "".obs;

  double get lat => _lat.value;
  double get long => _long.value;
  String get address => _address.value;

  LocationController({required this.user});

  @override
  void onInit() {
    _location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      distanceFilter: 4,
      interval: 999,
    );

    super.onInit();
  }

  void startStream() => _startStream();

  void _startStream() {
    _location.onLocationChanged.listen((data) {
      _lat.value = data.latitude!;
      _long.value = data.longitude!;

      FirebaseFirestore.instance.collection("location").doc(user.uid).update({
        "lat": data.latitude.toString(),
        "long": data.longitude.toString(),
      });

      // _getAddressFromCoord(_lat.value, _long.value)
      //     .then((value) => _address.value = value);
    });

    print("started streaming");
  }

  Future<String> _getAddressFromCoord(double lat, double long) async =>
      await placemarkFromCoordinates(lat, long).then((placemarks) =>
          "${placemarks[0].name} ${placemarks[0].subLocality}, ${placemarks[0].locality}");
}
