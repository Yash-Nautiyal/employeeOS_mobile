// ignore_for_file: prefer_function_declarations_over_variables

import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/auth/data/auth_repository.dart';
import 'package:employeeos/core/common/components/ui/custom_toast.dart';
import 'package:employeeos/core/user/current_user_profile.dart';
import 'package:employeeos/core/user/user_account_sync_service.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/core/common/components/ui/custom_bread_crumbs.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_general.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_security.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_social_links.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:toastification/toastification.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isPublicProfile = true;
  String selectedCountry = 'Country';

  late TextEditingController facebookController;
  late TextEditingController instagramController;
  late TextEditingController xController;
  late TextEditingController linkedinController;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late String? avatarUrl;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dateOfBirthController;
  late TextEditingController designationController;
  late TextEditingController dateOfJoiningController;
  late TextEditingController dateofRelievingController;
  late TextEditingController roleController;

  bool _applyingProfile = false;
  bool _isSaving = false;
  bool _isSavingSocial = false;
  bool _isSavingPassword = false;
  bool _isUploadingAvatar = false;

  String _baseFirst = '';
  String _baseLast = '';
  String _basePhone = '';
  String _baseDob = '';
  String _baseDesignation = '';
  String _baseJoining = '';
  String _baseRelieving = '';

  String _baseFacebook = '';
  String _baseInstagram = '';
  String _baseTwitter = '';
  String _baseLinkedin = '';

  late final VoidCallback _generalFieldListener = () {
    if (!mounted || _applyingProfile) return;
    setState(() {});
  };

  late final VoidCallback _socialFieldListener = () {
    if (!mounted || _applyingProfile) return;
    setState(() {});
  };

  late final VoidCallback _securityPasswordListener = () {
    if (!mounted) return;
    setState(() {});
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    dateOfBirthController = TextEditingController();
    designationController = TextEditingController();
    dateOfJoiningController = TextEditingController();
    dateofRelievingController = TextEditingController();
    roleController = TextEditingController();
    avatarUrl = '';

    facebookController = TextEditingController();
    instagramController = TextEditingController();
    xController = TextEditingController();
    linkedinController = TextEditingController();

    _attachSecurityPasswordListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyProfile(context.read<AuthBloc>().state.currentProfile);
    });
  }

  void _attachGeneralListeners() {
    firstNameController.addListener(_generalFieldListener);
    lastNameController.addListener(_generalFieldListener);
    phoneController.addListener(_generalFieldListener);
    dateOfBirthController.addListener(_generalFieldListener);
    designationController.addListener(_generalFieldListener);
    dateOfJoiningController.addListener(_generalFieldListener);
    dateofRelievingController.addListener(_generalFieldListener);
  }

  void _detachGeneralListeners() {
    firstNameController.removeListener(_generalFieldListener);
    lastNameController.removeListener(_generalFieldListener);
    phoneController.removeListener(_generalFieldListener);
    dateOfBirthController.removeListener(_generalFieldListener);
    designationController.removeListener(_generalFieldListener);
    dateOfJoiningController.removeListener(_generalFieldListener);
    dateofRelievingController.removeListener(_generalFieldListener);
  }

  void _attachSocialListeners() {
    facebookController.addListener(_socialFieldListener);
    instagramController.addListener(_socialFieldListener);
    xController.addListener(_socialFieldListener);
    linkedinController.addListener(_socialFieldListener);
  }

  void _detachSocialListeners() {
    facebookController.removeListener(_socialFieldListener);
    instagramController.removeListener(_socialFieldListener);
    xController.removeListener(_socialFieldListener);
    linkedinController.removeListener(_socialFieldListener);
  }

  void _captureSocialBaseline() {
    _baseFacebook = facebookController.text;
    _baseInstagram = instagramController.text;
    _baseTwitter = xController.text;
    _baseLinkedin = linkedinController.text;
  }

  bool get _socialDirty {
    return facebookController.text != _baseFacebook ||
        instagramController.text != _baseInstagram ||
        xController.text != _baseTwitter ||
        linkedinController.text != _baseLinkedin;
  }

  void _attachSecurityPasswordListeners() {
    oldPasswordController.addListener(_securityPasswordListener);
    newPasswordController.addListener(_securityPasswordListener);
    confirmPasswordController.addListener(_securityPasswordListener);
  }

  void _detachSecurityPasswordListeners() {
    oldPasswordController.removeListener(_securityPasswordListener);
    newPasswordController.removeListener(_securityPasswordListener);
    confirmPasswordController.removeListener(_securityPasswordListener);
  }

  bool get _canSubmitPassword {
    final old = oldPasswordController.text;
    final next = newPasswordController.text;
    final confirm = confirmPasswordController.text;
    return old.isNotEmpty && next.length >= 6 && next == confirm;
  }

  void _captureGeneralBaseline() {
    _baseFirst = firstNameController.text;
    _baseLast = lastNameController.text;
    _basePhone = phoneController.text;
    _baseDob = dateOfBirthController.text;
    _baseDesignation = designationController.text;
    _baseJoining = dateOfJoiningController.text;
    _baseRelieving = dateofRelievingController.text;
  }

  bool get _generalDirty {
    return firstNameController.text != _baseFirst ||
        lastNameController.text != _baseLast ||
        phoneController.text != _basePhone ||
        dateOfBirthController.text != _baseDob ||
        designationController.text != _baseDesignation ||
        dateOfJoiningController.text != _baseJoining ||
        dateofRelievingController.text != _baseRelieving;
  }

  void _applyProfile(CurrentUserProfile? profile) {
    if (profile == null) return;

    _detachGeneralListeners();
    _detachSocialListeners();
    _applyingProfile = true;

    final userMetadata = profile.metadata;

    firstNameController.text = userMetadata?['first_name']?.toString() ?? '';
    lastNameController.text = userMetadata?['last_name']?.toString() ?? '';
    emailController.text = profile.email;
    phoneController.text = profile.phoneNumber ?? '';
    dateOfBirthController.text =
        userMetadata?['date_of_birth']?.toString() ?? '';
    designationController.text = userMetadata?['designation']?.toString() ?? '';
    dateOfJoiningController.text =
        userMetadata?['date_of_joining']?.toString() ?? '';
    dateofRelievingController.text =
        userMetadata?['date_of_relieving']?.toString() ?? '';
    roleController.text = profile.role.value.capitalize();

    final socialLinks = userMetadata?['social_links'];
    facebookController.text = socialLinks?['facebook']?.toString() ?? '';
    instagramController.text = socialLinks?['instagram']?.toString() ?? '';
    xController.text = socialLinks?['twitter']?.toString() ?? '';
    linkedinController.text = socialLinks?['linkedin']?.toString() ?? '';

    _applyingProfile = false;
    setState(() {
      avatarUrl = profile.avatarUrl;
    });

    _captureGeneralBaseline();
    _captureSocialBaseline();
    _attachGeneralListeners();
    _attachSocialListeners();
  }

  Future<void> _savePassword() async {
    if (!_canSubmitPassword || _isSavingPassword) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Not signed in',
        description: 'Sign in again to change your password.',
      );
      return;
    }
    final email = authState.user.email;
    if (email == null || email.trim().isEmpty) {
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'No email',
        description: 'Your account has no email on file.',
      );
      return;
    }

    setState(() => _isSavingPassword = true);
    try {
      await context.read<AuthRepository>().changePassword(
            email: email.trim(),
            currentPassword: oldPasswordController.text,
            newPassword: newPasswordController.text,
          );
      if (!mounted) return;
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      setState(() {});
      showCustomToast(
        context: context,
        type: ToastificationType.success,
        title: 'Password updated',
        description: 'Your password was changed successfully.',
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not update password',
        description: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not update password',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  Future<void> _saveSocialLinks() async {
    if (!_socialDirty || _isSavingSocial) return;
    setState(() => _isSavingSocial = true);
    try {
      final sync = context.read<UserAccountSyncService>();
      await sync.saveSocialLinks(
        facebook: facebookController.text,
        instagram: instagramController.text,
        twitter: xController.text,
        linkedin: linkedinController.text,
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthRefreshProfileRequested());
      _captureSocialBaseline();
      setState(() {});
      showCustomToast(
        context: context,
        type: ToastificationType.success,
        title: 'Saved',
        description: 'Social links were updated.',
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not save',
        description: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not save',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isSavingSocial = false);
    }
  }

  Future<void> _saveGeneral() async {
    if (!_generalDirty || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final sync = context.read<UserAccountSyncService>();
      await sync.saveGeneralProfile(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        dateOfBirth: dateOfBirthController.text,
        designation: designationController.text,
        dateOfJoining: dateOfJoiningController.text,
        dateOfRelieving: dateofRelievingController.text,
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthRefreshProfileRequested());
      _captureGeneralBaseline();
      setState(() {});
      showCustomToast(
        context: context,
        type: ToastificationType.success,
        title: 'Saved',
        description: 'Your profile was updated.',
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not save',
        description: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Could not save',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (x == null || !mounted) return;

    final bytes = await x.readAsBytes();
    if (bytes.length > UserInfoService.maxAvatarBytes) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'File too large',
        description: 'Please choose an image under 3.1 MB.',
      );
      return;
    }

    final contentType = lookupMimeType(x.path) ?? 'image/jpeg';

    setState(() => _isUploadingAvatar = true);
    try {
      final url = await context.read<UserAccountSyncService>().uploadAvatar(
            bytes: bytes,
            contentType: contentType,
          );
      if (!mounted) return;
      setState(() {
        avatarUrl = url;
      });
      context.read<AuthBloc>().add(AuthRefreshProfileRequested());
      _captureGeneralBaseline();
      showCustomToast(
        context: context,
        type: ToastificationType.success,
        title: 'Photo updated',
        description: 'Your profile picture was saved.',
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Upload failed',
        description: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomToast(
        context: context,
        type: ToastificationType.error,
        title: 'Upload failed',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  void dispose() {
    _detachGeneralListeners();
    _detachSocialListeners();
    _detachSecurityPasswordListeners();
    _tabController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    designationController.dispose();
    dateOfJoiningController.dispose();
    dateofRelievingController.dispose();
    roleController.dispose();

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    facebookController.dispose();
    xController.dispose();
    linkedinController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBreadCrumbs(
              theme: theme,
              routes: const ['Dashboard', 'User', 'Account'],
              heading: 'User Account',
            ),
            const SizedBox(height: 20),
            UserAccountTab(
              theme: theme,
              tabController: _tabController,
              tabs: const ['General', 'Security', 'Social Links'],
              onTabSelected: (index) {
                // Handle tab selection if needed
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  UserAccountGeneral(
                    theme: theme,
                    avatarUrl: avatarUrl,
                    roleController: roleController,
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    dateOfBirthController: dateOfBirthController,
                    designationController: designationController,
                    dateOfJoiningController: dateOfJoiningController,
                    dateofRelievingController: dateofRelievingController,
                    emailController: emailController,
                    phoneController: phoneController,
                    saveEnabled: _generalDirty,
                    isSaving: _isSaving,
                    isUploadingAvatar: _isUploadingAvatar,
                    onSave: _saveGeneral,
                    onAvatarTap: _pickAndUploadAvatar,
                  ),
                  UserAccountSecurity(
                    theme: theme,
                    oldPasswordController: oldPasswordController,
                    newPasswordController: newPasswordController,
                    confirmPasswordController: confirmPasswordController,
                    saveEnabled: _canSubmitPassword,
                    isSaving: _isSavingPassword,
                    onSave: _savePassword,
                  ),
                  UserAccountSocialLinks(
                    theme: theme,
                    facebookController: facebookController,
                    instagramController: instagramController,
                    xController: xController,
                    linkedinController: linkedinController,
                    saveEnabled: _socialDirty,
                    isSaving: _isSavingSocial,
                    onSave: _saveSocialLinks,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return substring(0, 1).toUpperCase() + substring(1);
  }
}
