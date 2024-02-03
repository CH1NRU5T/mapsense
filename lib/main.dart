import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mapsense/features/auth/screens/auth_screen.dart';
import 'package:mapsense/features/home/screens/home_screen.dart';
import 'package:mapsense/firebase_options.dart';
import 'package:mapsense/providers/location_provider.dart';
import 'package:mapsense/router.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await openDatabase(
    join(await getDatabasesPath(), 'saved_locations_database.db'),
    onCreate: (db, _) async {
      return await db.execute(
        'CREATE TABLE saved_locations(id TEXT PRIMARY KEY, latitude DOUBLE, longitude DOUBLE, createdBy TEXT)',
      );
    },
    version: 1,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => LocationProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) => generateRoute(settings),
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
