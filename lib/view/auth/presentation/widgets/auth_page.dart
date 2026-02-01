import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/common/components/custom_toast.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/auth/presentation/bloc/auth_bloc.dart';
import 'package:employeeos/view/layout/presentation/pages/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class AuthPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const AuthPage(
      {super.key,
      required this.emailController,
      required this.passwordController});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthListenState,
      listener: (context, state) {
        if (state is AuthError) {
          showCustomToast(
            context: context,
            type: ToastificationType.error,
            title: 'Error',
            description: state.message,
          );
        }
        if (state is AuthSuccessState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Layout()),
            (route) => false,
          );
          showCustomToast(
            context: context,
            type: ToastificationType.success,
            title: 'Success',
            description: state.message,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign in to your account',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: 'Don\'t have an account? ',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.disabledColor),
              children: [
                TextSpan(
                  text: 'Contact the Admin for your Credentials',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppPallete.primaryMain),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomTextfield(
              controller: widget.emailController,
              theme: theme,
              hintText: "Email address",
              labelText: "Email Address",
              onchange: (text) {},
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          CustomTextfield(
            keyboardType: TextInputType.visiblePassword,
            controller: widget.passwordController,
            isPasswordVisible: isPasswordVisible,
            onchange: (text) {},
            theme: theme,
            hintText: "Password",
            labelText: "6+ characters",
            onClickPasswordVisisble: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot password?',
              style: theme.textTheme.bodyMedium?.copyWith(),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) =>
                      current is AuthLoading || previous is AuthLoading,
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return CustomTextButton(
                      onClick: isLoading
                          ? () {}
                          : () {
                              final email = widget.emailController.text.trim();
                              final password = widget.passwordController.text;
                              if (email.isEmpty || password.isEmpty) {
                                showCustomToast(
                                  context: context,
                                  type: ToastificationType.error,
                                  title: 'Error',
                                  description: 'Enter email and password.',
                                );
                                return;
                              }
                              context.read<AuthBloc>().add(
                                    AuthSignInRequested(
                                      email: email,
                                      password: password,
                                    ),
                                  );
                            },
                      backgroundColor: isLoading
                          ? theme.disabledColor.withAlpha(150)
                          : theme.colorScheme.tertiary,
                      child: Text(
                        isLoading ? "Sign in..." : "Sign in",
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: isLoading
                                ? theme.disabledColor
                                : theme.scaffoldBackgroundColor,
                            fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10.0),
          //   child: Row(
          //     children: [
          //       Expanded(child: Divider(color: theme.dividerColor)),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         child: Text(
          //           'OR',
          //           style: TextStyle(color: theme.disabledColor),
          //         ),
          //       ),
          //       Expanded(child: Divider(color: theme.dividerColor)),
          //     ],
          //   ),
          // ),
          // Row(
          //   mainAxisSize: MainAxisSize.max,
          //   children: [
          //     Expanded(
          //       child: CustomTextButton(
          //         onClick: () {},
          //         child: Row(
          //           mainAxisSize: MainAxisSize.max,
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             SvgPicture.asset(
          //               'assets/logo/ic-google.svg',
          //               width: 30,
          //             ),
          //             const SizedBox(
          //               width: 6,
          //             ),
          //             Text(
          //               "Continue with Google",
          //               style: theme.textTheme.labelLarge?.copyWith(
          //                   color: theme.colorScheme.tertiary, fontSize: 16),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
