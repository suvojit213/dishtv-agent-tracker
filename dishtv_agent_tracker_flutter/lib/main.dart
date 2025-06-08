import 'package:flutter/material.dart';
import 'package:dishtv_agent_tracker/core/constants/app_colors.dart';
import 'package:dishtv_agent_tracker/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dishtv_agent_tracker/data/datasources/local_data_source.dart';
import 'package:dishtv_agent_tracker/data/repositories/performance_repository_impl.dart';
import 'package:dishtv_agent_tracker/domain/repositories/performance_repository.dart';
import 'package:dishtv_agent_tracker/presentation/common/theme/app_theme.dart';
import 'package:dishtv_agent_tracker/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database
  final localDataSource = await LocalDataSource.init();
  
  // Create repository
  final PerformanceRepository performanceRepository = PerformanceRepositoryImpl(
    localDataSource: localDataSource,
  );
  
  runApp(MyApp(
    performanceRepository: performanceRepository,
  ));
}

class MyApp extends StatelessWidget {
  final PerformanceRepository performanceRepository;
  
  const MyApp({
    Key? key,
    required this.performanceRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PerformanceRepository>(
      create: (context) => performanceRepository,
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark theme as per requirements
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.dashboardRoute,
      ),
    );
  }
}

