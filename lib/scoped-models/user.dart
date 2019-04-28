import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './connected_product.dart';
import '../models/auth.dart';
import 'package:rxdart/subjects.dart';
import '../models/user.dart';

mixin UserModel on ConnectedProducts {
  Timer _authTimer;
  bool isUserLoading = false;
  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    isUserLoading = true;
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyABeOsrx4FXs9k6ProyS3I8Z3sLKStgBDo',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    } else {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyABeOsrx4FXs9k6ProyS3I8Z3sLKStgBDo',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    bool hasError = true;
    String message = 'Something went wrong.';
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded';
      authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAutoTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('token', responseData['idToken']);
      sharedPreferences.setString('userEmail', email);
      sharedPreferences.setString('userId', responseData['localId']);
      sharedPreferences.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'password is invalid.';
    }
    isUserLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuth() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final String token = sharedPreferences.getString('token');
    final String expiryTime = sharedPreferences.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parseExpiryTime = DateTime.parse(expiryTime);
      if (parseExpiryTime.isBefore(now)) {
        authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = sharedPreferences.getString('userEmail');
      final String userId = sharedPreferences.getString('userId');
      final tokenLifespan = parseExpiryTime.difference(now).inSeconds;
      authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAutoTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();

  }

  void setAutoTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
    });
  }
}

mixin UserUtilityModel on UserModel {
  bool get isUserISLoading {
    return isUserLoading;
  }
}
