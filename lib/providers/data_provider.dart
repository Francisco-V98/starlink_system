import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ClientGroup> _data = [];
  String _searchTerm = '';
  bool _isLoading = true;

  List<ClientGroup> get data => _data;
  String get searchTerm => _searchTerm;
  bool get isLoading => _isLoading;

  List<ClientGroup> get filteredData {
    if (_searchTerm.isEmpty) {
      return _data;
    }
    return _data.where((group) {
      final emailMatch = group.email.toLowerCase().contains(_searchTerm.toLowerCase());
      final userMatch = group.users.any((u) => u.name.toLowerCase().contains(_searchTerm.toLowerCase()));
      return emailMatch || userMatch;
    }).toList();
  }

  DataProvider() {
    _initData();
  }

  void _initData() {
    _firestoreService.getClientGroups().listen((groups) {
      _data = groups;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Error loading data from Firestore: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  Future<void> addUser({
    required String email,
    required String name,
    required String plan,
    required String country,
    required String phoneNumber,
    required String antennaSerial,
    required int paymentStartDay,
    required int paymentEndDay,
    bool isNewEmail = false,
  }) async {
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      plan: plan,
      country: country,
      phoneNumber: phoneNumber,
      antennaSerial: antennaSerial,
      paymentStartDay: paymentStartDay,
      paymentEndDay: paymentEndDay,
      payments: {},
    );

    if (isNewEmail) {
      // Safety check: if email already exists, treat as existing group
      final existingIndex = _data.indexWhere((g) => g.email == email);
      if (existingIndex != -1) {
        final group = _data[existingIndex];
        final updatedUsers = List<User>.from(group.users)..add(newUser);
        final updatedGroup = group.copyWith(users: updatedUsers);
        await _firestoreService.saveClientGroup(updatedGroup);
      } else {
        final newGroup = ClientGroup(
          email: email,
          alias: "",
          users: [newUser],
        );
        await _firestoreService.saveClientGroup(newGroup);
      }
    } else {
      final index = _data.indexWhere((g) => g.email == email);
      if (index != -1) {
        final group = _data[index];
        final updatedUsers = List<User>.from(group.users)..add(newUser);
        final updatedGroup = group.copyWith(users: updatedUsers);
        await _firestoreService.saveClientGroup(updatedGroup);
      } else {
        // Fallback: Create new group if not found locally but requested as existing
        final newGroup = ClientGroup(
          email: email,
          alias: "",
          users: [newUser],
        );
        await _firestoreService.saveClientGroup(newGroup);
      }
    }
  }

  Future<void> setPaymentDate(String email, int userId, String month, String? date) async {
    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final group = _data[groupIndex];
    final userIndex = group.users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;

    final user = group.users[userIndex];
    
    final newPayments = Map<String, String>.from(user.payments);
    if (date == null) {
      newPayments.remove(month);
    } else {
      newPayments[month] = date;
    }

    final updatedUser = user.copyWith(payments: newPayments);
    final updatedUsers = List<User>.from(group.users);
    updatedUsers[userIndex] = updatedUser;

    final updatedGroup = group.copyWith(users: updatedUsers);
    await _firestoreService.saveClientGroup(updatedGroup);
  }

  Future<void> updateUser(
    String email,
    int userId, {
    String? name,
    String? plan,
    String? phoneNumber,
    String? antennaSerial,
    String? country,
    int? paymentStartDay,
    int? paymentEndDay,
    String? note,
  }) async {
    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final group = _data[groupIndex];
    final userIndex = group.users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;

    final user = group.users[userIndex];
    final updatedUser = user.copyWith(
      name: name ?? user.name,
      plan: plan ?? user.plan,
      phoneNumber: phoneNumber ?? user.phoneNumber,
      antennaSerial: antennaSerial ?? user.antennaSerial,
      country: country ?? user.country,
      paymentStartDay: paymentStartDay ?? user.paymentStartDay,
      paymentEndDay: paymentEndDay ?? user.paymentEndDay,
      note: note ?? user.note,
    );

    final updatedUsers = List<User>.from(group.users);
    updatedUsers[userIndex] = updatedUser;

    final updatedGroup = group.copyWith(users: updatedUsers);
    await _firestoreService.saveClientGroup(updatedGroup);
  }

  Future<void> deleteUser(String email, int userId) async {
    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final group = _data[groupIndex];
    final updatedUsers = List<User>.from(group.users)..removeWhere((u) => u.id == userId);

    if (updatedUsers.isEmpty) {
      await _firestoreService.deleteClientGroup(email);
    } else {
      final updatedGroup = group.copyWith(users: updatedUsers);
      await _firestoreService.saveClientGroup(updatedGroup);
    }
  }
}
