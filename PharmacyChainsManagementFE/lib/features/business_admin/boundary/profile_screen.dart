import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/shared_components/app_empty_state.dart';
import '../../../shared/shared_components/app_error_dialog.dart';
import '../../../shared/shared_components/app_loading_indicator.dart';
import '../control/business_admin_bloc.dart';
import '../control/business_admin_event.dart';
import '../control/business_admin_state.dart';
import '../entity/profile_dto.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _genderController = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    context.read<BusinessAdminBloc>().add(BusinessAdminProfileFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessAdminBloc, BusinessAdminState>(
      listener: (context, state) {
        if (state is BusinessAdminLoadFailure) {
          showAppErrorDialog(context, message: state.message);
        } else if (state is BusinessAdminProfileOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is BusinessAdminLoading) return const AppLoadingIndicator();
        if (state is BusinessAdminProfileLoadSuccess) {
          return _ProfileView(
            profile: state.profile,
            fullNameController: _fullNameController,
            phoneController: _phoneController,
            addressController: _addressController,
            dateOfBirthController: _dateOfBirthController,
            genderController: _genderController,
            avatarBytes: _avatarBytes,
            onChangePhoto: _pickAvatar,
          );
        }
        return AppEmptyState(
          onRetry: () => context.read<BusinessAdminBloc>().add(
            BusinessAdminProfileFetchRequested(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _ProfileDimensions.avatarPickerMaxSize,
        maxHeight: _ProfileDimensions.avatarPickerMaxSize,
        imageQuality: _ProfileDimensions.avatarPickerQuality,
      );
      if (pickedImage == null) return;

      final bytes = await pickedImage.readAsBytes();
      if (!mounted) return;

      setState(() {
        _avatarBytes = bytes;
      });
      context.read<BusinessAdminBloc>().add(
        BusinessAdminProfileAvatarSubmitted(
          bytes: bytes,
          fileName: pickedImage.name,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_ProfileCopy.photoUpdateFailed)),
      );
    }
  }
}

class _ProfileView extends StatefulWidget {
  final ProfileDto profile;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController dateOfBirthController;
  final TextEditingController genderController;
  final Uint8List? avatarBytes;
  final VoidCallback onChangePhoto;

  const _ProfileView({
    required this.profile,
    required this.fullNameController,
    required this.phoneController,
    required this.addressController,
    required this.dateOfBirthController,
    required this.genderController,
    required this.avatarBytes,
    required this.onChangePhoto,
  });

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ensureExtraDetails();
  }

  @override
  void didUpdateWidget(covariant _ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureExtraDetails();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _ProfilePalette.page),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _ProfileDimensions.wideWidth;
          final content = isWide
              ? _DesktopProfileLayout(
                  profile: widget.profile,
                  editableDetails: _editableDetails,
                  avatarBytes: widget.avatarBytes,
                  onChangePhoto: widget.onChangePhoto,
                  onEdit: () => _showEditDialog(context),
                  onChangePassword: () => _showChangePasswordDialog(context),
                )
              : _MobileProfileLayout(
                  profile: widget.profile,
                  editableDetails: _editableDetails,
                  avatarBytes: widget.avatarBytes,
                  onChangePhoto: widget.onChangePhoto,
                  onEdit: () => _showEditDialog(context),
                  onChangePassword: () => _showChangePasswordDialog(context),
                );

          return ListView(
            padding: EdgeInsets.all(isWide ? AppSpacing.xxl : AppSpacing.lg),
            children: [content],
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    widget.fullNameController.text = _editableDetails.fullName;
    widget.phoneController.text = _editableDetails.phone;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(_ProfileCopy.editProfile),
        content: SizedBox(
          width: _ProfileDimensions.dialogWidth,
          child: Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: widget.fullNameController,
                  maxLength: _ProfileDimensions.maxFullNameLength,
                  decoration: const InputDecoration(
                    labelText: _ProfileCopy.fullName,
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? _ProfileCopy.fullNameInvalid
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: widget.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: _ProfileCopy.phoneNumber,
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) return null;
                    return RegExp(r'^\+?[0-9]{9,15}$').hasMatch(phone)
                        ? null
                        : _ProfileCopy.phoneInvalid;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: widget.addressController,
                  maxLength: _ProfileDimensions.maxAddressLength,
                  decoration: const InputDecoration(
                    labelText: _ProfileCopy.address,
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: widget.dateOfBirthController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: _ProfileCopy.dateOfBirth,
                    prefixIcon: Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _pickDateOfBirth(dialogContext),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _genderValue(widget.genderController.text),
                  decoration: const InputDecoration(
                    labelText: _ProfileCopy.gender,
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) =>
                      widget.genderController.text = value ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(_ProfileCopy.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!_editFormKey.currentState!.validate()) return;
              context.read<BusinessAdminBloc>().add(
                BusinessAdminProfileUpdateSubmitted(
                  UpdateProfileRequestDto(
                    fullName: widget.fullNameController.text.trim(),
                    phone: widget.phoneController.text.trim(),
                    address: widget.addressController.text.trim(),
                    dateOfBirth: _parseDate(widget.dateOfBirthController.text),
                    gender: widget.genderController.text.trim(),
                  ),
                ),
              );
              setState(() {});
              Navigator.of(dialogContext).pop();
            },
            child: const Text(AppStrings.saveChanges),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final request = await showDialog<ChangePasswordRequestDto>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (request == null || !context.mounted) return;
    context.read<BusinessAdminBloc>().add(
      BusinessAdminPasswordChangeSubmitted(request),
    );
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final current = _parseDate(widget.dateOfBirthController.text);
    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(today.year - 18),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (selected != null) {
      widget.dateOfBirthController.text = _formatDate(selected);
    }
  }

  _ProfileEditableDetails get _editableDetails => _ProfileEditableDetails(
    fullName: _fieldValue(
      widget.fullNameController.text,
      widget.profile.fullName,
    ),
    phone: _fieldValue(widget.phoneController.text, widget.profile.phone),
    address: _displayValue(widget.addressController.text),
    dateOfBirth: _displayValue(widget.dateOfBirthController.text),
    gender: _displayValue(widget.genderController.text),
  );

  void _ensureExtraDetails() {
    if (widget.addressController.text.trim().isEmpty) {
      widget.addressController.text = widget.profile.address ?? '';
    }
    if (widget.dateOfBirthController.text.trim().isEmpty) {
      widget.dateOfBirthController.text = widget.profile.dateOfBirth == null
          ? ''
          : _formatDate(widget.profile.dateOfBirth!);
    }
    if (widget.genderController.text.trim().isEmpty) {
      widget.genderController.text = widget.profile.gender ?? '';
    }
  }
}

class _DesktopProfileLayout extends StatelessWidget {
  final ProfileDto profile;
  final _ProfileEditableDetails editableDetails;
  final Uint8List? avatarBytes;
  final VoidCallback onChangePhoto;
  final VoidCallback onEdit;
  final VoidCallback onChangePassword;

  const _DesktopProfileLayout({
    required this.profile,
    required this.editableDetails,
    required this.avatarBytes,
    required this.onChangePhoto,
    required this.onEdit,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _ProfileDimensions.desktopMaxWidth,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _IdentityCard(
                profile: profile,
                editableDetails: editableDetails,
                avatarBytes: avatarBytes,
                onChangePhoto: onChangePhoto,
              ),
            ),
            const SizedBox(width: AppSpacing.xxl),
            Expanded(
              flex: 8,
              child: _PersonalInformationCard(
                profile: profile,
                editableDetails: editableDetails,
                onEdit: onEdit,
                onChangePassword: onChangePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileProfileLayout extends StatelessWidget {
  final ProfileDto profile;
  final _ProfileEditableDetails editableDetails;
  final Uint8List? avatarBytes;
  final VoidCallback onChangePhoto;
  final VoidCallback onEdit;
  final VoidCallback onChangePassword;

  const _MobileProfileLayout({
    required this.profile,
    required this.editableDetails,
    required this.avatarBytes,
    required this.onChangePhoto,
    required this.onEdit,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfilePanel(
      child: Column(
        children: [
          _EditableAvatar(
            profile: profile,
            avatarBytes: avatarBytes,
            size: _ProfileDimensions.mobileAvatar,
            onChangePhoto: onChangePhoto,
          ),
          const SizedBox(height: AppSpacing.xl),
          _MobileProfileTile(
            icon: Icons.badge_outlined,
            label: _ProfileCopy.fullName,
            value: editableDetails.fullName,
            supportingText: profile.role,
          ),
          _MobileProfileTile(
            icon: Icons.mail_outline,
            label: _ProfileCopy.email,
            value: profile.email,
          ),
          if (profile.branchName?.trim().isNotEmpty ?? false)
            _MobileProfileTile(
              icon: Icons.store_outlined,
              label: _ProfileCopy.branch,
              value: profile.branchName!,
            ),
          _MobileProfileTile(
            icon: Icons.phone_outlined,
            label: _ProfileCopy.phoneNumber,
            value: editableDetails.phone,
          ),
          _MobileProfileTile(
            icon: Icons.location_on_outlined,
            label: _ProfileCopy.address,
            value: editableDetails.address,
          ),
          _MobileProfileTile(
            icon: Icons.cake_outlined,
            label: _ProfileCopy.dateOfBirth,
            value: editableDetails.dateOfBirth,
          ),
          _MobileProfileTile(
            icon: Icons.person_outline,
            label: _ProfileCopy.gender,
            value: editableDetails.gender,
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ChangePasswordButton(onPressed: onChangePassword),
                _EditProfileButton(onPressed: onEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final ProfileDto profile;
  final _ProfileEditableDetails editableDetails;
  final Uint8List? avatarBytes;
  final VoidCallback onChangePhoto;

  const _IdentityCard({
    required this.profile,
    required this.editableDetails,
    required this.avatarBytes,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfilePanel(
      minHeight: _ProfileDimensions.identityCardHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          _EditableAvatar(
            profile: profile,
            avatarBytes: avatarBytes,
            size: _ProfileDimensions.desktopAvatar,
            onChangePhoto: onChangePhoto,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            editableDetails.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _ProfilePalette.title,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            profile.role,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
          ),
          if (profile.branchName?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.branchName!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _StatusPill(label: profile.status),
        ],
      ),
    );
  }
}

class _PersonalInformationCard extends StatelessWidget {
  final ProfileDto profile;
  final _ProfileEditableDetails editableDetails;
  final VoidCallback onEdit;
  final VoidCallback onChangePassword;

  const _PersonalInformationCard({
    required this.profile,
    required this.editableDetails,
    required this.onEdit,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfilePanel(
      minHeight: _ProfileDimensions.informationCardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _ProfileCopy.personalInformation,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _ProfilePalette.title,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount =
                  constraints.maxWidth <
                      _ProfileDimensions.singleColumnBreakpoint
                  ? 1
                  : 2;
              final itemWidth = columnCount == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.xxl) / 2;

              return Wrap(
                spacing: AppSpacing.xxl,
                runSpacing: AppSpacing.xl,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopInfoItem(
                      icon: Icons.badge_outlined,
                      label: _ProfileCopy.fullName,
                      value: editableDetails.fullName,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopInfoItem(
                      icon: Icons.mail_outline,
                      label: _ProfileCopy.email,
                      value: profile.email,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopInfoItem(
                      icon: Icons.phone_outlined,
                      label: _ProfileCopy.phoneNumber,
                      value: editableDetails.phone,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopInfoItem(
                      icon: Icons.location_on_outlined,
                      label: _ProfileCopy.address,
                      value: editableDetails.address,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopInfoItem(
                      icon: Icons.cake_outlined,
                      label: _ProfileCopy.dateOfBirth,
                      value: editableDetails.dateOfBirth,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DesktopInfoItem(
                      icon: Icons.person_outline,
                      label: _ProfileCopy.gender,
                      value: editableDetails.gender,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ChangePasswordButton(onPressed: onChangePassword),
                _EditProfileButton(onPressed: onEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  final ProfileDto profile;
  final Uint8List? avatarBytes;
  final double size;
  final VoidCallback onChangePhoto;

  const _EditableAvatar({
    required this.profile,
    required this.avatarBytes,
    required this.size,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * _ProfileDimensions.cameraBadgeScale;

    return SizedBox(
      width: size + badgeSize / 3,
      height: size + badgeSize / 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onChangePhoto,
              child: _ProfileAvatar(
                profile: profile,
                avatarBytes: avatarBytes,
                size: size,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onChangePhoto,
                child: SizedBox(
                  width: badgeSize,
                  height: badgeSize,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: badgeSize * _ProfileDimensions.cameraIconScale,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ProfileDto profile;
  final Uint8List? avatarBytes;
  final double size;

  const _ProfileAvatar({
    required this.profile,
    required this.avatarBytes,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final photoUri = profile.profilePhotoUri;
    final hasSelectedPhoto = avatarBytes != null;
    final hasNetworkPhoto = photoUri != null && photoUri.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _ProfilePalette.avatarBase,
        image: hasSelectedPhoto || hasNetworkPhoto
            ? DecorationImage(
                image: hasSelectedPhoto
                    ? MemoryImage(avatarBytes!)
                    : NetworkImage(photoUri!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasSelectedPhoto || hasNetworkPhoto
          ? null
          : CustomPaint(painter: _AvatarGlowPainter()),
    );
  }
}

class _MobileProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? supportingText;
  final bool showDivider;

  const _MobileProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    this.supportingText,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _ProfilePalette.icon, size: 26),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _ProfilePalette.title,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      supportingText ?? value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _ProfilePalette.subtitle,
                      ),
                    ),
                    if (supportingText != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _DesktopInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DesktopInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: _ProfilePalette.icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _ProfilePalette.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: _ProfilePalette.title),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditProfileButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.edit),
      label: const Text(_ProfileCopy.editProfile),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(
          _ProfileDimensions.editButtonWidth,
          _ProfileDimensions.editButtonHeight,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

class _ChangePasswordButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ChangePasswordButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.lock_reset_outlined),
      label: const Text(_ProfileCopy.changePassword),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          _ProfileDimensions.changePasswordButtonWidth,
          _ProfileDimensions.editButtonHeight,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(_ProfileCopy.changePassword),
      content: SizedBox(
        width: _ProfileDimensions.dialogWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(
                controller: _currentController,
                label: _ProfileCopy.currentPassword,
                obscureText: _obscureCurrent,
                onToggleVisibility: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) => (value?.isEmpty ?? true)
                    ? _ProfileCopy.passwordRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _PasswordField(
                controller: _newController,
                label: _ProfileCopy.newPassword,
                obscureText: _obscureNew,
                onToggleVisibility: () =>
                    setState(() => _obscureNew = !_obscureNew),
                validator: (value) =>
                    _ProfileCopy.passwordPattern.hasMatch(value ?? '')
                    ? null
                    : _ProfileCopy.passwordStrength,
              ),
              const SizedBox(height: AppSpacing.md),
              _PasswordField(
                controller: _confirmController,
                label: _ProfileCopy.confirmPassword,
                obscureText: _obscureConfirm,
                onToggleVisibility: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) => value == _newController.text
                    ? null
                    : _ProfileCopy.passwordMismatch,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(_ProfileCopy.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(_ProfileCopy.changePassword),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ChangePasswordRequestDto(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String> validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileEditableDetails {
  final String fullName;
  final String phone;
  final String address;
  final String dateOfBirth;
  final String gender;

  const _ProfileEditableDetails({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
  });
}

class _ProfilePanel extends StatelessWidget {
  final Widget child;
  final double? minHeight;

  const _ProfilePanel({required this.child, this.minHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: _ProfilePalette.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: _ProfilePalette.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AvatarGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: const [
          _ProfilePalette.avatarCore,
          _ProfilePalette.avatarBlue,
          _ProfilePalette.avatarBase,
        ],
        stops: const [0.0, 0.32, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.18);

    for (var i = 1; i <= 4; i += 1) {
      canvas.drawCircle(
        center.translate(-radius * 0.14 * i, radius * 0.02 * i),
        radius * (0.18 + i * 0.13),
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _displayValue(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return AppStrings.notAvailable;
  return normalized;
}

String _fieldValue(String? value, String? fallback) {
  final normalized = value?.trim();
  if (normalized != null && normalized.isNotEmpty) return normalized;
  return _displayValue(fallback);
}

String _formatDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

DateTime? _parseDate(String value) {
  final parts = value.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  final date = DateTime(year, month, day);
  return date.day == day && date.month == month && date.year == year
      ? date
      : null;
}

String? _genderValue(String value) =>
    const {'Male', 'Female', 'Other'}.contains(value.trim())
    ? value.trim()
    : null;

class _ProfileCopy {
  const _ProfileCopy._();

  static const personalInformation = 'Personal Information';
  static const fullName = 'Full Name';
  static const email = 'Email';
  static const branch = 'Branch';
  static const phoneNumber = 'Phone Number';
  static const address = 'Address';
  static const dateOfBirth = 'Date of Birth';
  static const gender = 'Gender';
  static const editProfile = 'Edit Profile';
  static const cancel = 'Cancel';
  static const photoUpdateFailed = 'Unable to update profile photo';
  static const changePassword = 'Change Password';
  static const currentPassword = 'Current Password';
  static const newPassword = 'New Password';
  static const confirmPassword = 'Confirm New Password';
  static const passwordRequired = 'Enter your current password.';
  static const passwordStrength =
      'Use at least 8 characters with uppercase, lowercase, number, and special character.';
  static const passwordMismatch = 'Passwords do not match.';
  static const fullNameInvalid =
      'Full name must contain at least 2 characters.';
  static const phoneInvalid = 'Enter a valid phone number.';
  static final passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d])\S{8,100}$',
  );
}

class _ProfileDimensions {
  const _ProfileDimensions._();

  static const wideWidth = 900.0;
  static const desktopMaxWidth = 1420.0;
  static const dialogWidth = 420.0;
  static const identityCardHeight = 640.0;
  static const informationCardHeight = 640.0;
  static const desktopAvatar = 184.0;
  static const mobileAvatar = 126.0;
  static const cameraBadgeScale = 0.28;
  static const cameraIconScale = 0.52;
  static const avatarPickerMaxSize = 512.0;
  static const avatarPickerQuality = 85;
  static const singleColumnBreakpoint = 520.0;
  static const editButtonWidth = 180.0;
  static const changePasswordButtonWidth = 200.0;
  static const editButtonHeight = 52.0;
  static const maxFullNameLength = 100;
  static const maxAddressLength = 255;
}

class _ProfilePalette {
  const _ProfilePalette._();

  static const page = Color(0xFFF4FAF7);
  static const panel = Color(0xFFFAFCFA);
  static const title = Color(0xFF17211F);
  static const subtitle = Color(0xFF4B5B57);
  static const label = Color(0xFF737D79);
  static const icon = Color(0xFF59635F);
  static const avatarBase = Color(0xFF050708);
  static const avatarBlue = Color(0xFF1E87B7);
  static const avatarCore = Color(0xFFE8FFFF);
  static const shadow = Color(0x16000000);
}
