import 'dart:typed_data';

import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/auth/data/auth_repository.dart';
import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/core/common/components/custom_toast.dart';
import 'package:employeeos/core/user/user_creation_service.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/core/user/user_role.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_general.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:toastification/toastification.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final designationController = TextEditingController();
  final dateOfJoiningController = TextEditingController();
  final dateofRelievingController = TextEditingController();
  final roleController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String _role = UserRole.employee.name;
  Uint8List? _avatarBytes;
  String? _avatarContentType;
  bool _isSubmitting = false;
  bool _isPickingAvatar = false;

  late final VoidCallback _listener = () {
    if (mounted) setState(() {});
  };

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_listener);
    lastNameController.addListener(_listener);
    emailController.addListener(_listener);
    phoneController.addListener(_listener);
    passwordController.addListener(_listener);
    confirmPasswordController.addListener(_listener);
  }

  @override
  void dispose() {
    firstNameController.removeListener(_listener);
    lastNameController.removeListener(_listener);
    emailController.removeListener(_listener);
    phoneController.removeListener(_listener);
    passwordController.removeListener(_listener);
    confirmPasswordController.removeListener(_listener);
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    designationController.dispose();
    dateOfJoiningController.dispose();
    dateofRelievingController.dispose();
    roleController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final email = emailController.text.trim();
    final pw = passwordController.text;
    final confirm = confirmPasswordController.text;
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      return false;
    }
    if (email.isEmpty || !email.contains('@')) return false;
    if (pw.length < 6 || pw != confirm) return false;
    return true;
  }

  Future<void> _pickAvatar() async {
    if (_isPickingAvatar) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (x == null || !mounted) return;
    final bytes = await x.readAsBytes();
    if (bytes.length > UserInfoService.maxAvatarBytes) {
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'File too large',
        description: 'Please choose an image under 3.1 MB.',
      );
      return;
    }
    setState(() {
      _avatarBytes = Uint8List.fromList(bytes);
      _avatarContentType = lookupMimeType(x.path) ?? 'image/jpeg';
    });
  }

  Future<void> _createUser() async {
    if (!_canSubmit || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<UserCreationService>().createUser(
            email: emailController.text.trim(),
            password: passwordController.text,
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            role: _role,
            phone: phoneController.text,
            dateOfBirth: dateOfBirthController.text,
            designation: designationController.text,
            dateOfJoining: dateOfJoiningController.text,
            dateOfRelieving: dateofRelievingController.text,
            avatarBytes: _avatarBytes?.toList(),
            avatarContentType: _avatarContentType,
          );
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthRefreshProfileRequested());
      _clearForm();
      showCustomToast(
        context: context,
        type: ToastificationType.success,
        title: 'User created',
        description: 'The new user can sign in with the email and password you set.',
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not create user',
        description: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not create user',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    dateOfBirthController.clear();
    designationController.clear();
    dateOfJoiningController.clear();
    dateofRelievingController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    setState(() {
      _role = UserRole.employee.name;
      _avatarBytes = null;
      _avatarContentType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<AuthBloc>().state.currentProfile;
    final allowed = profile != null && !profile.isEmployee;

    if (!allowed) {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBreadCrumbs(
              theme: theme,
              routes: const ['Dashboard', 'User', 'Create User'],
              heading: 'Create User',
            ),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'You do not have permission to create users.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBreadCrumbs(
              theme: theme,
              routes: const ['Dashboard', 'User', 'Create User'],
              heading: 'Create User',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: UserAccountGeneral(
                theme: theme,
                avatarUrl: null,
                localAvatarBytes: _avatarBytes,
                roleController: roleController,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                emailController: emailController,
                phoneController: phoneController,
                dateOfBirthController: dateOfBirthController,
                designationController: designationController,
                dateOfJoiningController: dateOfJoiningController,
                dateofRelievingController: dateofRelievingController,
                saveEnabled: _canSubmit,
                isSaving: _isSubmitting,
                isUploadingAvatar: _isPickingAvatar,
                onSave: _createUser,
                onAvatarTap: () async {
                  setState(() => _isPickingAvatar = true);
                  try {
                    await _pickAvatar();
                  } finally {
                    if (mounted) setState(() => _isPickingAvatar = false);
                  }
                },
                isCreateUserFlow: true,
                primaryButtonLabel: 'Create user',
                primaryButtonLoadingLabel: 'Creating…',
                avatarActionLabel: 'Add photo',
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                roleDropdownValue: _role,
                onRoleChanged: (value) {
                  if (value is String && value.isNotEmpty) {
                    setState(() => _role = value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
