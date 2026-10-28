class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? deviceId;
  final String? deviceToken;
  final String? status;
  final DateTime? trialEndsAt;
  final DateTime? subscriptionStartsAt;
  final DateTime? subscriptionEndsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int representativesLimit;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.deviceId,
    this.deviceToken,
    this.status,
    this.trialEndsAt,
    this.subscriptionStartsAt,
    this.subscriptionEndsAt,
    this.createdAt,
    this.updatedAt,
    required this.representativesLimit,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      deviceId: json['device_id']?.toString(),
      deviceToken: json['device_token']?.toString(),
      status: json['status']?.toString(),
      trialEndsAt: _parseDate(json['trial_ends_at']),
      subscriptionStartsAt: _parseDate(json['subscription_starts_at']),
      subscriptionEndsAt: _parseDate(json['subscription_ends_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      representativesLimit: int.tryParse('${json['representatives_limit']}') ?? 0,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

class AuthTokenModel {
  final String token;
  final String type;

  const AuthTokenModel({
    required this.token,
    required this.type,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      token: json['token']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class AuthResponse {
  final UserModel user;
  final AuthTokenModel auth;

  const AuthResponse({
    required this.user,
    required this.auth,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final authJson = json['auth'];

    return AuthResponse(
      user: UserModel.fromJson(userJson is Map<String, dynamic>
          ? userJson
          : Map<String, dynamic>.from(userJson ?? <String, dynamic>{})),
      auth: AuthTokenModel.fromJson(authJson is Map<String, dynamic>
          ? authJson
          : Map<String, dynamic>.from(authJson ?? <String, dynamic>{})),
    );
  }
}
