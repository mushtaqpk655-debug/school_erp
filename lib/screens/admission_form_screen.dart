import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/database_service.dart';

class AdmissionFormScreen extends StatefulWidget {
  final Student? studentToEdit;

  const AdmissionFormScreen({super.key, this.studentToEdit});

  @override
  State<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends State<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture the input
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _rollController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController(); // NEW: Fee Controller

  @override
  void initState() {
    super.initState();

    if (widget.studentToEdit != null) {
      _nameController.text = widget.studentToEdit!.name;
      _classController.text = widget.studentToEdit!.studentClass;
      _rollController.text = widget.studentToEdit!.rollNumber;
      _phoneController.text = widget.studentToEdit!.phoneNumber;
      _feeController.text = widget.studentToEdit!.totalFee.toString(); // Load existing fee
    } else {
      _feeController.text = "0.0"; // Default value for new students
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentToEdit != null ? "Edit Student" : "Student Admission"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Enter Student Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter a name" : null,
              ),
              const SizedBox(height: 15),

              // Class Field
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(labelText: "Class (e.g. 10-A)", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Please enter a class" : null,
              ),
              const SizedBox(height: 15),

              // Roll Number Field
              TextFormField(
                controller: _rollController,
                decoration: const InputDecoration(labelText: "Roll Number", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Please enter a roll number" : null,
              ),
              const SizedBox(height: 15),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Parent Phone", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Please enter a phone number" : null,
              ),
              const SizedBox(height: 15),

              // NEW: Total Fee Field
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(
                  labelText: "Total Annual Fee (AED)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Please enter the total fee" : null,
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    // Create the student object with the fee data
                    final student = Student(
                      id: widget.studentToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      studentClass: _classController.text,
                      rollNumber: _rollController.text,
                      parentName: "Parent Name",
                      phoneNumber: _phoneController.text,
                      // FINANCIAL DATA:
                      totalFee: double.tryParse(_feeController.text) ?? 0.0,
                      paidAmount: widget.studentToEdit?.paidAmount ?? 0.0, // Keep old payment if editing
                      feeStatus: widget.studentToEdit?.feeStatus ?? "Pending",
                    );

                    await DatabaseService().saveStudent(student);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Student Data Saved Successfully!")),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.all(15)
                ),
                child: const Text("Confirm Admission", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}