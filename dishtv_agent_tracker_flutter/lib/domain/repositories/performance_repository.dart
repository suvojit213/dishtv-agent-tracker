import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';
import 'package:dishtv_agent_tracker/domain/entities/monthly_summary.dart';

abstract class PerformanceRepository {
  // Daily entries operations
  Future<List<DailyEntry>> getAllEntries();
  Future<List<DailyEntry>> getEntriesForMonth(int month, int year);
  Future<DailyEntry?> getEntryForDate(DateTime date);
  Future<int> addEntry(DailyEntry entry);
  Future<int> updateEntry(DailyEntry entry);
  Future<int> deleteEntry(int id);
  
  // Monthly summary operations
  Future<List<MonthlySummary>> getAllMonthlySummaries();
  Future<MonthlySummary> getMonthlySummary(int month, int year);
  
  // PDF operations
  Future<String> generateMonthlyReportPdf(MonthlySummary summary);
}

