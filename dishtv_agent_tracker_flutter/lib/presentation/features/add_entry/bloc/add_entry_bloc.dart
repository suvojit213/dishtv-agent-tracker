import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';
import 'package:dishtv_agent_tracker/domain/repositories/performance_repository.dart';
import 'package:dishtv_agent_tracker/domain/usecases/add_entry_usecase.dart';
import 'package:dishtv_agent_tracker/domain/usecases/update_entry_usecase.dart';
import 'package:dishtv_agent_tracker/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:dishtv_agent_tracker/presentation/features/add_entry/bloc/add_entry_state.dart';

class AddEntryBloc extends Bloc<AddEntryEvent, AddEntryState> {
  final PerformanceRepository repository;
  late final AddEntryUseCase _addEntryUseCase;
  late final UpdateEntryUseCase _updateEntryUseCase;

  AddEntryBloc({required this.repository}) : super(AddEntryState.initial()) {
    _addEntryUseCase = AddEntryUseCase(repository);
    _updateEntryUseCase = UpdateEntryUseCase(repository);

    on<InitializeAddEntry>(_onInitializeAddEntry);
    on<DateChanged>(_onDateChanged);
    on<LoginHoursChanged>(_onLoginHoursChanged);
    on<LoginMinutesChanged>(_onLoginMinutesChanged);
    on<LoginSecondsChanged>(_onLoginSecondsChanged);
    on<CallCountChanged>(_onCallCountChanged);
    on<SubmitEntry>(_onSubmitEntry);
  }

  Future<void> _onInitializeAddEntry(
    InitializeAddEntry event,
    Emitter<AddEntryState> emit,
  ) async {
    // Agar entry seedhe pass ki gayi hai (edit mode), to use use karein
    if (event.entry != null) {
      emit(state.copyWith(
        status: AddEntryStatus.loaded,
        date: event.entry!.date,
        loginHours: event.entry!.loginHours,
        loginMinutes: event.entry!.loginMinutes,
        loginSeconds: event.entry!.loginSeconds,
        callCount: event.entry!.callCount,
        existingEntry: event.entry,
      ));
      return;
    }

    // Varna, date ke aadhar par entry check karein
    final date = event.date ?? DateTime.now();
    try {
      final existingEntry = await repository.getEntryForDate(date);

      if (existingEntry != null) {
        emit(state.copyWith(
          status: AddEntryStatus.loaded,
          date: date,
          loginHours: existingEntry.loginHours,
          loginMinutes: existingEntry.loginMinutes,
          loginSeconds: existingEntry.loginSeconds,
          callCount: existingEntry.callCount,
          existingEntry: existingEntry,
        ));
      } else {
        emit(state.copyWith(
          status: AddEntryStatus.loaded,
          date: date,
          loginHours: 0,
          loginMinutes: 0,
          loginSeconds: 0,
          callCount: 0,
          existingEntry: null, // existingEntry ko null set karein
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        date: date,
        errorMessage: 'Failed to check for existing entry: ${e.toString()}',
      ));
    }
  }

  void _onDateChanged(
    DateChanged event,
    Emitter<AddEntryState> emit,
  ) {
    // Status ko initial par set karein jab date change ho
    emit(state.copyWith(status: AddEntryStatus.initial));
    add(InitializeAddEntry(date: event.date));
  }

  void _onLoginHoursChanged(
    LoginHoursChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginHours: event.hours));
  }

  void _onLoginMinutesChanged(
    LoginMinutesChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginMinutes: event.minutes));
  }

  void _onLoginSecondsChanged(
    LoginSecondsChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(loginSeconds: event.seconds));
  }

  void _onCallCountChanged(
    CallCountChanged event,
    Emitter<AddEntryState> emit,
  ) {
    emit(state.copyWith(callCount: event.callCount));
  }

  Future<void> _onSubmitEntry(
    SubmitEntry event,
    Emitter<AddEntryState> emit,
  ) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Please enter valid values for all fields',
      ));
      // status ko loaded par wapas set karein taki UI fir se dikhe
      emit(state.copyWith(status: AddEntryStatus.loaded));
      return;
    }

    emit(state.copyWith(status: AddEntryStatus.loading));

    try {
      final entry = state.toEntry();

      if (state.isUpdate) {
        await _updateEntryUseCase.execute(entry);
      } else {
        await _addEntryUseCase.execute(entry);
      }

      emit(state.copyWith(
        status: AddEntryStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddEntryStatus.failure,
        errorMessage: 'Failed to save entry: ${e.toString()}',
      ));
    }
  }
}
