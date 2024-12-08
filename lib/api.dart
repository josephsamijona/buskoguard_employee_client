//import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';
import '../models/dashboard_models.dart';
import '../models/attendance_models.dart';
import '../models/leave_models.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // Add interceptor for JWT token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: StorageConstants.authToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expiré, essayer de le rafraîchir
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Réessayer la requête originale
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Auth Methods
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        await _storage.write(
          key: StorageConstants.authToken,
          value: response.data['access'],
        );
        await _storage.write(
          key: StorageConstants.refreshToken,
          value: response.data['refresh'],
        );
        await _storage.write(
          key: StorageConstants.employeeId,
          value: response.data['employee_id'].toString(),
        );
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: StorageConstants.refreshToken);
      if (refreshToken == null) return false;

      final response = await _dio.post(ApiConstants.refreshToken, data: {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        await _storage.write(
          key: StorageConstants.authToken,
          value: response.data['access'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await _storage.deleteAll();
    }
  }

  // Dashboard Methods
  Future<DashboardResponse> getDashboardData() async {
    try {
      final response = await _dio.get(ApiConstants.dashboard);
      return DashboardResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, LeaveBalance>> getLeaveBalance() async {
    try {
      final response = await _dio.get(ApiConstants.leavesBalance);
      return (response.data as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, LeaveBalance.fromJson(value)),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceStatus> getAttendanceStatus() async {
    try {
      final response = await _dio.get(ApiConstants.attendanceStatus);
      return AttendanceStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // QR Code Methods
  Future<void> saveQRCodeAttendance({
    required String code,
    required String purpose,
    required DateTime expiry,
  }) async {
    try {
      final employeeId = await _storage.read(key: StorageConstants.employeeId);
      if (employeeId == null) throw Exception('Employee ID not found');

      await _dio.post(ApiConstants.saveQrCode, data: {
        'employee': int.parse(employeeId),
        'code': code,
        'purpose': purpose,
        'expiry': expiry.toIso8601String(),
        'is_used': false
      });
    } catch (e) {
      rethrow;
    }
  }

  // Leave Methods
  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      final response = await _dio.get(ApiConstants.leaves);
      return (response.data as List)
          .map((json) => LeaveRequest.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<LeaveRequest> createLeaveRequest(LeaveRequestCreate request) async {
    try {
      final response = await _dio.post(
        ApiConstants.leaves,
        data: request.toJson(),
      );
      return LeaveRequest.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

// Errors personnalisés
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

// Extension pour les durées pour Dio
extension DurationExtension on Duration {
  int get inMillisecondsInt => inMilliseconds;
}