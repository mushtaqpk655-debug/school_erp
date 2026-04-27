import 'package:flutter/material.dart';
import 'package:school_erp/screens/student_profile_screen.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';
import 'admission_form_screen.dart';
import 'attendance_screen.dart';
import 'report_card_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // --- RESTORED: DELETE FUNCTION ---
  void _deleteStudent(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to remove this student? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _db.deleteStudent(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Student removed successfully")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- RESTORED: EDIT FUNCTION ---
  void _editStudent(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdmissionFormScreen(studentToEdit: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search students...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = "";
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.assignment_turned_in),
            tooltip: "Take Attendance",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AttendanceScreen()),
              );
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
          if (snapshot.hasError) return const Center(child: Text("Error connecting to database"));

          final cloudStudents = snapshot.data ?? [];
          final filteredStudents = cloudStudents.where((student) {
            return student.name.toLowerCase().contains(_searchQuery);
          }).toList();

          if (cloudStudents.isEmpty) {
            return const Center(child: Text("No students found. Tap + to add one!"));
          }
          if (filteredStudents.isEmpty) {
            return const Center(child: Text("No matching students found."));
          }

          return ListView.builder(
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              final student = filteredStudents[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 2,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentProfileScreen(student: student),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Text(
                      student.name.isNotEmpty ? student.name[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Class: ${student.studentClass} | Roll: ${student.rollNumber}"),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editStudent(student);
                      } else if (value == 'delete') {
                        _deleteStudent(student.id);
                      } else if (value == 'report') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportCardScreen(student: student),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.assignment, color: Colors.purple),
                            SizedBox(width: 10),
                            Text("View Report Card"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 10),
                            Text("Edit Info"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Remove Student"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdmissionFormScreen()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}