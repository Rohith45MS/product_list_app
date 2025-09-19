import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'otp_bloc.dart';
import '../username/username_screen.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.phone, required this.otp});
  final String phone;
  final String otp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpBloc()..add(OtpStarted(phone: phone, otp: otp)),
      child: _OtpView(phone: phone, otp: otp),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView({required this.phone, required this.otp});
  final String phone;
  final String otp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<OtpBloc, OtpState>(
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
                Text(
                  'OTP VERIFICATION',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Enter the OTP sent to - '),
                      TextSpan(
                        text: '+91-$phone',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Development OTP Display
                if (otp.isNotEmpty) ...[
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'OTP is: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: otp,
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                const _OtpInputRow(),
                const SizedBox(height: 12),
                Center(
                  child: BlocBuilder<OtpBloc, OtpState>(
                    buildWhen:
                        (p, c) => p.secondsRemaining != c.secondsRemaining,
                    builder: (context, state) {
                      final m = (state.secondsRemaining ~/ 60)
                          .toString()
                          .padLeft(2, '0');
                      final s = (state.secondsRemaining % 60)
                          .toString()
                          .padLeft(2, '0');
                      return Text(
                        '00:$m$s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: BlocBuilder<OtpBloc, OtpState>(
                    builder: (context, state) {
                      final canTap = state.canResend;
                      final style = theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      );
                      return RichText(
                        text: TextSpan(
                          style: style,
                          children: [
                            const TextSpan(text: "Don't receive code ? "),
                            TextSpan(
                              text: 'Re-send',
                              style: const TextStyle(
                                color: Color(0xFF06C167),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap =
                                        canTap
                                            ? () => context.read<OtpBloc>().add(
                                              OtpResendRequested(),
                                            )
                                            : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                BlocBuilder<OtpBloc, OtpState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            state.isValid && !state.isSubmitting
                                ? () =>
                                    context.read<OtpBloc>().add(OtpSubmitted())
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary
                              .withOpacity(0.5),
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
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpInputRow extends StatefulWidget {
  const _OtpInputRow();

  @override
  State<_OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<_OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncFromState(OtpState state) {
    final code = state.code.padRight(4);
    for (int i = 0; i < 4; i++) {
      final ch = i < code.length ? code[i] : '';
      final current = _controllers[i].text;
      if (current != ch.trim()) {
        _controllers[i].text = ch.trim();
      }
    }
  }

  void _updateBlocWithCurrentCode(BuildContext context) {
    final combined = _controllers.map((c) => c.text).join();
    context.read<OtpBloc>().add(OtpCodeChanged(combined));
  }

  void _handleChanged(BuildContext context, int index, String value) {
    // Accept only digits
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length <= 1) {
      _controllers[index].text = digitsOnly;
      _controllers[index].selection = TextSelection.collapsed(
        offset: digitsOnly.length,
      );
      if (digitsOnly.isNotEmpty && index < 3) {
        _focusNodes[index + 1].requestFocus();
      }
      _updateBlocWithCurrentCode(context);
      return;
    }

    // Handle paste of multiple digits,
    final chars = digitsOnly.split('');
    int cursor = index;
    for (final ch in chars) {
      if (cursor > 3) break;
      _controllers[cursor].text = ch;
      cursor += 1;
    }
    if (cursor <= 3) {
      _focusNodes[cursor].requestFocus();
    } else {
      _focusNodes[3].unfocus();
    }
    _updateBlocWithCurrentCode(context);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event, int index) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      final hasText = _controllers[index].text.isNotEmpty;
      if (!hasText && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].text = '';
        _updateBlocWithCurrentCode(context);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpBloc, OtpState>(
      listenWhen: (p, c) => p.code != c.code,
      listener: (context, state) => _syncFromState(state),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          return SizedBox(
            width: 72,
            height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Focus(
                  focusNode: _focusNodes[index],
                  onKeyEvent: (node, event) => _onKey(node, event, index),
                  child: TextField(
                    controller: _controllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    textInputAction:
                        index < 3 ? TextInputAction.next : TextInputAction.done,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (v) => _handleChanged(context, index, v),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
