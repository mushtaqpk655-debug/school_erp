class TransportRoute {
  final String id;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final String routeName; // e.g., "Al Reem Island - Route A"
  final String pickupTime;

  TransportRoute({
    required this.id,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.routeName,
    required this.pickupTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'busNumber': busNumber,
    'driverName': driverName,
    'driverPhone': driverPhone,
    'routeName': routeName,
    'pickupTime': pickupTime,
  };

  factory TransportRoute.fromJson(Map<String, dynamic> json) => TransportRoute(
    id: json['id'],
    busNumber: json['busNumber'],
    driverName: json['driverName'],
    driverPhone: json['driverPhone'],
    routeName: json['routeName'],
    pickupTime: json['pickupTime'],
  );
}