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
      validateStatus: (status) {
        return status! < 500;
      },
    ));

    // Add interceptor for JWT token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: StorageConstants.authToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
        }
        print('Request: ${options.method} ${options.path}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode}');
        print('Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('Error: ${error.type} - ${error.message}');
        if (error.response != null) {
          print('Error Response: ${error.response?.data}');
        }
        
        if (error.response?.statusCode == 401) {
          // Token expiré, essayer de le rafraîchir
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Réessayer la requête originale
            return handler.resolve(await _retry(error.requestOptions));
          } else {
            // Si le rafraîchissement échoue, déconnecter l'utilisateur
            await logout();
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
      print('Tentative de connexion pour: $username');
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      print('Réponse de connexion: ${response.statusCode}');
      if (response.statusCode == 200) {
        await _storage.write(
          key: StorageConstants.authToken,
          value: response.data['access'],
        );
        await _storage.write(
          key: StorageConstants.refreshToken,
          value: response.data['refresh'],
        );
        if (response.data['employee_id'] != null) {
          await _storage.write(
            key: StorageConstants.employeeId,
            value: response.data['employee_id'].toString(),
          );
        }
        print('Connexion réussie et tokens sauvegardés');
        return true;
      }
      print('Échec de la connexion: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Erreur Dio lors de la connexion: ${e.message}');
      if (e.response != null) {
        print('Données d\'erreur: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Erreur inattendue lors de la connexion: $e');
      rethrow;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: StorageConstants.refreshToken);
      if (refreshToken == null) {
        print('Pas de refresh token trouvé');
        return false;
      }

      print('Tentative de rafraîchissement du token');
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {
          'refresh': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        await _storage.write(
          key: StorageConstants.authToken,
          value: response.data['access'],
        );
        print('Token rafraîchi avec succès');
        return true;
      }
      print('Échec du rafraîchissement: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Erreur lors du rafraîchissement du token: $e');
      return false;
    }
  }

Future<bool> logout() async {
    try {
      final refreshToken = await _storage.read(key: StorageConstants.refreshToken);
      final authToken = await _storage.read(key: StorageConstants.authToken);

      if (refreshToken == null || authToken == null) {
        print('Tokens non trouvés - Nettoyage du stockage local');
        await _clearAuthData();
        return true;
      }

      try {
        print('Tentative de déconnexion avec refresh token');
        // Modifier le corps de la requête pour utiliser 'refresh_token' au lieu de 'refresh'
        final response = await _dio.post(
          ApiConstants.logout,
          data: {
            'refresh_token': refreshToken,  // Changé ici de 'refresh' à 'refresh_token'
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) => true,
            followRedirects: false,
          ),
        );

        print('Réponse de déconnexion reçue');
        print('Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        
        await _clearAuthData();

        if (response.statusCode == 200 || response.statusCode == 204) {
          print('Déconnexion réussie côté serveur');
          return true;
        } else {
          print('Avertissement: Déconnexion côté serveur a retourné le code ${response.statusCode}');
          print('Détails de l\'erreur: ${response.data}');
          return true;
        }
      } on DioException catch (e) {
        print('Erreur Dio lors de la déconnexion: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('Données de réponse d\'erreur: ${e.response?.data}');
        }
        await _clearAuthData();
        return true;
      }
    } catch (e) {
      print('Erreur inattendue lors de la déconnexion: $e');
      await _clearAuthData();
      return true;
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _storage.delete(key: StorageConstants.authToken);
      await _storage.delete(key: StorageConstants.refreshToken);
      await _storage.delete(key: StorageConstants.employeeId);
      await _storage.delete(key: StorageConstants.userData);
      print('Stockage local nettoyé avec succès');
    } catch (e) {
      print('Erreur lors du nettoyage du stockage: $e');
      try {
        await _storage.deleteAll();
        print('Nettoyage complet du stockage effectué');
      } catch (e2) {
        print('Échec du nettoyage complet du stockage: $e2');
      }
    }
  }

  // Dashboard Methods
  Future<DashboardResponse> getDashboardData() async {
    try {
      print('Récupération des données du dashboard');
      final response = await _dio.get(ApiConstants.dashboard);
      return DashboardResponse.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la récupération du dashboard: $e');
      rethrow;
    }
  }

  // Leave Methods
  Future<Map<String, LeaveBalance>> getLeaveBalance() async {
    try {
      print('Récupération du solde des congés');
      final response = await _dio.get(ApiConstants.leavesBalance);
      return (response.data as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, LeaveBalance.fromJson(value)),
      );
    } catch (e) {
      print('Erreur lors de la récupération du solde des congés: $e');
      rethrow;
    }
  }

  Future<AttendanceStatus> getAttendanceStatus() async {
    try {
      print('Récupération du statut de présence');
      final response = await _dio.get(ApiConstants.attendanceStatus);
      return AttendanceStatus.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la récupération du statut de présence: $e');
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
      print('Sauvegarde du QR Code pour la présence');
      final employeeId = await _storage.read(key: StorageConstants.employeeId);
      if (employeeId == null) {
        throw Exception('ID employé non trouvé');
      }

      await _dio.post(
        ApiConstants.saveQrCode,
        data: {
          'employee': int.parse(employeeId),
          'code': code,
          'purpose': purpose,
          'expiry': expiry.toIso8601String(),
          'is_used': false
        },
      );
      print('QR Code sauvegardé avec succès');
    } catch (e) {
      print('Erreur lors de la sauvegarde du QR Code: $e');
      rethrow;
    }
  }

  // Leave Methods
  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      print('Récupération des demandes de congés');
      final response = await _dio.get(ApiConstants.leaves);
      return (response.data as List)
          .map((json) => LeaveRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des demandes de congés: $e');
      rethrow;
    }
  }

  Future<LeaveRequest> createLeaveRequest(LeaveRequestCreate request) async {
    try {
      print('Création d\'une demande de congé');
      final response = await _dio.post(
        ApiConstants.leaves,
        data: request.toJson(),
      );
      print('Demande de congé créée avec succès');
      return LeaveRequest.fromJson(response.data);
    } catch (e) {
      print('Erreur lors de la création de la demande de congé: $e');
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

extension DurationExtension on Duration {
  int get inMillisecondsInt => inMilliseconds;
}