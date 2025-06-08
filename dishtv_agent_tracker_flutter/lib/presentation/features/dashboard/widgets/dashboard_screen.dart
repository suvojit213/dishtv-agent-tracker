import 'package:dishtv_agent_tracker/presentation/features/dashboard/widgets/daily_entries_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dishtv_agent_tracker/core/constants/app_colors.dart';
import 'package:dishtv_agent_tracker/domain/repositories/performance_repository.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_app_bar.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_bottom_navigation_bar.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/bloc/dashboard_event.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/bloc/dashboard_state.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/widgets/summary_section.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/widgets/salary_section.dart';
import 'package:dishtv_agent_tracker/presentation/features/dashboard/widgets/performance_chart.dart';
import 'package:dishtv_agent_tracker/presentation/routes/app_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        repository: context.read<PerformanceRepository>(),
      )..add(LoadDashboardData(month: DateTime.now().month, year: DateTime.now().year)),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          switch (state.status) {
            case DashboardStatus.initial:
            case DashboardStatus.loading:
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.dishTvOrange,
                ),
              );
            case DashboardStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.accentRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Unknown error occurred',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(RefreshDashboard());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case DashboardStatus.loaded:
              if (state.monthlySummary == null) {
                return const Center(
                  child: Text('No data available'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                },
                color: AppColors.dishTvOrange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Month/Year header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.monthlySummary!.formattedMonthYear,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: () {
                                    final currentDate = DateTime(state.currentYear, state.currentMonth);
                                    final previousMonth = DateTime(currentDate.year, currentDate.month - 1);
                                    context.read<DashboardBloc>().add(
                                      LoadDashboardData(
                                        month: previousMonth.month,
                                        year: previousMonth.year,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    final currentDate = DateTime(state.currentYear, state.currentMonth);
                                    final nextMonth = DateTime(currentDate.year, currentDate.month + 1);
                                    context.read<DashboardBloc>().add(
                                      LoadDashboardData(
                                        month: nextMonth.month,
                                        year: nextMonth.year,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Summary section
                      SummarySection(summary: state.monthlySummary!),
                      const SizedBox(height: 24),
                      
                      // Salary section
                      SalarySection(summary: state.monthlySummary!),
                      const SizedBox(height: 24),
                      
                      // Performance chart
                      PerformanceChart(summary: state.monthlySummary!),
                      const SizedBox(height: 24),

                      // Daily Entries Section - नया विजेट यहाँ जोड़ा गया है
                      DailyEntriesSection(entries: state.monthlySummary!.entries),
                      
                      const SizedBox(height: 100), // Extra space for FAB
                    ],
                  ),
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Edit mode ke liye null entry pass karein
          Navigator.pushNamed(context, AppRouter.addEntryRoute, arguments: null)
              .then((value) {
            // Dashboard par wapas aane ke baad data refresh karein
            if (value == true) {
              context.read<DashboardBloc>().add(RefreshDashboard());
            }
          });
        },
        backgroundColor: AppColors.dishTvOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, AppRouter.monthlyPerformanceRoute);
              break;
            case 2:
              Navigator.pushNamed(context, AppRouter.allReportsRoute);
              break;
          }
        },
      ),
    );
  }
}
