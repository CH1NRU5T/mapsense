import 'package:flutter/material.dart';
import 'package:mapsense/features/auth/screens/auth_screen.dart';
import 'package:mapsense/features/history/screens/history_screen.dart';
import 'package:mapsense/features/home/screens/home_screen.dart';

generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case HomeScreen.routeName:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case HistoryScreen.routeName:
      return MaterialPageRoute(builder: (context) => const HistoryScreen());
    case AuthScreen.routeName:
      return MaterialPageRoute(builder: (context) => const AuthScreen());
    default:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
  }
}
