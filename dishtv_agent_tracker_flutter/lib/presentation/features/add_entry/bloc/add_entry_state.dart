import 'package:equatable/equatable.dart';
import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';

enum AddEntryStatus { initial, loading, loaded, success, failure } // 'loaded' status जोड़ा गया

class AddEntryState extends Equatable {
  final AddEntryStatus status;
  final DateTime date;
  final int loginHours;
  final int loginMinutes;
  final int loginSeconds;
  final int callCount;
  final DailyEntry? existingEntry;
  final String? errorMessage;

  const AddEntryState({
    this.status = AddEntryStatus.initial,
    required this.date,
    this.loginHours = 0,
    this.loginMinutes = 0,
    this.loginSeconds = 0,
    this.callCount = 0,
    this.existingEntry,
    this.errorMessage,
  });

  factory AddEntryState.initial() {
    return AddEntryState(
      date: DateTime.now(),
    );
  }

  AddEntryState copyWith({
    AddEntryStatus? status,
    DateTime? date,
    int? loginHours,
    int? loginMinutes,
    int? loginSeconds,
    int? callCount,
    DailyEntry? existingEntry,
    String? errorMessage,
  }) {
    return AddEntryState(
      status: status ?? this.status,
      date: date ?? this.date,
      loginHours: loginHours ?? this.loginHours,
      loginMinutes: loginMinutes ?? this.loginMinutes,
      loginSeconds: loginSeconds ?? this.loginSeconds,
      callCount: callCount ?? this.callCount,
      existingEntry: existingEntry ?? this.existingEntry,
      errorMessage: errorMessage,
    );
  }

  bool get isValid {
    return loginHours >= 0 &&
        loginHours < 24 &&
        loginMinutes >= 0 &&
        loginMinutes < 60 &&
        loginSeconds >= 0 &&
        loginSeconds < 60 &&
        callCount >= 0 &&
        (loginHours > 0 || loginMinutes > 0 || loginSeconds > 0 || callCount > 0);
  }

  bool get isUpdate => existingEntry != null;

  DailyEntry toEntry() {
    return DailyEntry(
      id: existingEntry?.id,
      date: date,
      loginHours: loginHours,
      loginMinutes: loginMinutes,
      loginSeconds: loginSeconds,
      callCount: callCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        date,
        loginHours,
        loginMinutes,
        loginSeconds,
        callCount,
        existingEntry,
        errorMessage,
      ];
}
