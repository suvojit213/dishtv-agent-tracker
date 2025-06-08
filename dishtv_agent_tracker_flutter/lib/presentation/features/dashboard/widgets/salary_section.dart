import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dishtv_agent_tracker/core/constants/app_colors.dart';
import 'package:dishtv_agent_tracker/core/constants/app_constants.dart';
import 'package:dishtv_agent_tracker/domain/entities/monthly_summary.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_card.dart';

class SalarySection extends StatelessWidget {
  final MonthlySummary summary;
  
  const SalarySection({
    Key? key,
    required this.summary,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Salary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              children: [
                _buildSalaryRow(
                  context,
                  'Base Salary (₹${AppConstants.baseRatePerCall} per call)',
                  '₹${formatter.format(summary.baseSalary)}',
                ),
                const Divider(color: AppColors.divider),
                _buildSalaryRow(
                  context,
                  'Bonus (${summary.isBonusAchieved ? 'Achieved' : 'Not Achieved'})',
                  '₹${formatter.format(summary.bonusAmount)}',
                  highlight: summary.isBonusAchieved,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Bonus Criteria: ${AppConstants.bonusCallTarget}+ calls & ${AppConstants.bonusHourTarget}+ hours',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(color: AppColors.divider),
                _buildSalaryRow(
                  context,
                  'Total Salary',
                  '₹${formatter.format(summary.totalSalary)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSalaryRow(
    BuildContext context,
    String label,
    String amount, {
    bool highlight = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: isBold
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: highlight ? AppColors.accentGreen : null,
            ),
          ),
        ],
      ),
    );
  }
}

