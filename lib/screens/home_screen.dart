import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_erp/screens/settings_screen.dart';
import 'package:school_erp/screens/staff_list_screen.dart';
import 'package:school_erp/screens/transport_screen.dart';
import 'fees_list_screen.dart';
import 'library_screen.dart';
import 'mark_entry_screen.dart';
import 'student_list_screen.dart';
import 'attendance_screen.dart';
import 'attendance_history_screen.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();

  // Variables to hold our dashboard numbers
  int _totalStudents = 0;
  double _totalFees = 0.0;
  String _attendanceRate = "0%";

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  // Fetch all live data from Firebase
  Future<void> _loadDashboardStats() async {
    final students = await _db.getTotalStudentCount();
    final fees = await _db.getTotalFeesCollected();

    // Get today's attendance rate
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final attendanceData = await _db.getAttendanceByDate(today);

    String rate = "N/A";
    if (attendanceData != null && students > 0) {
      final records = attendanceData['records'] as Map<String, dynamic>;
      int presentCount = records.values.where((v) => v == true).length;
      rate = "${((presentCount / students) * 100).toStringAsFixed(0)}%";
    }

    if (mounted) {
      setState(() {
        _totalStudents = students;
        _totalFees = fees;
        _attendanceRate = rate;
      });
    }
  }

  void _showAttendanceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Attendance Management",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_calendar, color: Colors.green),
                title: const Text("Mark Today's Attendance"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.blue),
                title: const Text("View Attendance History"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("School ERP Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardStats, // Manual refresh button
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Top Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1976D2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Color(0xFF1976D2))),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome, Admin Mushtaq",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Academic Year: 2026-27", style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // NEW: STATS ROW
              SizedBox(
                height: 110,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatCard("Total Students", _totalStudents.toString(), Icons.groups, Colors.orange),
                    _buildStatCard("Fees Collected", "AED ${_totalFees.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.teal),
                    _buildStatCard("Today's Presence", _attendanceRate, Icons.fact_check, Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // The Grid of Modules
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(context, "Students", Icons.school, Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentListScreen()));
                  }),
                  _buildMenuCard(context, "Staff", Icons.people, Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaffListScreen()),
                    );
                  }),
                  _buildMenuCard(context, "Attendance", Icons.calendar_month, Colors.green, () {
                    _showAttendanceOptions(context);
                  }),
                  _buildMenuCard(context, "Fees", Icons.monetization_on, Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FeesListScreen()));
                  }),
                  _buildMenuCard(context, "Exams", Icons.assignment, Colors.purple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MarkEntryScreen()),
                    );
                  }),
                  _buildMenuCard(context, "Library", Icons.menu_book, Colors.brown, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LibraryScreen()),
                    );
                  }),
                  _buildMenuCard(context, "Transport", Icons.directions_bus, Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransportScreen()),
                    );
                  }),
                  _buildMenuCard(context, "Settings", Icons.settings, Colors.blueGrey, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}