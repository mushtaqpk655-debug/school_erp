class ExamResult {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final double marksObtained;
  final double totalMarks;
  final String examTerm; // e.g., "First Term 2026"

  ExamResult({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
    required this.examTerm,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'subject': subject,
    'marksObtained': marksObtained,
    'totalMarks': totalMarks,
    'examTerm': examTerm,
  };

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
    id: json['id'],
    studentId: json['studentId'],
    studentName: json['studentName'],
    subject: json['subject'],
    marksObtained: (json['marksObtained'] ?? 0.0).toDouble(),
    totalMarks: (json['totalMarks'] ?? 100.0).toDouble(),
    examTerm: json['examTerm'],
  );
}