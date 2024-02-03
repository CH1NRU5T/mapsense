import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapsense/features/history/screens/history_screen.dart';
import 'package:mapsense/models/saved_location_model.dart';
import 'package:mapsense/providers/location_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String DB_NAME = 'saved_locations_database.db';
  final String TABLE_NAME = 'saved_locations';
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(373.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final List<SavedLocation> savedLocations = await _getSavedLocations();
    final List<LatLng> locations = savedLocations
        .map(
          (location) => LatLng(location.latitude, location.longitude),
        )
        .toList();
    if (mounted) {
      this.context.read<LocationProvider>().locations = locations;
    }
  }

  Future<List<SavedLocation>> _getSavedLocations() async {
    try {
      return FirebaseFirestore.instance
          .collection(TABLE_NAME)
          .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((snapshot) {
        return snapshot.docs
            .map(
              (doc) => SavedLocation.fromMap(doc.data()),
            )
            .toList();
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  void _markClicked() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    SavedLocation savedLocation = SavedLocation(
      id: const Uuid().v4(),
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
      createdBy: FirebaseAuth.instance.currentUser!.uid,
    );

    // add the location to offline db
    _addCurrentPositionToLocalDB(savedLocation);

    // add the location to firestore
    _addCurrentPositionToServer(savedLocation);

    // mark the location on the map
    if (mounted) {
      this.context.read<LocationProvider>().addLocation(
            LatLng(savedLocation.latitude, savedLocation.longitude),
          );
    }

    // move the camera to the marked location
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(savedLocation.latitude, savedLocation.longitude),
          zoom: 18,
        ),
      ),
    );
  }

  void _addCurrentPositionToServer(SavedLocation currentPosition) async {
    await FirebaseFirestore.instance
        .collection(TABLE_NAME)
        .doc(currentPosition.id)
        .set(currentPosition.toMap());
  }

  Database? database;

  void _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), DB_NAME),
      onCreate: (db, _) {},
      version: 1,
    );
    setState(() {});
  }

  void _addCurrentPositionToLocalDB(SavedLocation currentPosition) async {
    if (database == null) {
      _initDatabase();
    }
    await database!.insert(TABLE_NAME, currentPosition.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Row(
          children: [
            FloatingActionButton(
              onPressed: () async {
                _markClicked();
              },
              child: const Icon(Icons.center_focus_strong),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () async {
                Navigator.pushNamed(context, HistoryScreen.routeName);
              },
              child: const Icon(Icons.history),
            ),
          ],
        ),
        appBar: AppBar(
          title: const Text('Mapsense'),
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Consumer<LocationProvider>(builder: (context, provider, _) {
          return provider.locations == null
              ? const CircularProgressIndicator()
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  markers: provider.locations!
                      .map(
                        (location) => Marker(
                          markerId: MarkerId(location.toString()),
                          position: location,
                        ),
                      )
                      .toSet(),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('line'),
                      width: 2,
                      color: Colors.blue,
                      points: provider.locations!,
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                );
        }),
      ),
    );
  }
}
