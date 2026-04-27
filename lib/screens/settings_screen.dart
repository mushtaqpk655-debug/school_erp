import 'package:flutter/material.dart';
import '../models/school_model.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<SchoolProfile>(
        stream: _db.schoolProfileStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final profile = snapshot.data!;
          _nameController.text = profile.schoolName;
          _yearController.text = profile.academicYear;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Text("School Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "School Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: "Academic Year (e.g. 2026-2027)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.all(15)),
                  onPressed: () async {
                    final updated = SchoolProfile(
                      schoolName: _nameController.text,
                      principalName: profile.principalName,
                      contactNumber: profile.contactNumber,
                      address: profile.address,
                      academicYear: _yearController.text,
                    );
                    await _db.updateSchoolProfile(updated);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Settings Saved!")));
                  },
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}