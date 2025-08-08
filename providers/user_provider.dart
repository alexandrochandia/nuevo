import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';
import '../data/mock_users.dart';

class UserProvider extends ChangeNotifier {
  // Removed SupabaseService dependency

  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<UserModel> get newUsers => _newUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from Supabase first, fallback to mock data
      try {
        final client = SupabaseConfig.client;
        if (client != null) {
          final response = await client.from('users').select('*');
          _users = (response as List).map((user) => UserModel.fromJson(user)).toList();
        } else {
          throw Exception('Supabase not initialized');
        }
      } catch (e) {
        // If Supabase fails, use mock data
        _users = MockUsers.getUsers();
      }
      _newUsers = _users.where((user) => user.isNewUser).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _users = [];
      _newUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUsers() async {
    await loadUsers();
  }

  void removeUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    _newUsers.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  List<UserModel> getOnlineUsers() {
    return _users.where((user) => user.isOnline).toList();
  }

  int get totalUsers => _users.length;
  int get newUsersCount => _newUsers.length;
  int get onlineUsersCount => getOnlineUsers().length;
}
