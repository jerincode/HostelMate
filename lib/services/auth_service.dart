import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/data_repository.dart';

class AuthService extends ChangeNotifier {
  final DataRepository _repository;
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthService(this._repository);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _repository.login(email, password);
      return _currentUser != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
