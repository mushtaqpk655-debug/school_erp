import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// Models
import '../models/book_model.dart';
import '../models/exam_model.dart';
import '../models/school_model.dart';
import '../models/staff_model.dart';
import '../models/student_model.dart';
import '../models/transport_model.dart';

class DatabaseService {
  // --- INITIALIZATION ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;



  // --- COLLECTION REFERENCES ---
  // These are shortcuts to your Firestore folders
  final CollectionReference _studentCollection = FirebaseFirestore.instance.collection('students');
  final CollectionReference _staffCollection = FirebaseFirestore.instance.collection('staff');
  final CollectionReference _bookCollection = FirebaseFirestore.instance.collection('books');
  final CollectionReference _examCollection = FirebaseFirestore.instance.collection('exam_results');
  final CollectionReference _transportCollection = FirebaseFirestore.instance.collection('transport');
  final CollectionReference _settingsCollection = FirebaseFirestore.instance.collection('settings');
  final CollectionReference _attendanceCollection = FirebaseFirestore.instance.collection('attendance');

  // ==========================================
  // 1. AUTHENTICATION SECTION
  // ==========================================

  /// Signs in the user using Firebase Auth
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      debugPrint("Login Error: ${e.toString()}");
      return null;
    }
  }

  /// Logs the current user out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Listens to login/logout changes
  Stream<User?> get userStatus => _auth.authStateChanges();

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Reset Error: ${e.toString()}");
      rethrow; // Pass the error to the UI to show a message
    }
  }

  // ==========================================
  // 2. STUDENT MANAGEMENT SECTION
  // ==========================================

  /// Gets a live list of all students
  Stream<List<Student>> get studentsStream {
    return _studentCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Adds a new student or updates an existing one
  Future<void> saveStudent(Student student) async {
    await _studentCollection.doc(student.id).set(student.toJson());
  }

  /// Removes a student from the system
  Future<void> deleteStudent(String id) async {
    await _studentCollection.doc(id).delete();
  }

  // ==========================================
  // 3. STAFF MANAGEMENT SECTION
  // ==========================================

  /// Gets a live list of all staff members
  Stream<List<Staff>> get staffStream {
    return _staffCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Staff.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> saveStaff(Staff staff) async {
    await _staffCollection.doc(staff.id).set(staff.toJson());
  }

  Future<void> deleteStaff(String id) async {
    await _staffCollection.doc(id).delete();
  }

  // ==========================================
  // 4. EXAMS & REPORT CARDS SECTION
  // ==========================================

  /// Saves exam marks. Prevents duplicates by creating a unique ID
  Future<void> saveExamResult(ExamResult result) async {
    String uniqueId = "${result.studentId}_${result.subject}_${result.examTerm}";
    await _examCollection.doc(uniqueId).set(result.toJson());
  }

  /// Fetches marks for a specific student only
  Stream<List<ExamResult>> getStudentResults(String studentId) {
    return _examCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ExamResult.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // ==========================================
  // 5. LIBRARY MANAGEMENT SECTION
  // ==========================================

  Stream<List<Book>> get booksStream {
    return _bookCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> saveBook(Book book) async {
    await _bookCollection.doc(book.id).set(book.toJson());
  }

  Future<void> issueBook(String bookId, String studentId, String date) async {
    await _bookCollection.doc(bookId).update({
      'isAvailable': false,
      'borrowedBy': studentId,
      'dueDate': date,
    });
  }

  Future<void> returnBook(String bookId) async {
    await _bookCollection.doc(bookId).update({
      'isAvailable': true,
      'borrowedBy': null,
      'dueDate': null,
    });
  }

  // ==========================================
  // 6. TRANSPORT SECTION
  // ==========================================

  Stream<List<TransportRoute>> get transportStream {
    return _transportCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TransportRoute.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> saveRoute(TransportRoute route) async {
    await _transportCollection.doc(route.id).set(route.toJson());
  }

  // ==========================================
  // 7. ATTENDANCE SECTION
  // ==========================================

  Future<void> saveAttendance(String date, Map<String, bool> attendanceData) async {
    try {
      await _attendanceCollection.doc(date).set({
        'date': date,
        'records': attendanceData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving attendance: $e");
    }
  }

  Future<Map<String, dynamic>?> getAttendanceByDate(String date) async {
    try {
      DocumentSnapshot doc = await _attendanceCollection.doc(date).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
    }
    return null;
  }

  // ==========================================
  // 8. DASHBOARD & SETTINGS SECTION
  // ==========================================

  /// Update Global School Settings
  Future<void> updateSchoolProfile(SchoolProfile profile) async {
    await _settingsCollection.doc('profile').set(profile.toJson());
  }

  /// Get School Profile (or default if empty)
  Stream<SchoolProfile> get schoolProfileStream {
    return _settingsCollection.doc('profile').snapshots().map((doc) {
      if (doc.exists) {
        return SchoolProfile.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return SchoolProfile(
          schoolName: "My School ERP",
          principalName: "Admin",
          contactNumber: "00000000",
          address: "UAE",
          academicYear: "2026",
        );
      }
    });
  }

  /// Dashboard Stat: Count total students
  Future<int> getTotalStudentCount() async {
    final snapshot = await _studentCollection.get();
    return snapshot.docs.length;
  }

  /// Dashboard Stat: Sum all paid fees
  Future<double> getTotalFeesCollected() async {
    final snapshot = await _studentCollection.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data() as Map<String, dynamic>)['paidAmount'] ?? 0.0;
    }
    return total;
  }
}