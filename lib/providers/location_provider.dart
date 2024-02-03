import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  LocationProvider() {
    _locations = [];
    notifyListeners();
  }
  List<LatLng>? _locations;
  List<LatLng>? get locations => _locations;
  set locations(List<LatLng>? value) {
    _locations = value;
    notifyListeners();
  }

  void addLocation(LatLng location) {
    _locations ??= [];
    _locations!.add(location);
    notifyListeners();
  }
}
