// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceStatus _$AttendanceStatusFromJson(Map<String, dynamic> json) =>
    AttendanceStatus(
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      checkIn: json['check_in'] == null
          ? null
          : DateTime.parse(json['check_in'] as String),
      checkOut: json['check_out'] == null
          ? null
          : DateTime.parse(json['check_out'] as String),
      attendanceType: json['attendance_type'] as String?,
    );

Map<String, dynamic> _$AttendanceStatusToJson(AttendanceStatus instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'check_in': instance.checkIn?.toIso8601String(),
      'check_out': instance.checkOut?.toIso8601String(),
      'attendance_type': instance.attendanceType,
    };

TemporaryQRCode _$TemporaryQRCodeFromJson(Map<String, dynamic> json) =>
    TemporaryQRCode(
      employee: (json['employee'] as num).toInt(),
      code: json['code'] as String,
      purpose: json['purpose'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
      isUsed: json['is_used'] as bool,
    );

Map<String, dynamic> _$TemporaryQRCodeToJson(TemporaryQRCode instance) =>
    <String, dynamic>{
      'employee': instance.employee,
      'code': instance.code,
      'purpose': instance.purpose,
      'expiry': instance.expiry.toIso8601String(),
      'is_used': instance.isUsed,
    };
