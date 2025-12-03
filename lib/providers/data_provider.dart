import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_model.dart';
import '../data/initial_data.dart';

class DataProvider extends ChangeNotifier {
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
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('starlinkData');

      if (savedData != null) {
        final List<dynamic> decoded = json.decode(savedData);
        _data = decoded.map((e) => ClientGroup.fromJson(e)).toList();
      } else {
        _data = initialDataLoad;
      }
    } catch (e) {
      print("Error loading data: $e");
      _data = initialDataLoad;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_data.map((e) => e.toJson()).toList());
      await prefs.setString('starlinkData', encoded);
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  Future<void> addUser({
    required String email,
    required String name,
    required String plan,
    required String range,
    bool isNewEmail = false,
  }) async {
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      plan: plan,
      range: range.isEmpty ? "Pendiente" : range,
      payments: {},
    );

    if (isNewEmail) {
      _data.add(ClientGroup(
        email: email,
        alias: "",
        users: [newUser],
      ));
    } else {
      final index = _data.indexWhere((g) => g.email == email);
      if (index != -1) {
        _data[index].users.add(newUser);
      } else {
        // Fallback if email not found but marked as existing (shouldn't happen if UI is correct)
        _data.add(ClientGroup(
          email: email,
          alias: "",
          users: [newUser],
        ));
      }
    }

    notifyListeners();
    await saveData();
  }

  Future<void> togglePayment(String email, int userId, String month) async {
    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final userIndex = _data[groupIndex].users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;

    final user = _data[groupIndex].users[userIndex];
    final currentStatus = user.payments[month] ?? false;
    
    // Create a new map to ensure immutability/change detection if needed, though direct mutation works with notifyListeners
    final newPayments = Map<String, bool>.from(user.payments);
    newPayments[month] = !currentStatus;

    _data[groupIndex].users[userIndex] = user.copyWith(payments: newPayments);

    notifyListeners();
    await saveData();
  }

  Future<void> updateUser(
    String email,
    int userId, {
    String? name,
    String? plan,
    String? range,
    String? note,
  }) async {
    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final userIndex = _data[groupIndex].users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;

    final user = _data[groupIndex].users[userIndex];
    _data[groupIndex].users[userIndex] = user.copyWith(
      name: name ?? user.name,
      plan: plan ?? user.plan,
      range: range ?? user.range,
      note: note ?? user.note,
    );

    notifyListeners();
    await saveData();
  }

  Future<void> deleteUser(String email, int userId) async {
    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    _data[groupIndex].users.removeWhere((u) => u.id == userId);

    // Remove group if empty
    if (_data[groupIndex].users.isEmpty) {
      _data.removeAt(groupIndex);
    }

    notifyListeners();
    await saveData();
  }

}
