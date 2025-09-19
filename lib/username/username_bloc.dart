import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/models/register_request.dart';
import '../core/models/register_response.dart';
import '../core/services/preferences_service.dart';

// Events
abstract class UsernameEvent {}

class NameChanged extends UsernameEvent {
  final String name;
  NameChanged(this.name);
}

class SubmitPressed extends UsernameEvent {
  final String phoneNumber;
  SubmitPressed(this.phoneNumber);
}

// State
class UsernameState {
  final String name;
  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;
  final RegisterResponse? registerResponse;

  UsernameState({
    this.name = '',
    this.isValid = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.registerResponse,
  });

  UsernameState copyWith({
    String? name,
    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
    RegisterResponse? registerResponse,
  }) {
    return UsernameState(
      name: name ?? this.name,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      registerResponse: registerResponse ?? this.registerResponse,
    );
  }
}

class UsernameBloc extends Bloc<UsernameEvent, UsernameState> {
  UsernameBloc() : super(UsernameState()) {
    on<NameChanged>(_onNameChanged);
    on<SubmitPressed>(_onSubmitPressed);
  }

  void _onNameChanged(NameChanged event, Emitter<UsernameState> emit) {
    emit(state.copyWith(
      name: event.name,
      isValid: event.name.length >= 3,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitPressed(
      SubmitPressed event, Emitter<UsernameState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final request = RegisterRequest(
        phone: event.phoneNumber,
        firstName: state.name,
      );

      final response = await http.post(
        Uri.parse('https://skilltestflutter.zybotechlab.com/api/login-register/'),
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final registerResponse = RegisterResponse.fromJson(data);

        if (data['token'] != null && data['token']['access'] != null) {
          // Save token using PreferencesService
          await PreferencesService.saveLoginData(
            phone: event.phoneNumber,
            token: data['token']['access'],
            firstName: state.name,
          );
          
          emit(state.copyWith(
            isSubmitting: false,
            registerResponse: registerResponse,
          ));
        } else {
          emit(state.copyWith(
            isSubmitting: false,
            errorMessage: 'Invalid response from server: No token received',
          ));
        }
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: 'Registration failed: ${response.statusCode}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Network error occurred: $e',
      ));
    }
  }
}
