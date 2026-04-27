import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/exam_model.dart';
import '../services/database_service.dart';

class ReportCardScreen extends StatelessWidget {
  final Student student;
  const ReportCardScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text("${student.name}'s Report"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          // Header with Student Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.purple[50],
            child: Column(
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                const SizedBox(height: 10),
                Text(student.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Class: ${student.studentClass} | Roll: ${student.rollNumber}"),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Academic Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: StreamBuilder<List<ExamResult>>(
              stream: db.getStudentResults(student.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final results = snapshot.data!;
                if (results.isEmpty) {
                  return const Center(child: Text("No exam results found for this student."));
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    double percentage = (res.marksObtained / res.totalMarks) * 100;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        title: Text(res.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(res.examTerm),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${res.marksObtained} / ${res.totalMarks}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${percentage.toStringAsFixed(1)}%",
                                style: TextStyle(color: percentage >= 50 ? Colors.green : Colors.red)),
                          ],
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