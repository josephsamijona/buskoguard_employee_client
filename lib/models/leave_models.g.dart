// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) => LeaveRequest(
      id: (json['id'] as num).toInt(),
      employee: (json['employee'] as num).toInt(),
      employeeName: json['employee_name'] as String,
      leaveType: json['leave_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String,
      status: json['status'] as String,
      daysRequested: (json['days_requested'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LeaveRequestToJson(LeaveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee': instance.employee,
      'employee_name': instance.employeeName,
      'leave_type': instance.leaveType,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'reason': instance.reason,
      'status': instance.status,
      'days_requested': instance.daysRequested,
      'created_at': instance.createdAt.toIso8601String(),
    };

LeaveRequestCreate _$LeaveRequestCreateFromJson(Map<String, dynamic> json) =>
    LeaveRequestCreate(
      leaveType: json['leave_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$LeaveRequestCreateToJson(LeaveRequestCreate instance) =>
    <String, dynamic>{
      'leave_type': instance.leaveType,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'reason': instance.reason,
    };
