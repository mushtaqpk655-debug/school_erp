class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String studentClass;
  final String parentName;
  final String phoneNumber;

  // ADD THESE THREE FIELDS:
  final double totalFee;
  final double paidAmount;
  final String feeStatus;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.studentClass,
    required this.parentName,
    required this.phoneNumber,
    this.totalFee = 0.0,      // Default to 0
    this.paidAmount = 0.0,    // Default to 0
    this.feeStatus = "Pending", // Default to Pending
  });

  // Update your toJson
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rollNumber': rollNumber,
    'studentClass': studentClass,
    'parentName': parentName,
    'phoneNumber': phoneNumber,
    'totalFee': totalFee,
    'paidAmount': paidAmount,
    'feeStatus': feeStatus,
  };

  // Update your fromJson
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    name: json['name'],
    rollNumber: json['rollNumber'],
    studentClass: json['studentClass'],
    parentName: json['parentName'],
    phoneNumber: json['phoneNumber'],
    totalFee: (json['totalFee'] ?? 0.0).toDouble(),
    paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
    feeStatus: json['feeStatus'] ?? "Pending",
  );
}