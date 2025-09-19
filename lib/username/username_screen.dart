import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import 'username_bloc.dart';
import '../home/home_screen.dart';

class UsernameScreen extends StatelessWidget {
  final String phoneNumber;
  
  const UsernameScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsernameBloc(),
      child: _UsernameView(phoneNumber: phoneNumber),
    );
  }
}

class _UsernameView extends StatelessWidget {
  final String phoneNumber;
  
  const _UsernameView({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsernameBloc, UsernameState>(
      listenWhen: (p, c) => p.registerResponse != c.registerResponse && c.registerResponse != null,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.black12,
                elevation: 4,
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _NameField(),
              const SizedBox(height: 16),
              _ContinueButton(phoneNumber: phoneNumber),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsernameBloc, UsernameState>(
      builder: (context, state) {
        return TextField(
          onChanged: (value) => context.read<UsernameBloc>().add(NameChanged(value)),
          decoration: InputDecoration(
            labelText: 'Name',
            prefixStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            errorText: state.errorMessage,
          ),
        );
      },
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final String phoneNumber;
  
  const _ContinueButton({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsernameBloc, UsernameState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: state.isValid && !state.isSubmitting
                ? () => context.read<UsernameBloc>().add(SubmitPressed(phoneNumber))
                : null,
            child: state.isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Continue',style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }
}
