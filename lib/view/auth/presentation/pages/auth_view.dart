import 'package:employeeos/core/common/components/custom_toast.dart';
import 'package:employeeos/core/common/components/home_nav.dart';
import 'package:employeeos/view/auth/data/auth_repository.dart';
import 'package:employeeos/view/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:employeeos/view/auth/presentation/widgets/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (ctx) => SignInCubit(ctx.read<AuthRepository>()),
      child: BlocBuilder<SignInCubit, SignInState>(
        builder: (context, state) {
          final isSigningIn = state.isLoading;
          return PopScope(
            canPop: !isSigningIn,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && isSigningIn) {
                showCustomToast(
                  context: context,
                  type: ToastificationType.info,
                  title: 'Sign-in in progress',
                  description: 'Please wait until sign-in completes.',
                );
              }
            },
            child: Scaffold(
              appBar: HomeNav(
                theme: theme,
                backDisabled: isSigningIn,
                onBackPressedWhenDisabled: () {
                  showCustomToast(
                    context: context,
                    type: ToastificationType.info,
                    title: 'Sign-in in progress',
                    description: 'Please wait until sign-in completes.',
                  );
                },
              ),
              extendBody: true,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15)
                      .copyWith(top: 25),
                  child: Column(
                    children: [
                      AuthPage(
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
