import 'dart:convert';

class ClientGroup {
  final String email;
  final String alias;
  final List<User> users;

  ClientGroup({
    required this.email,
    required this.alias,
    required this.users,
  });

  factory ClientGroup.fromJson(Map<String, dynamic> json) {
    return ClientGroup(
      email: json['email'] ?? '',
      alias: json['alias'] ?? '',
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'alias': alias,
      'users': users.map((e) => e.toJson()).toList(),
    };
  }

  ClientGroup copyWith({
    String? email,
    String? alias,
    List<User>? users,
  }) {
    return ClientGroup(
      email: email ?? this.email,
      alias: alias ?? this.alias,
      users: users ?? this.users,
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
    );
  }
}
