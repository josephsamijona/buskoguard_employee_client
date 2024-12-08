import 'package:json_annotation/json_annotation.dart';

part 'attendance_models.g.dart';

@JsonSerializable()
class AttendanceStatus {
  final DateTime date;
  final String status;
  @JsonKey(name: 'check_in')
  final DateTime? checkIn;
  @JsonKey(name: 'check_out')
  final DateTime? checkOut;
  @JsonKey(name: 'attendance_type')
  final String? attendanceType;

  AttendanceStatus({
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.attendanceType,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatusFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceStatusToJson(this);
}

@JsonSerializable()
class TemporaryQRCode {
  final int employee;
  final String code;
  final String purpose;
  final DateTime expiry;
  @JsonKey(name: 'is_used')
  final bool isUsed;

  TemporaryQRCode({
    required this.employee,
    required this.code,
    required this.purpose,
    required this.expiry,
    required this.isUsed,
  });

  factory TemporaryQRCode.fromJson(Map<String, dynamic> json) =>
      _$TemporaryQRCodeFromJson(json);
  Map<String, dynamic> toJson() => _$TemporaryQRCodeToJson(this);

  bool get isValid => !isUsed && DateTime.now().isBefore(expiry);
}