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
  final String range;
  final Map<String, bool> payments;
  final String? note;

  User({
    required this.id,
    required this.name,
    required this.plan,
    required this.range,
    required this.payments,
    this.note,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      plan: json['plan'] ?? '',
      range: json['range'] ?? '',
      payments: Map<String, bool>.from(json['payments'] ?? {}),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plan': plan,
      'range': range,
      'payments': payments,
      'note': note,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? plan,
    String? range,
    Map<String, bool>? payments,
    String? note,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      range: range ?? this.range,
      payments: payments ?? this.payments,
      note: note ?? this.note,
    );
  }
}
