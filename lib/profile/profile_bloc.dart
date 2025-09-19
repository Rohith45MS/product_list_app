import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../core/services/preferences_service.dart';
import '../core/api/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Events
abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

// States
abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String phone;
  ProfileLoaded({required this.name, required this.phone});
  @override
  List<Object?> get props => [name, phone];
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final token = await PreferencesService.getToken();
        print('Saved Token: $token'); // Print the token

        if (token == null) {
          emit(ProfileError("No token found"));
          return;
        }
        final response = await http.get(
          Uri.parse('https://skilltestflutter.zybotechlab.com/api/user-data/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print('API Response: ${response.body}'); // Print the response

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          emit(
            ProfileLoaded(
              name: data['name'] ?? 'No Name',
              phone: data['phone_number'] ?? 'No Number',
            ),
          );
        } else {
          emit(ProfileError("failed to load the profile data from the api user-data"));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
