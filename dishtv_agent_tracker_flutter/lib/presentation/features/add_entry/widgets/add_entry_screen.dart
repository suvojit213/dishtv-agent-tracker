import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dishtv_agent_tracker/core/constants/app_colors.dart';
import 'package:dishtv_agent_tracker/domain/repositories/performance_repository.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_app_bar.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_card.dart';
import 'package:dishtv_agent_tracker/presentation/common/widgets/custom_button.dart';
import 'package:dishtv_agent_tracker/presentation/features/add_entry/bloc/add_entry_bloc.dart';
import 'package:dishtv_agent_tracker/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:dishtv_agent_tracker/presentation/features/add_entry/bloc/add_entry_state.dart';

class AddEntryScreen extends StatelessWidget {
  final DailyEntry? entryToEdit;

  const AddEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddEntryBloc(
        repository: context.read<PerformanceRepository>(),
      )..add(InitializeAddEntry(entry: entryToEdit)),
      child: const AddEntryView(),
    );
  }
}

class AddEntryView extends StatelessWidget {
  const AddEntryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddEntryBloc, AddEntryState>(
      listener: (context, state) {
        if (state.status == AddEntryStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.isUpdate
                      ? 'Entry updated successfully!'
                      : 'Entry added successfully!',
                ),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          // Dashboard par wapas jaakar refresh karein
          Navigator.pop(context, true);
        } else if (state.status == AddEntryStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to save entry'),
                backgroundColor: AppColors.accentRed,
              ),
            );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
            title: context.watch<AddEntryBloc>().state.isUpdate
                ? 'Edit Entry'
                : 'Add New Entry'),
        body: BlocBuilder<AddEntryBloc, AddEntryState>(
          builder: (context, state) {
            if (state.status == AddEntryStatus.initial || state.status == AddEntryStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selection
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: state.isUpdate ? null : () => _selectDate(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: state.isUpdate
                                  ? AppColors.divider
                                  : AppColors.secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('dd MMM Picardy').format(state.date),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.isUpdate)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Date cannot be edited.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login time
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login Time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeField(
                                context,
                                'Hours',
                                state.loginHours.toString(),
                                (value) => context.read<AddEntryBloc>().add(
                                      LoginHoursChanged(hours: int.tryParse(value) ?? 0),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimeField(
                                context,
                                'Minutes',
                                state.loginMinutes.toString(),
                                (value) => context.read<AddEntryBloc>().add(
                                      LoginMinutesChanged(minutes: int.tryParse(value) ?? 0),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimeField(
                                context,
                                'Seconds',
                                state.loginSeconds.toString(),
                                (value) => context.read<AddEntryBloc>().add(
                                      LoginSecondsChanged(seconds: int.tryParse(value) ?? 0),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Call count
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call Count',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: state.callCount.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter number of calls',
                            prefixIcon: Icon(Icons.call),
                          ),
                          onChanged: (value) {
                            context.read<AddEntryBloc>().add(
                                  CallCountChanged(callCount: int.tryParse(value) ?? 0),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: state.isUpdate ? 'Update Entry' : 'Add Entry',
                      onPressed: () {
                              context.read<AddEntryBloc>().add(const SubmitEntry());
                            },
                      icon: state.isUpdate ? Icons.update : Icons.add,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    String label,
    String initialValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '0',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final bloc = context.read<AddEntryBloc>();
    final currentDate = bloc.state.date;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.dishTvOrange,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      bloc.add(DateChanged(date: selectedDate));
    }
  }
}
