// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponse _$DashboardResponseFromJson(Map<String, dynamic> json) =>
    DashboardResponse(
      attendanceStats: AttendanceStats.fromJson(
          json['attendanceStats'] as Map<String, dynamic>),
      leavesBalance: (json['leavesBalance'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, LeaveBalance.fromJson(e as Map<String, dynamic>)),
      ),
      recentLeaves: (json['recentLeaves'] as List<dynamic>)
          .map((e) => Leave.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardResponseToJson(DashboardResponse instance) =>
    <String, dynamic>{
      'attendanceStats': instance.attendanceStats,
      'leavesBalance': instance.leavesBalance,
      'recentLeaves': instance.recentLeaves,
    };

AttendanceStats _$AttendanceStatsFromJson(Map<String, dynamic> json) =>
    AttendanceStats(
      presentDays: (json['present_days'] as num).toInt(),
      totalWorkingDays: (json['total_working_days'] as num).toInt(),
      lateCount: (json['late_count'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceStatsToJson(AttendanceStats instance) =>
    <String, dynamic>{
      'present_days': instance.presentDays,
      'total_working_days': instance.totalWorkingDays,
      'late_count': instance.lateCount,
    };

LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) => LeaveBalance(
      total: (json['total'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      remaining: (json['remaining'] as num).toInt(),
    );

Map<String, dynamic> _$LeaveBalanceToJson(LeaveBalance instance) =>
    <String, dynamic>{
      'total': instance.total,
      'used': instance.used,
      'remaining': instance.remaining,
    };

Leave _$LeaveFromJson(Map<String, dynamic> json) => Leave(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      days: (json['days'] as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LeaveToJson(Leave instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'days': instance.days,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
