import 'package:dishtv_agent_tracker/domain/repositories/performance_repository.dart';

class GetAllMonthlySummariesUseCase {
  final PerformanceRepository repository;
  
  GetAllMonthlySummariesUseCase(this.repository);
  
  Future<List<Map<String, int>>> execute() async {
    final summaries = await repository.getAllMonthlySummaries();
    
    // Convert to a list of month-year maps for easier consumption by the UI
    return summaries.map((summary) => {
      'month': summary.month,
      'year': summary.year,
    }).toList();
  }
}

