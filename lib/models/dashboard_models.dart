import 'package:json_annotation/json_annotation.dart';

part 'dashboard_models.g.dart';

@JsonSerializable()
class DashboardResponse {
  final AttendanceStats attendanceStats;
  final Map<String, LeaveBalance> leavesBalance;
  final List<Leave> recentLeaves;

  DashboardResponse({
    required this.attendanceStats,
    required this.leavesBalance,
    required this.recentLeaves,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      attendanceStats: AttendanceStats.fromJson(json['attendance_stats']),
      leavesBalance: (json['leaves_balance'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, LeaveBalance.fromJson(value)),
      ),
      recentLeaves: (json['recent_leaves'] as List)
          .map((e) => Leave.fromJson(e))
          .toList(),
    );
  }
}

@JsonSerializable()
class AttendanceStats {
  @JsonKey(name: 'present_days')
  final int presentDays;
  @JsonKey(name: 'total_working_days')
  final int totalWorkingDays;
  @JsonKey(name: 'late_count')
  final int lateCount;

  AttendanceStats({
    required this.presentDays,
    required this.totalWorkingDays,
    required this.lateCount,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceStatsToJson(this);
}

@JsonSerializable()
class LeaveBalance {
  final int total;
  final int used;
  final int remaining;

  LeaveBalance({
    required this.total,
    required this.used,
    required this.remaining,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveBalanceToJson(this);
}

@JsonSerializable()
class Leave {
  final int id;
  final String type;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  final int days;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Leave({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.status,
    required this.createdAt,
  });

  factory Leave.fromJson(Map<String, dynamic> json) => _$LeaveFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveToJson(this);
}