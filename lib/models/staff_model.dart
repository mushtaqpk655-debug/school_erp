class Staff {
  final String id;
  final String name;
  final String designation; // e.g., Primary Teacher, Security, Admin
  final String phoneNumber;
  final String email;
  final String joinDate;

  Staff({
    required this.id,
    required this.name,
    required this.designation,
    required this.phoneNumber,
    required this.email,
    required this.joinDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'designation': designation,
    'phoneNumber': phoneNumber,
    'email': email,
    'joinDate': joinDate,
  };

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json['id'],
    name: json['name'],
    designation: json['designation'],
    phoneNumber: json['phoneNumber'],
    email: json['email'],
    joinDate: json['joinDate'],
  );
}