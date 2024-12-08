import 'package:json_annotation/json_annotation.dart';

part 'leave_models.g.dart';

@JsonSerializable()
class LeaveRequest {
  final int id;
  final int employee;
  @JsonKey(name: 'employee_name')
  final String employeeName;
  @JsonKey(name: 'leave_type')
  final String leaveType;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  final String reason;
  final String status;
  @JsonKey(name: 'days_requested')
  final int daysRequested;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  LeaveRequest({
    required this.id,
    required this.employee,
    required this.employeeName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.daysRequested,
    required this.createdAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveRequestToJson(this);
}

@JsonSerializable()
class LeaveRequestCreate {
  @JsonKey(name: 'leave_type')
  final String leaveType;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  final String reason;

  LeaveRequestCreate({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  factory LeaveRequestCreate.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestCreateFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveRequestCreateToJson(this);
}

enum LeaveType {
  @JsonValue('ANNUAL')
  annual,
  @JsonValue('SICK')
  sick,
  @JsonValue('UNPAID')
  unpaid,
  @JsonValue('OTHER')
  other,
}

enum LeaveStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('CANCELLED')
  cancelled,
}

extension LeaveTypeExtension on LeaveType {
  String get displayName {
    switch (this) {
      case LeaveType.annual:
        return 'Congé annuel';
      case LeaveType.sick:
        return 'Congé maladie';
      case LeaveType.unpaid:
        return 'Congé sans solde';
      case LeaveType.other:
        return 'Autre';
    }
  }
}

extension LeaveStatusExtension on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'En attente';
      case LeaveStatus.approved:
        return 'Approuvé';
      case LeaveStatus.rejected:
        return 'Refusé';
      case LeaveStatus.cancelled:
        return 'Annulé';
    }
  }
}