import 'package:shared_preferences/shared_preferences.dart';

import 'user_role.dart';

/// Local session flags (JWT/role hydration will extend this later).
class UserPrefs {
  UserPrefs._();
  static final UserPrefs instance = UserPrefs._();

  SharedPreferences? _p;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static const _kRole = 'user_role';
  static const _kLocationAsked = 'location_prompt_done';

  UserRole get role => UserRole.fromStorage(_p?.getString(_kRole));

  Future<void> setRole(UserRole r) async {
    await _p?.setString(_kRole, r.name);
  }

  bool get locationPromptCompleted => _p?.getBool(_kLocationAsked) ?? false;

  Future<void> setLocationPromptCompleted([bool v = true]) async {
    await _p?.setBool(_kLocationAsked, v);
  }
}
