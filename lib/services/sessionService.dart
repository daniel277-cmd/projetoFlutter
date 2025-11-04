import 'package:shared_preferences/shared_preferences.dart';

import 'package:teladelogin/models/userModel.dart';

class SessionService {
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kUserId = 'userId';
  static const _kUserName = 'userName';
  static const _kUserEmail = 'userEmail';
  static const _kAvatarUrl = 'avatarUrl';
  static const _kFirebaseUid = 'firebaseUid';
  static const _kIsGoogleUser = 'isGoogleUser';
  static const _kRole = 'role';
  static const _kClassId = 'classId';

  Future<void> save(UserModel u) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kIsLoggedIn, true);
    if (u.id != null) await p.setInt(_kUserId, u.id!);
    await p.setString(_kUserName, u.name);
    await p.setString(_kUserEmail, u.email);
    await p.setString(_kFirebaseUid, u.firebaseUid);
    await p.setBool(_kIsGoogleUser, u.isGoogleUser);
    await p.setString(_kRole, roleToString(u.role));
    if (u.avatarUrl != null) await p.setString(_kAvatarUrl, u.avatarUrl!);
    if (u.classId != null) await p.setString(_kClassId, u.classId!);
  }

  Future<UserModel?> load() async {
    final p = await SharedPreferences.getInstance();
    final isLogged = p.getBool(_kIsLoggedIn) ?? false;
    if (!isLogged) return null;

    return UserModel(
      id: p.getInt(_kUserId),
      firebaseUid: p.getString(_kFirebaseUid) ?? '',
      name: p.getString(_kUserName) ?? '',
      email: p.getString(_kUserEmail) ?? '',
      avatarUrl: p.getString(_kAvatarUrl),
      isGoogleUser: p.getBool(_kIsGoogleUser) ?? false,
      role: roleFromString(p.getString(_kRole)),
      classId: p.getString(_kClassId),
    );
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kIsLoggedIn);
    await p.remove(_kUserId);
    await p.remove(_kUserName);
    await p.remove(_kUserEmail);
    await p.remove(_kAvatarUrl);
    await p.remove(_kFirebaseUid);
    await p.remove(_kIsGoogleUser);
    await p.remove(_kRole);
    await p.remove(_kClassId);
  }
}
