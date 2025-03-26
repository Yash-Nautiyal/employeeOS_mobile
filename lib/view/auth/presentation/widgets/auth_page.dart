import 'package:employeeos/core/common/textbutton/textbutton.dart';
import 'package:employeeos/core/common/textfield/textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    return Column(
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
            passwordController: widget.emailController,
            theme: theme,
            hintText: "Email address",
            labelText: "Email Address",
            onchange: (text) {
              setState(() {
                widget.emailController.text = text;
              });
            },
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        CustomTextfield(
          keyboardType: TextInputType.visiblePassword,
          passwordController: widget.passwordController,
          isPasswordVisible: isPasswordVisible,
          onchange: (text) {
            setState(() {
              widget.passwordController.text = text;
            });
          },
          theme: theme,
          hintText: "6+ characters",
          labelText: "Password",
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
              child: CustomTextButton(
                onClick: () {},
                backgroundColor: theme.colorScheme.tertiary,
                child: Text(
                  "Sign in",
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.scaffoldBackgroundColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'OR',
                  style: TextStyle(color: theme.disabledColor),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: CustomTextButton(
                  onClick: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/logo/ic-google.svg',
                        width: 30,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        "Continue with Google",
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.tertiary, fontSize: 16),
                      ),
                    ],
                  )),
            ),
          ],
        )
      ],
    );
  }
}
