import 'package:flutter/material.dart';
import '../models/transport_model.dart';
import '../services/database_service.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transport & Bus Routes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<TransportRoute>>(
        stream: db.transportStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final routes = snapshot.data!;

          if (routes.isEmpty) {
            return const Center(child: Text("No routes defined. Add a bus route."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.directions_bus, size: 40, color: Colors.redAccent),
                  title: Text(route.routeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Bus: ${route.busNumber} | Driver: ${route.driverName}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // We can add a "View Students on this Bus" list later
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _showAddRouteDialog(context, db),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddRouteDialog(BuildContext context, DatabaseService db) {
    final routeController = TextEditingController();
    final busController = TextEditingController();
    final driverController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Route"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: routeController, decoration: const InputDecoration(labelText: "Route Name")),
            TextField(controller: busController, decoration: const InputDecoration(labelText: "Bus Number")),
            TextField(controller: driverController, decoration: const InputDecoration(labelText: "Driver Name")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newRoute = TransportRoute(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                busNumber: busController.text,
                driverName: driverController.text,
                driverPhone: "", // Optional
                routeName: routeController.text,
                pickupTime: "07:00 AM",
              );
              await db.saveRoute(newRoute);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save Route"),
          ),
        ],
      ),
    );
  }
}