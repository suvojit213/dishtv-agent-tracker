import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dishtv_agent_tracker/domain/repositories/performance_repository.dart';
import 'package:dishtv_agent_tracker/domain/usecases/get_monthly_summary_usecase.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/bloc/dashboard_event.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final PerformanceRepository repository;
  late final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;
  
  DashboardBloc({required this.repository}) : super(DashboardState.initial()) {
    _getMonthlySummaryUseCase = GetMonthlySummaryUseCase(repository);
    
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<NavigateToAddEntry>(_onNavigateToAddEntry);
    on<NavigateToMonthlyPerformance>(_onNavigateToMonthlyPerformance);
    on<NavigateToAllReports>(_onNavigateToAllReports);
    
    // Load initial data
    add(LoadDashboardData(
      month: state.currentMonth,
      year: state.currentYear,
    ));
  }
  
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      currentMonth: event.month,
      currentYear: event.year,
    ));
    
    try {
      final monthlySummary = await _getMonthlySummaryUseCase.execute(
        event.month,
        event.year,
      );
      
      emit(state.copyWith(
        status: DashboardStatus.loaded,
        monthlySummary: monthlySummary,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboardData(
      month: state.currentMonth,
      year: state.currentYear,
    ));
  }
  
  void _onNavigateToAddEntry(
    NavigateToAddEntry event,
    Emitter<DashboardState> emit,
  ) {
    // Navigation will be handled in the UI layer
  }
  
  void _onNavigateToMonthlyPerformance(
    NavigateToMonthlyPerformance event,
    Emitter<DashboardState> emit,
  ) {
    // Navigation will be handled in the UI layer
  }
  
  void _onNavigateToAllReports(
    NavigateToAllReports event,
    Emitter<DashboardState> emit,
  ) {
    // Navigation will be handled in the UI layer
  }
}

