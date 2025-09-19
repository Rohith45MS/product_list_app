import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import 'username_bloc.dart';
import '../home/home_screen.dart';

class UsernameScreen extends StatelessWidget {
  const UsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsernameBloc(),
      child: const _UsernameView(),
    );
  }
}

class _UsernameView extends StatelessWidget {
  const _UsernameView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<UsernameBloc, UsernameState>(
      listenWhen: (p, c) => p.isSubmitting && !c.isSubmitting,
      listener: (context, state) {
        if (state.isValid) {
          // Navigate to home screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Enter Full Name',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _NameField(),
                const SizedBox(height: 8),
                _ErrorMessage(),
                const SizedBox(height: 16),
                const _SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  _NameField();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsernameBloc, UsernameState>(
      listenWhen: (p, c) => p.fullName != c.fullName,
      listener: (context, state) {
        if (controller.text != state.fullName) {
          controller.value = TextEditingValue(
            text: state.fullName,
            selection: TextSelection.collapsed(offset: state.fullName.length),
          );
        }
      },
      child: BlocBuilder<UsernameBloc, UsernameState>(
        builder: (context, state) {
          return TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter Full Name',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.fieldBorder, width: 2),
              ),
            ),
            onChanged:
                (v) => context.read<UsernameBloc>().add(UsernameChanged(v)),
            onSubmitted:
                (_) => context.read<UsernameBloc>().add(UsernameSubmitted()),
          );
        },
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsernameBloc, UsernameState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                state.isValid && !state.isSubmitting
                    ? () =>
                        context.read<UsernameBloc>().add(UsernameSubmitted())
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsernameBloc, UsernameState>(
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
