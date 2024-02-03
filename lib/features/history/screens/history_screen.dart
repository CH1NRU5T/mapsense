import 'package:flutter/material.dart';
import 'package:mapsense/providers/location_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  static const routeName = '/history';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<LocationProvider>(
          builder: (context, provider, _) {
            return ListView.builder(
              itemCount: provider.locations?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Location ${index + 1}'),
                  subtitle: Text(
                    'Latitude: ${provider.locations![index].latitude}, Longitude: ${provider.locations![index].longitude}',
                  ),
                );
              },
            );
          },
        ),
      ),
    ));
  }
}
