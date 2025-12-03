import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/client_model.dart';
import '../services/firestore_service.dart';

class DataProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ClientGroup> _data = [];
  String _searchTerm = '';
  bool _isLoading = true;
  String? _currentUserId;

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
    _initAuthListener();
  }

  void _initAuthListener() {
    auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _currentUserId = user.uid;
        _initData(user.uid);
      } else {
        _currentUserId = null;
        _data = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _initData(String userId) {
    _isLoading = true;
    notifyListeners();
    
    _firestoreService.getClientGroups(userId).listen((groups) {
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
    if (_currentUserId == null) return;

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
        await _firestoreService.saveClientGroup(_currentUserId!, updatedGroup);
      } else {
        final newGroup = ClientGroup(
          email: email,
          alias: "",
          users: [newUser],
          adminId: _currentUserId,
        );
        await _firestoreService.saveClientGroup(_currentUserId!, newGroup);
      }
    } else {
      final index = _data.indexWhere((g) => g.email == email);
      if (index != -1) {
        final group = _data[index];
        final updatedUsers = List<User>.from(group.users)..add(newUser);
        final updatedGroup = group.copyWith(users: updatedUsers);
        await _firestoreService.saveClientGroup(_currentUserId!, updatedGroup);
      } else {
        // Fallback: Create new group if not found locally but requested as existing
        final newGroup = ClientGroup(
          email: email,
          alias: "",
          users: [newUser],
          adminId: _currentUserId,
        );
        await _firestoreService.saveClientGroup(_currentUserId!, newGroup);
      }
    }
  }

  Future<void> setPaymentDate(String email, int userId, String month, String? date) async {
    if (_currentUserId == null) return;

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
    await _firestoreService.saveClientGroup(_currentUserId!, updatedGroup);
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
    if (_currentUserId == null) return;

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
    await _firestoreService.saveClientGroup(_currentUserId!, updatedGroup);
  }

  Future<void> deleteUser(String email, int userId) async {
    if (_currentUserId == null) return;

    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final group = _data[groupIndex];
    final updatedUsers = List<User>.from(group.users)..removeWhere((u) => u.id == userId);

    if (updatedUsers.isEmpty) {
      await _firestoreService.deleteClientGroup(_currentUserId!, email);
    } else {
      final updatedGroup = group.copyWith(users: updatedUsers);
      await _firestoreService.saveClientGroup(_currentUserId!, updatedGroup);
    }
  }
}
