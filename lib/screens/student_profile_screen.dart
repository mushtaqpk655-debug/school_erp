import 'package:flutter/material.dart';
import '../models/student_model.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${student.name}'s Profile"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              color: Colors.orange[50],
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orange,
                    child: Text(
                      student.name[0],
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    student.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text("Roll Number: ${student.rollNumber}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _profileInfoTile(Icons.class_, "Class", student.studentClass),
                  _profileInfoTile(Icons.person, "Parent Name", student.parentName),
                  _profileInfoTile(Icons.phone, "Phone Number", student.phoneNumber),

                  const Divider(height: 40),

                  // Future section for Attendance Stats
                  const ListTile(
                    leading: Icon(Icons.analytics, color: Colors.orange),
                    title: Text("Attendance Summary"),
                    subtitle: Text("Coming Soon: View monthly percentage"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
    );
  }
}