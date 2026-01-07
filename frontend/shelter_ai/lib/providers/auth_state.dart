import 'package:flutter/widgets.dart';

enum UserRole { refugee, worker }

class AuthState extends ChangeNotifier {
  UserRole? _role;
  int? _userId;
  String _token = '';
  String _userName = '';

  UserRole? get role => _role;
  bool get isAuthenticated => _role != null;
  int? get userId => _userId;
  String get token => _token;
  String get userName => _userName;

  void login(
    UserRole role, {
    int? userId,
    String token = '',
    String userName = '',
  }) {
    _role = role;
    _userId = userId;
    _token = token;
    _userName = userName;
    notifyListeners();
  }

  void logout() {
    _role = null;
    _userId = null;
    _token = '';
    _userName = '';
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
