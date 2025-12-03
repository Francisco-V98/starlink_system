import 'dart:convert';

class ClientGroup {
  final String email;
  final String alias;
  final List<User> users;
  final String? adminId; // ID of the admin who owns this group

  ClientGroup({
    required this.email,
    required this.alias,
    required this.users,
    this.adminId,
  });

  factory ClientGroup.fromJson(Map<String, dynamic> json) {
    return ClientGroup(
      email: json['email'] ?? '',
      alias: json['alias'] ?? '',
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e))
              .toList() ??
          [],
      adminId: json['adminId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'alias': alias,
      'users': users.map((e) => e.toJson()).toList(),
      'adminId': adminId,
    };
  }

  ClientGroup copyWith({
    String? email,
    String? alias,
    List<User>? users,
    String? adminId,
  }) {
    return ClientGroup(
      email: email ?? this.email,
      alias: alias ?? this.alias,
      users: users ?? this.users,
      adminId: adminId ?? this.adminId,
    );
  }
}

class User {
  final int id;
  final String name;
  final String plan;
  final String country;
  final String phoneNumber;
  final String antennaSerial;
  final int paymentStartDay;
  final int paymentEndDay;
  final Map<String, String> payments; // Changed to String to store date
  final String? note;
  final DateTime? serviceStartDate;

  User({
    required this.id,
    required this.name,
    required this.plan,
    required this.country,
    required this.phoneNumber,
    required this.antennaSerial,
    required this.paymentStartDay,
    required this.paymentEndDay,
    required this.payments,
    this.note,
    this.serviceStartDate,
  });

  String get range => '$paymentStartDay al $paymentEndDay';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      plan: json['plan'] ?? '',
      country: json['country'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      antennaSerial: json['antennaSerial'] ?? '',
      paymentStartDay: json['paymentStartDay'] ?? 1,
      paymentEndDay: json['paymentEndDay'] ?? 5,
      payments: Map<String, String>.from(json['payments'] ?? {}),
      note: json['note'],
      serviceStartDate: json['serviceStartDate'] != null
          ? DateTime.parse(json['serviceStartDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plan': plan,
      'country': country,
      'phoneNumber': phoneNumber,
      'antennaSerial': antennaSerial,
      'paymentStartDay': paymentStartDay,
      'paymentEndDay': paymentEndDay,
      'payments': payments,
      'note': note,
      'serviceStartDate': serviceStartDate?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? plan,
    String? country,
    String? phoneNumber,
    String? antennaSerial,
    int? paymentStartDay,
    int? paymentEndDay,
    Map<String, String>? payments,
    String? note,
    DateTime? serviceStartDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      antennaSerial: antennaSerial ?? this.antennaSerial,
      paymentStartDay: paymentStartDay ?? this.paymentStartDay,
      paymentEndDay: paymentEndDay ?? this.paymentEndDay,
      payments: payments ?? this.payments,
      note: note ?? this.note,
      serviceStartDate: serviceStartDate ?? this.serviceStartDate,
    );
  }
}
