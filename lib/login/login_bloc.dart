import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/auth_service.dart';
import '../core/services/preferences_service.dart';
import '../core/models/login_request.dart';
import '../core/models/verify_response.dart';

sealed class LoginEvent {}

class PhoneChanged extends LoginEvent {
  PhoneChanged(this.phone);
  final String phone;
}

class SubmitPressed extends LoginEvent {}

class LoginState {
  const LoginState({
    required this.phone_number,
    required this.isValid,
    required this.isSubmitting,
    this.errorMessage,
    this.verifyResponse,
  });

  final String phone_number;
  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;
  final VerifyResponse? verifyResponse;

  LoginState copyWith({
    String? phone_number,
    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
    VerifyResponse? verifyResponse,
  }) {
    return LoginState(
      phone_number: phone_number ?? this.phone_number,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      verifyResponse: verifyResponse ?? this.verifyResponse,
    );
  }

  factory LoginState.initial() =>
      const LoginState(phone_number: '', isValid: false, isSubmitting: false);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService = AuthService();

  LoginBloc() : super(LoginState.initial()) {
    on<PhoneChanged>(_onPhoneChanged);
    on<SubmitPressed>(_onSubmit);
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<LoginState> emit) {
    final sanitized = event.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final isValid = sanitized.length >= 10 && sanitized.length <= 12;
    emit(
      state.copyWith(
        phone_number: sanitized,
        isValid: isValid,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSubmit(SubmitPressed event, Emitter<LoginState> emit) async {
    if (!state.isValid || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final request = LoginRequest(phone: state.phone_number);
      final response = await _authService.verifyPhone(request);

      print(
        'Login response: ${response.token}, user: ${response.user}, otp: ${response.otp}',
      );

      if (response.success) {
        // Save phone number for later use
        await PreferencesService.savePhoneNumber(state.phone_number);

        // If user exists and has token, save the token
        if (response.user == true && response.token != null) {
          await PreferencesService.saveToken(response.token!);
          print('Token saved: ${response.token}');
        }

        emit(state.copyWith(isSubmitting: false, verifyResponse: response));
      } else {
        emit(
          state.copyWith(isSubmitting: false, errorMessage: response.message),
        );
      }
    } catch (e) {
      print('Login error: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'An error occurred: $e',
        ),
      );
    }
  }
}
