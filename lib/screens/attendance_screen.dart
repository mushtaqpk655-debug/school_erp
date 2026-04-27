import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseService _db = DatabaseService();
  final Map<String, bool> _attendanceMap = {}; // Stores {studentId: isPresent}
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Mark Attendance: $formattedDate"),
        backgroundColor: Colors.green, // Matching your Home Screen card color
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Student>>(
        stream: _db.studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No students found. Add students first!"));
          }

          final students = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    // Default to 'true' (Present) if not yet changed by user
                    _attendanceMap.putIfAbsent(student.id, () => true);

                    return CheckboxListTile(
                      title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Roll: ${student.rollNumber}"),
                      activeColor: Colors.green,
                      value: _attendanceMap[student.id],
                      onChanged: (bool? value) {
                        setState(() {
                          _attendanceMap[student.id] = value!;
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    // This calls the function in your DatabaseService
                    await _db.saveAttendance(formattedDate, _attendanceMap);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Attendance saved for $formattedDate")),
                      );
                      Navigator.pop(context); // Go back to Home Screen
                    }
                  },
                  child: const Text("SAVE ATTENDANCE",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}