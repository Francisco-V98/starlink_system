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

  List<String> _selectedStatusFilters = [];
  List<String> _selectedPlanFilters = [];

  List<ClientGroup> get data => _data;
  String get searchTerm => _searchTerm;
  bool get isLoading => _isLoading;
  List<String> get selectedStatusFilters => _selectedStatusFilters;
  List<String> get selectedPlanFilters => _selectedPlanFilters;

  List<ClientGroup> get filteredData {
    return _data
        .where((group) {
          // 1. Text Search Filter
          final emailMatch = group.email.toLowerCase().contains(
            _searchTerm.toLowerCase(),
          );
          final usersMatchingSearch = group.users.where((u) {
            return u.name.toLowerCase().contains(_searchTerm.toLowerCase());
          }).toList();

          if (!emailMatch && usersMatchingSearch.isEmpty) {
            return false;
          }

          // 2. Advanced Filters (Status & Plan)
          // If no filters are selected, we don't filter users by status/plan
          if (_selectedStatusFilters.isEmpty && _selectedPlanFilters.isEmpty) {
            return true;
          }

          // We need to check if ANY user in the group matches the filters
          // OR if we are showing the group because of email match, we might want to filter the users inside?
          // Usually, filteredData returns groups. If a group has NO users matching filters, should it be shown?
          // Let's say: Show group if it has at least one user matching ALL active filter categories.

          final usersMatchingFilters = group.users.where((u) {
            // Status Filter
            bool statusMatch = true;
            if (_selectedStatusFilters.isNotEmpty) {
              statusMatch = false;
              if (_selectedStatusFilters.contains('Solvente') && u.isSolvent)
                statusMatch = true;
              if (_selectedStatusFilters.contains('Moroso') &&
                  u.overdueMonths > 0)
                statusMatch = true;
              if (_selectedStatusFilters.contains('Pago pendiente') &&
                  u.isPaymentDue)
                statusMatch = true;
              if (_selectedStatusFilters.contains('Mes por pagar') &&
                  u.isPendingMonth)
                statusMatch = true;
            }

            // Plan Filter
            bool planMatch = true;
            if (_selectedPlanFilters.isNotEmpty) {
              planMatch = _selectedPlanFilters.contains(u.plan);
            }

            return statusMatch && planMatch;
          });

          return usersMatchingFilters.isNotEmpty;
        })
        .map((group) {
          // Create a copy of the group with ONLY the users that match the filters (and search term if applicable)
          // This is important so the UI only shows relevant users.

          final filteredUsers = group.users.where((u) {
            // Search Term Check
            final searchMatch =
                _searchTerm.isEmpty ||
                group.email.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                u.name.toLowerCase().contains(_searchTerm.toLowerCase());

            // Status Filter
            bool statusMatch = true;
            if (_selectedStatusFilters.isNotEmpty) {
              statusMatch = false;
              if (_selectedStatusFilters.contains('Solvente') && u.isSolvent)
                statusMatch = true;
              if (_selectedStatusFilters.contains('Moroso') &&
                  u.overdueMonths > 0)
                statusMatch = true;
              if (_selectedStatusFilters.contains('Pago pendiente') &&
                  u.isPaymentDue)
                statusMatch = true;
              if (_selectedStatusFilters.contains('Mes por pagar') &&
                  u.isPendingMonth)
                statusMatch = true;
            }

            // Plan Filter
            bool planMatch = true;
            if (_selectedPlanFilters.isNotEmpty) {
              planMatch = _selectedPlanFilters.contains(u.plan);
            }

            return searchMatch && statusMatch && planMatch;
          }).toList();

          return group.copyWith(users: filteredUsers);
        })
        .where((g) => g.users.isNotEmpty)
        .toList();
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

    _firestoreService
        .getClientGroups(userId)
        .listen(
          (groups) {
            _data = groups;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print("Error loading data from Firestore: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void toggleStatusFilter(String status) {
    if (_selectedStatusFilters.contains(status)) {
      _selectedStatusFilters.remove(status);
    } else {
      _selectedStatusFilters.add(status);
    }
    notifyListeners();
  }

  void togglePlanFilter(String plan) {
    if (_selectedPlanFilters.contains(plan)) {
      _selectedPlanFilters.remove(plan);
    } else {
      _selectedPlanFilters.add(plan);
    }
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatusFilters.clear();
    _selectedPlanFilters.clear();
    _searchTerm = ''; // Optional: clear search too? Maybe distinct is better.
    // Let's keep search separate as per standard UX, or clear all?
    // "Limpiar filtros" usually implies the advanced filters.
    // But if we want a "Reset all", we can clear search too.
    // Let's just clear the advanced filters for now.
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
    DateTime? serviceStartDate,
    bool isNewEmail = false,
  }) async {
    if (_currentUserId == null) return;

    final Map<String, String> initialPayments = {};

    // Auto-fill payments if service start date is provided
    if (serviceStartDate != null) {
      final now = DateTime.now();
      // Start from the service start date
      DateTime iterator = DateTime(
        serviceStartDate.year,
        serviceStartDate.month,
      );
      // End at the current month
      final end = DateTime(now.year, now.month);

      while (iterator.isBefore(end) || iterator.isAtSameMomentAs(end)) {
        final monthKey =
            "${iterator.year}-${iterator.month.toString().padLeft(2, '0')}";
        // Mark as paid with the current date as the recording date
        initialPayments[monthKey] = DateTime.now().toIso8601String();

        // Move to next month
        iterator = DateTime(iterator.year, iterator.month + 1);
      }
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      plan: plan,
      country: country,
      phoneNumber: phoneNumber,
      antennaSerial: antennaSerial,
      paymentStartDay: paymentStartDay,
      paymentEndDay: paymentEndDay,
      payments: initialPayments,
      serviceStartDate: serviceStartDate,
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

  Future<void> setPaymentDate(
    String email,
    int userId,
    String month,
    String? date,
  ) async {
    if (_currentUserId == null) return;

    final groupIndex = _data.indexWhere((g) => g.email == email);
    if (groupIndex == -1) return;

    final group = _data[groupIndex];
    final userIndex = group.users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;

    final user = group.users[userIndex];

    final newPayments = Map<String, String>.from(user.payments);

    if (date == null) {
      // Unmarking as paid
      newPayments.remove(month);
    } else {
      // Marking as paid
      newPayments[month] = date;

      // Auto-fill logic: Fill gaps between the last paid month and this new month
      try {
        final targetDateParts = month.split('-');
        final targetYear = int.parse(targetDateParts[0]);
        final targetMonth = int.parse(targetDateParts[1]);
        final targetDateTime = DateTime(targetYear, targetMonth);

        // Find the latest paid month before the target date
        DateTime? latestPaidDate;

        // Sort existing keys to find the latest one before target
        final sortedKeys = user.payments.keys.toList()..sort();

        for (final key in sortedKeys.reversed) {
          final parts = key.split('-');
          final year = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final d = DateTime(year, m);

          if (d.isBefore(targetDateTime)) {
            latestPaidDate = d;
            break;
          }
        }

        // If we found a previous payment, fill the gap
        if (latestPaidDate != null) {
          DateTime iterator = DateTime(
            latestPaidDate.year,
            latestPaidDate.month + 1,
          );

          while (iterator.isBefore(targetDateTime)) {
            final gapKey =
                "${iterator.year}-${iterator.month.toString().padLeft(2, '0')}";
            // Only fill if not already paid (though logic suggests it shouldn't be, but safety first)
            if (!newPayments.containsKey(gapKey)) {
              newPayments[gapKey] = date; // Use the same payment date
            }
            iterator = DateTime(iterator.year, iterator.month + 1);
          }
        }
      } catch (e) {
        print("Error in auto-fill logic: $e");
      }
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
    final updatedUsers = List<User>.from(group.users)
      ..removeWhere((u) => u.id == userId);

    if (updatedUsers.isEmpty) {
      await _firestoreService.deleteClientGroup(_currentUserId!, email);
    } else {
      final updatedGroup = group.copyWith(users: updatedUsers);
      await _firestoreService.saveClientGroup(_currentUserId!, updatedGroup);
    }
  }
}
