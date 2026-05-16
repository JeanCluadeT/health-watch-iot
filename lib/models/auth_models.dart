class AuthResponse {
  final String status;
  final String message;
  final int userId;
  final String email;
  final String role;
  final String token;
  final String? fullName;
  final String? verificationStatus;

  AuthResponse({
    required this.status,
    required this.message,
    required this.userId,
    required this.email,
    required this.role,
    required this.token,
    this.fullName,
    this.verificationStatus,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      userId: json['user_id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
      fullName: json['full_name'],
      verificationStatus: json['verification_status'],
    );
  }
}

class UserSession {
  final int userId;
  final String email;
  final String role;
  final String token;
  final String fullName;

  UserSession({
    required this.userId,
    required this.email,
    required this.role,
    required this.token,
    required this.fullName,
  });
}
