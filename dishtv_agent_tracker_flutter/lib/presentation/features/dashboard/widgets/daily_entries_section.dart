import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_card.dart';
import 'package:dishtv_agent_tracker/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyEntriesSection extends StatelessWidget {
  final List<DailyEntry> entries;

  const DailyEntriesSection({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Entries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const CustomCard(
              child: Center(
                child: Text('Is mahine ke liye koi entry nahi hai.'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildEntryItem(context, entry);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(BuildContext context, DailyEntry entry) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Text(
            DateFormat('dd').format(entry.date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          DateFormat('EEEE, MMM dd, yyyy').format(entry.date),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${entry.callCount} calls • Login Time: ${entry.formattedLoginTime}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            // Edit ke liye AddEntryScreen par navigate karein
            Navigator.pushNamed(
              context,
              AppRouter.addEntryRoute,
              arguments: entry, // Entry object ko arguments ke roop mein pass karein
            ).then((_) {
              // Dashboard ko refresh karein (optional, agar BLoC se handle nahi ho raha)
            });
          },
        ),
      ),
    );
  }
}
