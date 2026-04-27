import 'package:flutter/material.dart';
import 'package:school_erp/screens/staff_form_screen.dart';
import '../models/staff_model.dart';
import '../services/database_service.dart';

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Management"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<List<Staff>>(
        stream: db.staffStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final staffList = snapshot.data!;

          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              // Inside ListView.builder in staff_list_screen.dart
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(staff.name),
                  subtitle: Text(staff.designation),
                  onTap: () {
                    // Edit logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StaffFormScreen(staffToEdit: staff)),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => db.deleteStaff(staff.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}