import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/student_model.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final DatabaseService _db = DatabaseService();
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _attendanceData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Load today's history by default
  }

  // Fetch the record from Firebase for the chosen date
  void _fetchHistory() async {
    setState(() => _isLoading = true);
    String date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final data = await _db.getAttendanceByDate(date);
    setState(() {
      _attendanceData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Date Selection Tile
          Container(
            color: Colors.orange[50],
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.orange),
              title: Text("Showing records for: $formattedDate",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _fetchHistory();
                }
              },
            ),
          ),
          const Divider(height: 1),

          // Result Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _attendanceData == null
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No records found for this date.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
                : StreamBuilder<List<Student>>(
              stream: _db.studentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final students = snapshot.data!;
                final records = _attendanceData!['records'] as Map<String, dynamic>;

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    // Check if student exists in the record, default to false if not
                    final isPresent = records[student.id] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPresent ? Colors.green[100] : Colors.red[100],
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text("Roll: ${student.rollNumber}"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPresent ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPresent ? "PRESENT" : "ABSENT",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}