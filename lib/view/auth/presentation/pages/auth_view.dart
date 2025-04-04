import 'package:employeeos/core/common/nav/home_nav.dart';
import 'package:employeeos/view/auth/presentation/widgets/auth_page.dart';
import 'package:flutter/material.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: HomeNav(
        theme: theme,
      ),
      extendBody: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 25),
          child: Column(
            children: [
              AuthPage(
                  emailController: _emailController,
                  passwordController: _passwordController)
            ],
          ),
        ),
      ),
    );
  }
}
