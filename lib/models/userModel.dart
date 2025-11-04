// lib/models/user_model.dart

enum UserRole { student, teacher, admin }

UserRole roleFromString(String? v) {
  switch (v) {
    case 'teacher': return UserRole.teacher;
    case 'admin': return UserRole.admin;
    case 'student':
    default: return UserRole.student;
  }
}

String roleToString(UserRole r) {
  switch (r) {
    case UserRole.teacher: return 'teacher';
    case UserRole.admin: return 'admin';
    // ignore: unreachable_switch_default
    case UserRole.student: default: return 'student';
  }
}

class UserModel {
  final int? id;                 // id local (SQLite)
  final String firebaseUid;      // UID do Firebase Auth
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isGoogleUser;
  final UserRole role;           // aluno/professor/admin
  final String? classId;         // turma atual (opcional)

  UserModel({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isGoogleUser = false,
    this.role = UserRole.student,
    this.classId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      firebaseUid: map['firebaseUid'],
      name: map['name'],
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      isGoogleUser: (map['isGoogleUser'] ?? 0) == 1,
      role: roleFromString(map['role']),
      classId: map['classId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isGoogleUser': isGoogleUser ? 1 : 0,
      'role': roleToString(role),
      'classId': classId,
    };
  }

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserModel(
      id: null,
      firebaseUid: uid,
      name: (data['name'] ?? data['displayName'] ?? data['email'] ?? 'Usuário') as String,
      email: (data['email'] ?? '') as String,
      avatarUrl: data['avatarUrl'] as String?,
      isGoogleUser: (data['isGoogleUser'] ?? false) as bool,
      role: roleFromString(data['role'] as String?),
      classId: data['classId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isGoogleUser': isGoogleUser,
      'role': roleToString(role),
      'classId': classId,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? firebaseUid,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isGoogleUser,
    UserRole? role,
    String? classId,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      role: role ?? this.role,
      classId: classId ?? this.classId,
    );
  }
}
