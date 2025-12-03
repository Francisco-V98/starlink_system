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

  int get overdueMonths {
    final now = DateTime.now();
    int count = 0;
    
    // Determine where to start checking
    // If today > paymentEndDay, check this month. Else check previous month.
    DateTime iterator;
    if (now.day > paymentEndDay) {
      iterator = DateTime(now.year, now.month);
    } else {
      iterator = DateTime(now.year, now.month - 1);
    }

    // If serviceStartDate is null, we default to 0 to avoid issues
    if (serviceStartDate == null) return 0;
    
    final start = DateTime(serviceStartDate!.year, serviceStartDate!.month);

    // Loop backwards
    while (iterator.isAfter(start) || iterator.isAtSameMomentAs(start)) {
       final key = "${iterator.year}-${iterator.month.toString().padLeft(2, '0')}";
       if (payments.containsKey(key)) {
         break; // Found a payment, stop counting
       }
       count++;
       iterator = DateTime(iterator.year, iterator.month - 1);
    }
    return count;
  }

  bool isMonthOverdue(String monthKey) {
    if (payments.containsKey(monthKey)) return false; // Paid
    if (serviceStartDate == null) return false;

    try {
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthDate = DateTime(year, month);
      
      final start = DateTime(serviceStartDate!.year, serviceStartDate!.month);
      // We only care about month precision for start date comparison
      if (monthDate.isBefore(start)) return false; 

      final now = DateTime.now();
      
      // If the month is in the future, it's not overdue
      if (monthDate.year > now.year) return false;
      if (monthDate.year == now.year && monthDate.month > now.month) return false;

      // If it's the current month
      if (monthDate.year == now.year && monthDate.month == now.month) {
        return now.day > paymentEndDay;
      }

      // If it's a past month and not paid, it's overdue
      return true;
    } catch (e) {
      return false;
    }
  }
}
