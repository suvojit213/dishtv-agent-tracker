import 'package:equatable/equatable.dart';
import 'package:dishtv_agent_tracker/core/constants/app_constants.dart';
import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';

class MonthlySummary extends Equatable {
  final int month;
  final int year;
  final List<DailyEntry> entries;
  
  const MonthlySummary({
    required this.month,
    required this.year,
    required this.entries,
  });
  
  // Total login hours for the month
  double get totalLoginHours {
    if (entries.isEmpty) return 0;
    return entries.fold(0.0, (sum, entry) => sum + entry.totalLoginTimeInHours);
  }
  
  // Total calls for the month
  int get totalCalls {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, entry) => sum + entry.callCount);
  }
  
  // Average daily login hours
  double get averageDailyLoginHours {
    if (entries.isEmpty) return 0;
    return totalLoginHours / entries.length;
  }
  
  // Average daily calls
  double get averageDailyCalls {
    if (entries.isEmpty) return 0;
    return totalCalls / entries.length;
  }
  
  // Check if bonus targets are achieved
  bool get isBonusAchieved {
    return totalCalls >= AppConstants.bonusCallTarget && 
           totalLoginHours >= AppConstants.bonusHourTarget;
  }
  
  // Calculate base salary (₹4.30 per call)
  double get baseSalary {
    return totalCalls * AppConstants.baseRatePerCall;
  }
  
  // Calculate bonus amount (₹2000 if targets are met)
  double get bonusAmount {
    return isBonusAchieved ? AppConstants.bonusAmount : 0;
  }
  
  // Calculate total salary
  double get totalSalary {
    return baseSalary + bonusAmount;
  }
  
  // Format month name
  String get monthName {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
  
  // Format as Month Year (e.g., "June 2025")
  String get formattedMonthYear {
    return '$monthName $year';
  }
  
  @override
  List<Object?> get props => [month, year, entries];
}

