import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/preferences_service.dart';
import '../core/models/verify_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // All API-related code removed from this file. Use local/mock data for login.

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
      final response = await http.post(
        Uri.parse('https://skilltestflutter.zybotechlab.com/api/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': state.phone_number}),
      );
      final data = jsonDecode(response.body);

      // Save token if present
      if (data['token'] != null && data['token']['access'] != null) {
        await PreferencesService.setToken(data['token']['access']);
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          verifyResponse: VerifyResponse(
            success: data['success'] ?? true,
            message: data['message']?.toString() ?? 'Success',
            otp: data['otp']?.toString(),
            token: data['token']?['access'],
            user: data['user'],
          ),
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to login. Please try again.',
        ),
      );
    }
  }
}
