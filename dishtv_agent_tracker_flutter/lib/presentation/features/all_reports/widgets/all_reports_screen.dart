import 'package:flutter/material.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_app_bar.dart';

class AllReportsScreen extends StatelessWidget {
  const AllReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'All Reports'),
      body: Center(
        child: Text('This is the All Reports Screen.'),
      ),
    );
  }
}