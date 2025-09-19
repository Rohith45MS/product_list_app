import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/auth_service.dart';
import '../core/services/preferences_service.dart';
import '../core/models/register_request.dart';

sealed class UsernameEvent {}

class UsernameChanged extends UsernameEvent {
  UsernameChanged(this.fullName);
  final String fullName;
}

class UsernameSubmitted extends UsernameEvent {}

class UsernameState {
  const UsernameState({
    required this.fullName,
    required this.isValid,
    required this.isSubmitting,
    this.errorMessage,
  });

  final String fullName;
  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;

  UsernameState copyWith({
    String? fullName,
    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return UsernameState(
      fullName: fullName ?? this.fullName,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  factory UsernameState.initial() =>
      const UsernameState(fullName: '', isValid: false, isSubmitting: false);
}

class UsernameBloc extends Bloc<UsernameEvent, UsernameState> {
  final AuthService _authService = AuthService();

  UsernameBloc() : super(UsernameState.initial()) {
    on<UsernameChanged>(_onChanged);
    on<UsernameSubmitted>(_onSubmit);
  }

  void _onChanged(UsernameChanged event, Emitter<UsernameState> emit) {
    final normalized = event.fullName.replaceAll(RegExp(r"\s+"), ' ').trim();
    final isValid = _isNameValid(normalized);
    emit(
      state.copyWith(
        fullName: normalized,
        isValid: isValid,
        errorMessage: null,
      ),
    );
  }

  bool _isNameValid(String name) {
    if (name.isEmpty) return false;
    if (name.length < 3) return false;
    if (!RegExp(r'^[A-Za-z][A-Za-z .]*[A-Za-z]$').hasMatch(name)) return false;
    return true;
  }

  Future<void> _onSubmit(
    UsernameSubmitted event,
    Emitter<UsernameState> emit,
  ) async {
    if (!state.isValid || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final phone = PreferencesService.getPhoneNumber() ?? '';
      final request = RegisterRequest(phone: phone, firstName: state.fullName);

      final response = await _authService.register(request);

      if (response.success && response.token != null) {
        // Save user data with token
        await PreferencesService.saveUserData(
          phone: phone,
          token: response.token!,
          firstName: state.fullName,
        );
        emit(state.copyWith(isSubmitting: false));
      } else {
        emit(
          state.copyWith(isSubmitting: false, errorMessage: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'An error occurred: $e',
        ),
      );
    }
  }
}
