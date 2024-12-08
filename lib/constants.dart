// lib/constants.dart

class ApiConstants {
  // Base URL - À changer selon l'environnement
  static const String baseUrl = 'https://buskoguard.up.railway.app/api';

  // Endpoints pour l'authentification (accounts app)
  static const String login = '/auth/login/';
  static const String refreshToken = '/auth/refresh/';
  static const String logout = '/auth/logout/';

  // Endpoints pour le dashboard (accounts app)
  static const String dashboard = '/dashboard/';
  static const String leavesBalance = '/leaves/balance/';
  static const String attendanceStatus = '/attendance/status/';

  // Endpoints pour la présence (attendance app)
  static const String saveQrCode = '/qr/save/';

  // Endpoints pour les congés (leave app)
  static const String leaves = '/leaves/';
}

class StorageConstants {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String employeeId = 'employee_id';
  static const String userData = 'user_data';
}

class AppConstants {
  // Délais
  static const Duration qrCodeExpiration = Duration(seconds: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Messages par défaut
  static const String defaultErrorMessage = 'Une erreur est survenue';
  static const String networkErrorMessage = 'Erreur de connexion';
  static const String sessionExpiredMessage = 'Session expirée';
}

class UIConstants {
  // Espacements
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Rayons des bordures
  static const double borderRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;

  // Élévations
  static const double cardElevation = 2.0;
  static const double modalElevation = 8.0;

  // Durées des animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);

  // Tailles
  static const double qrCodeSize = 250.0;
  static const double iconSize = 24.0;
  static const double bottomNavHeight = 60.0;
}

class ValidationConstants {
  static const int minPasswordLength = 8;
  static const int maxReasonLength = 500;
  static const int minReasonLength = 10;
}