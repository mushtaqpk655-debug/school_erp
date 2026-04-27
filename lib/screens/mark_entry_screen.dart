import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/exam_model.dart';
import '../services/database_service.dart';

class MarkEntryScreen extends StatefulWidget {
  const MarkEntryScreen({super.key});

  @override
  State<MarkEntryScreen> createState() => _MarkEntryScreenState();
}

class _MarkEntryScreenState extends State<MarkEntryScreen> {
  final DatabaseService _db = DatabaseService();
  String _selectedSubject = "Mathematics";
  String _selectedTerm = "Mid-Term 2026";

  // To store the marks and names entered by the user temporarily
  final Map<String, double> _marksMap = {};
  final Map<String, String> _namesMap = {}; // Added to keep track of names for saving

  final List<String> _subjects = ["Mathematics", "Science", "English", "Arabic", "ICT"];
  final List<String> _terms = ["Mid-Term 2026", "Final Exam 2026"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Marks"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Selectors for Subject and Term
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedSubject,
                    decoration: const InputDecoration(labelText: "Subject", border: OutlineInputBorder()),
                    items: _subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedSubject = val.toString()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedTerm,
                    decoration: const InputDecoration(labelText: "Term", border: OutlineInputBorder()),
                    items: _terms.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedTerm = val.toString()),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _db.studentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No students found to enter marks."));
                }

                final students = snapshot.data!;

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];

                    // Map IDs to Names so we can access them in the Save button
                    _namesMap[student.id] = student.name;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Roll: ${student.rollNumber}"),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: "Score",
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (val) {
                              _marksMap[student.id] = double.tryParse(val) ?? 0.0;
                            },
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            if (_marksMap.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No marks entered to save.")),
              );
              return;
            }

            // Show a loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );

            // Save all entered marks from the map
            for (var studentId in _marksMap.keys) {
              final result = ExamResult(
                id: "", // Service handles unique ID
                studentId: studentId,
                studentName: _namesMap[studentId] ?? "Unknown",
                subject: _selectedSubject,
                marksObtained: _marksMap[studentId]!,
                totalMarks: 100.0,
                examTerm: _selectedTerm,
              );
              await _db.saveExamResult(result);
            }

            if (mounted) {
              Navigator.pop(context); // Close loading indicator
              Navigator.pop(context); // Go back to Home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All marks saved successfully!")),
              );
            }
          },
          child: const Text("Confirm & Save All Marks",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}