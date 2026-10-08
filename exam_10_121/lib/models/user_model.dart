class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'Admin' | 'Operator'

  UserModel({required this.uid, required this.name, required this.email, required this.role});

  bool get isAdmin => role == 'Admin';

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: m['uid'] ?? '',
        name: m['name'] ?? '',
        email: m['email'] ?? '',
        role: m['role'] ?? 'Operator',
      );

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'email': email, 'role': role};
}
