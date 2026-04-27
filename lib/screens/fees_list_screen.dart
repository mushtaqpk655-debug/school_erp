import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

class FeesListScreen extends StatefulWidget {
  const FeesListScreen({super.key});

  @override
  State<FeesListScreen> createState() => _FeesListScreenState();
}

class _FeesListScreenState extends State<FeesListScreen> {
  final DatabaseService _db = DatabaseService();

  // --- FUNCTION: THE PAYMENT DIALOG ---
  void _showPaymentDialog(Student student) {
    final TextEditingController feeController = TextEditingController();
    double currentBalance = student.totalFee - student.paidAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Collect Fee: ${student.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Assigned: AED ${student.totalFee}"),
            Text("Remaining Balance: AED $currentBalance",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 20),
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount Received",
                hintText: "e.g. 500",
                border: OutlineInputBorder(),
                prefixText: "AED ",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              double newPayment = double.tryParse(feeController.text) ?? 0.0;

              if (newPayment <= 0) {
                // Basic check to prevent empty or negative entries
                return;
              }

              double updatedPaid = student.paidAmount + newPayment;

              // Logic to determine status
              String newStatus = "Pending";
              if (updatedPaid >= student.totalFee) {
                newStatus = "Paid";
              } else if (updatedPaid > 0) {
                newStatus = "Partial";
              }

              // Create updated student object with new financial data
              Student updatedStudent = Student(
                id: student.id,
                name: student.name,
                rollNumber: student.rollNumber,
                studentClass: student.studentClass,
                parentName: student.parentName,
                phoneNumber: student.phoneNumber,
                totalFee: student.totalFee,
                paidAmount: updatedPaid,
                feeStatus: newStatus,
              );

              // Update Firebase
              await _db.saveStudent(updatedStudent);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Payment of AED $newPayment recorded for ${student.name}")),
                );
              }
            },
            child: const Text("Update Payment", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fees Management"),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Student>>(
        stream: _db.studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No student records found."));
          }

          final students = snapshot.data!;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              double balance = student.totalFee - student.paidAmount;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Total Fee: AED ${student.totalFee}"),
                      Text("Paid: AED ${student.paidAmount}", style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Bal: AED $balance",
                        style: TextStyle(
                          color: balance > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _statusBadge(student.feeStatus),
                    ],
                  ),
                  onTap: () => _showPaymentDialog(student),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.red;
    if (status == "Paid") color = Colors.green;
    if (status == "Partial") color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}