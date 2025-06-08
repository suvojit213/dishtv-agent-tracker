import 'package:flutter/material.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_app_bar.dart';

class MonthlyPerformanceScreen extends StatelessWidget {
  const MonthlyPerformanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Monthly Performance'),
      body: Center(
        child: Text('This is the Monthly Performance Screen.'),
      ),
    );
  }
}