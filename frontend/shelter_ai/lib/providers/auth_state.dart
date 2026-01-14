import 'package:flutter/widgets.dart';

enum UserRole { refugee, worker }

class AuthState extends ChangeNotifier {
  UserRole? _role;
  int? _userId;
  String _token = '';
  String _userName = '';
  
  // User registration data
  String _firstName = '';
  String _lastName = '';
  int? _age;
  String _gender = 'Male';
  String? _nationality;
  String? _email;
  String? _phoneNumber;
  String? _address;

  UserRole? get role => _role;
  bool get isAuthenticated => _role != null;
  int? get userId => _userId;
  String get token => _token;
  String get userName => _userName;
  
  // Getters for user data
  String get firstName => _firstName;
  String get lastName => _lastName;
  int? get age => _age;
  String get gender => _gender;
  String? get nationality => _nationality;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get address => _address;

  void login(
    UserRole role, {
    int? userId,
    String token = '',
    String userName = '',
    String firstName = '',
    String lastName = '',
    int? age,
    String gender = 'Male',
    String? nationality,
    String? email,
    String? phoneNumber,
    String? address,
  }) {
    _role = role;
    _userId = userId;
    _token = token;
    _userName = userName;
    _firstName = firstName;
    _lastName = lastName;
    _age = age;
    _gender = gender;
    _nationality = nationality;
    _email = email;
    _phoneNumber = phoneNumber;
    _address = address;
    notifyListeners();
  }

  void logout() {
    _role = null;
    _userId = null;
    _token = '';
    _userName = '';
    _firstName = '';
    _lastName = '';
    _age = null;
    _gender = 'Male';
    _nationality = null;
    _email = null;
    _phoneNumber = null;
    _address = null;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthState> {
  final AuthState state;

  const AuthScope({super.key, required this.state, required Widget child})
    : super(notifier: state, child: child);

  static AuthState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in context');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(covariant AuthScope oldWidget) =>
      oldWidget.state != state;
}
