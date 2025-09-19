import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/preferences_service.dart';
import '../core/models/register_request.dart';

class OtpEvent {}

class OtpStarted extends OtpEvent {
  OtpStarted({
    required this.phone,
    required this.otp,
    this.duration = const Duration(seconds: 120),
  });
  final String phone;
  final String otp;
  final Duration duration;
}

class OtpCodeChanged extends OtpEvent {
  OtpCodeChanged(this.code);
  final String code;
}

class OtpResendRequested extends OtpEvent {}

class OtpSubmitted extends OtpEvent {}

class _OtpTicked extends OtpEvent {
  _OtpTicked(this.secondsRemaining);
  final int secondsRemaining;
}

class OtpState {
  const OtpState({
    required this.phone,
    required this.code,
    required this.secondsRemaining,
    required this.isSubmitting,
    this.errorMessage,
    this.expectedOtp,
  });

  final String phone;
  final String code; // 0-4 digits
  final int secondsRemaining; // 0 when can resend
  final bool isSubmitting;
  final String? errorMessage;
  final String? expectedOtp;

  bool get isValid => code.length == 4;
  bool get canResend => secondsRemaining == 0 && !isSubmitting;

  OtpState copyWith({
    String? phone,
    String? code,
    int? secondsRemaining,
    bool? isSubmitting,
    String? errorMessage,
    String? expectedOtp,
  }) {
    return OtpState(
      phone: phone ?? this.phone,
      code: code ?? this.code,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      expectedOtp: expectedOtp ?? this.expectedOtp,
    );
  }

  factory OtpState.initial() => const OtpState(
    phone: '',
    code: '',
    secondsRemaining: 0,
    isSubmitting: false,
  );
}

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc() : super(OtpState.initial()) {
    on<OtpStarted>(_onStarted);
    on<OtpCodeChanged>(_onCodeChanged);
    on<OtpResendRequested>(_onResend);
    on<OtpSubmitted>(_onSubmit);
    on<_OtpTicked>(_onTicked);
  }

  Timer? _timer;

  void _onStarted(OtpStarted event, Emitter<OtpState> emit) {
    _startTimer(event.duration, emit);
    emit(
      state.copyWith(
        phone: event.phone,
        code: '',
        expectedOtp: event.otp,
        errorMessage: null,
      ),
    );
  }

  void _startTimer(Duration duration, Emitter<OtpState> emit) {
    _timer?.cancel();
    emit(state.copyWith(secondsRemaining: duration.inSeconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = state.secondsRemaining - 1;
      add(_OtpTicked(next < 0 ? 0 : next));
      if (next <= 0) {
        t.cancel();
      }
    });
  }

  void _onTicked(_OtpTicked event, Emitter<OtpState> emit) {
    emit(state.copyWith(secondsRemaining: event.secondsRemaining));
  }

  void _onCodeChanged(OtpCodeChanged event, Emitter<OtpState> emit) {
    final sanitized = event.code.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated =
        sanitized.length > 4 ? sanitized.substring(0, 4) : sanitized;
    emit(state.copyWith(code: truncated, errorMessage: null));
  }

  Future<void> _onResend(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canResend) return;
    _startTimer(const Duration(seconds: 120), emit);
  }

  Future<void> _onSubmit(OtpSubmitted event, Emitter<OtpState> emit) async {
    if (!state.isValid || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      // Verify OTP
      if (state.expectedOtp != null && state.code == state.expectedOtp) {
        // OTP is correct, save token and navigate to home
        print('OTP verified successfully. Saving token...');

        // Get the token from preferences (it should have been saved during login)
        final token = PreferencesService.getToken();
        if (token != null) {
          await PreferencesService.setLoggedIn(true);
          print('User logged in successfully');
          emit(state.copyWith(isSubmitting: false));
        } else {
          emit(
            state.copyWith(
              isSubmitting: false,
              errorMessage: 'Token not found. Please try again.',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Invalid OTP. Please try again.',
          ),
        );
      }
    } catch (e) {
      print('OTP verification error: $e');
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'An error occurred: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
