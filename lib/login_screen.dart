import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login/login_bloc.dart';
import 'otp/otp_screen.dart';
import 'username/username_screen.dart';
import 'theme/app_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API client
    return BlocProvider(create: (_) => LoginBloc(), child: const _LoginView());
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Login',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's Connect with Lorem Ipsum..!",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _PhoneField(),
              const SizedBox(height: 8),
              _ErrorMessage(),
              const SizedBox(height: 16),
              const _ContinueButton(),
              const SizedBox(height: 16),
              _TermsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  _PhoneField();

  String _dialCodeFor(BuildContext context) {
    final countryCode =
        Localizations.localeOf(context).countryCode?.toUpperCase();
    const Map<String, String> countryToDial = {'IN': '+91'};
    if (countryCode != null && countryToDial.containsKey(countryCode)) {
      return countryToDial[countryCode]!;
    }
    return '+91';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (p, c) => p.phone_number != c.phone_number,
      listener: (context, state) {
        if (controller.text != state.phone_number) {
          controller.value = TextEditingValue(
            text: state.phone_number,
            selection: TextSelection.collapsed(
              offset: state.phone_number.length,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter Phone',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixText: '${_dialCodeFor(context)}  ',
              prefixStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.fieldBorder, width: 2),
              ),
            ),
            onChanged: (v) => context.read<LoginBloc>().add(PhoneChanged(v)),
          );
        },
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen:
          (p, c) =>
              p.isSubmitting && !c.isSubmitting && c.verifyResponse != null,
      listener: (context, state) {
        final response = state.verifyResponse!;

        print(
          'Navigation check - Token: ${response.token}, User: ${response.user}, OTP: ${response.otp}',
        );

        if (response.user == true && response.token != null) {
          // User exists and has token, go to OTP screen
          print('Navigating to OTP screen');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => OtpScreen(
                    phone: state.phone_number,
                    otp: response.otp ?? '',
                  ),
            ),
          );
        } else if (response.user == false) {
          // User doesn't exist, go to username screen
          print('Navigating to Username screen');
          // In _ContinueButton class, update the navigation to UsernameScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UsernameScreen(phoneNumber: state.phone_number),
            ),
          );
        } else {
          // Handle other cases or show error
          print('Unexpected response: ${response.token}, ${response.user}');
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  state.isValid && !state.isSubmitting
                      ? () {
                        context.read<LoginBloc>().add(SubmitPressed());
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  state.isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontSize: 12,
    );
    final link = style?.copyWith(
      decoration: TextDecoration.underline,
      color: AppColors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'By Continuing you accepting the '),
              TextSpan(
                text: 'Terms of Use',
                style: link,
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
              const TextSpan(text: ' & '),
              TextSpan(
                text: 'Privacy Policy',
                style: link,
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
