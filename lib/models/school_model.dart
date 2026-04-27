class SchoolProfile {
  final String schoolName;
  final String principalName;
  final String contactNumber;
  final String address;
  final String academicYear;

  SchoolProfile({
    required this.schoolName,
    required this.principalName,
    required this.contactNumber,
    required this.address,
    required this.academicYear,
  });

  Map<String, dynamic> toJson() => {
    'schoolName': schoolName,
    'principalName': principalName,
    'contactNumber': contactNumber,
    'address': address,
    'academicYear': academicYear,
  };

  factory SchoolProfile.fromJson(Map<String, dynamic> json) => SchoolProfile(
    // FIXED: Removed the id line that was causing the error
    schoolName: json['schoolName'] ?? "School Name",
    principalName: json['principalName'] ?? "Principal Name",
    contactNumber: json['contactNumber'] ?? "000",
    address: json['address'] ?? "Address",
    academicYear: json['academicYear'] ?? "2026",
  );
}