// lib/features/auth/provider/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';

// 로그인 상태
class AuthState {
  final bool isLoggedIn;
  final String? userName;
  final int? userId;

  const AuthState({
    this.isLoggedIn = false,
    this.userName,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userName,
    int? userId,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() => const AuthState();

  //로그인
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await DioClient.instance.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final token    = res.data['access_token'] as String;
    final userName = res.data['name'] as String;
    final userId   = res.data['user_id'] as int;

    // JWT 토큰 저장
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_id',   value: userId.toString());
    await _storage.write(key: 'user_name', value: userName);

    state = state.copyWith(
      isLoggedIn: true,
      userName: userName,
      userId: userId,
    );
  }

  //회원가입
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await DioClient.instance.post(
      '/api/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final token  = res.data['access_token'] as String;
    final userId = res.data['user_id'] as int;

    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_id',   value: userId.toString());
    await _storage.write(key: 'user_name', value: name);

    state = state.copyWith(
      isLoggedIn: true,
      userName: name,
      userId: userId,
    );
  }

  //로그아웃
  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  //자동 로그인 확인
  Future<bool> checkAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    final userIdStr = await _storage.read(key: 'user_id');
    state = state.copyWith(
      isLoggedIn: true,
      userId: int.tryParse(userIdStr ?? ''),
    );
    return true;
  }
}