import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class StaffFormScreen extends StatefulWidget {
  final Staff? staffToEdit;

  const StaffFormScreen({super.key, this.staffToEdit});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();

  // Controllers
  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _joinDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    if (widget.staffToEdit != null) {
      _nameController.text = widget.staffToEdit!.name;
      _designationController.text = widget.staffToEdit!.designation;
      _phoneController.text = widget.staffToEdit!.phoneNumber;
      _emailController.text = widget.staffToEdit!.email;
      _joinDate = widget.staffToEdit!.joinDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staffToEdit != null ? "Edit Staff" : "Add New Staff"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Staff Personal Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildTextField(_nameController, "Full Name", Icons.person),
              const SizedBox(height: 15),

              _buildTextField(_designationController, "Designation (e.g. Math Teacher)", Icons.work),
              const SizedBox(height: 15),

              _buildTextField(_phoneController, "Phone Number", Icons.phone, keyboard: TextInputType.phone),
              const SizedBox(height: 15),

              _buildTextField(_emailController, "Email Address", Icons.email, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 15),

              // Date Picker Tile
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text("Joining Date"),
                subtitle: Text(_joinDate),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _joinDate = DateFormat('yyyy-MM-dd').format(picked));
                  }
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final staff = Staff(
                      id: widget.staffToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      designation: _designationController.text,
                      phoneNumber: _phoneController.text,
                      email: _emailController.text,
                      joinDate: _joinDate,
                    );

                    await _db.saveStaff(staff);
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Save Staff Member", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? "Required field" : null,
    );
  }
}