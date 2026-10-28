import 'package:storeflow/core/api/api_response.dart';
import 'package:storeflow/core/api/base_api_service.dart';
import 'package:storeflow/features/auth/data/models/auth_models.dart';

class AuthService extends BaseApiService {
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    return request<AuthResponse>(
      method: 'POST',
      path: '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      fromJson: (data) {
        if (data is! Map<String, dynamic>) {
          return AuthResponse(
            user: const UserModel(
              id: 0,
              name: '',
              email: '',
              role: '',
              representativesLimit: 0,
            ),
            auth: const AuthTokenModel(token: '', type: ''),
          );
        }

        return AuthResponse.fromJson(data);
      },
    );
  }
}
