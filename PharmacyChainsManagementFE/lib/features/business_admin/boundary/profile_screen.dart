import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _profileStorage = const FlutterSecureStorage();
  Uint8List? _avatarBytes;
  String? _activeProfileEmail;
  String? _avatarStorageEmail;
  bool _isAvatarLoading = false;

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
        }
      },
      builder: (context, state) {
        if (state is BusinessAdminLoading) return const AppLoadingIndicator();
        if (state is BusinessAdminProfileLoadSuccess) {
          _activeProfileEmail = state.profile.email;
          _loadAvatarForProfile(state.profile.email);
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
      final profileEmail =
          _activeProfileEmail ?? _ProfileCopy.avatarFallbackKey;
      await _profileStorage.write(
        key: _avatarStorageKey(profileEmail),
        value: base64Encode(bytes),
      );
      if (!mounted) return;

      setState(() {
        _avatarBytes = bytes;
        _avatarStorageEmail = profileEmail;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(_ProfileCopy.photoUpdated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_ProfileCopy.photoUpdateFailed)),
      );
    }
  }

  Future<void> _loadAvatarForProfile(String profileEmail) async {
    if (_avatarStorageEmail == profileEmail || _isAvatarLoading) return;

    _isAvatarLoading = true;
    try {
      final encodedAvatar = await _profileStorage.read(
        key: _avatarStorageKey(profileEmail),
      );
      if (!mounted) return;

      setState(() {
        _avatarStorageEmail = profileEmail;
        _avatarBytes = encodedAvatar == null
            ? null
            : base64Decode(encodedAvatar);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _avatarStorageEmail = profileEmail;
        _avatarBytes = null;
      });
    } finally {
      _isAvatarLoading = false;
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
                )
              : _MobileProfileLayout(
                  profile: widget.profile,
                  editableDetails: _editableDetails,
                  avatarBytes: widget.avatarBytes,
                  onChangePhoto: widget.onChangePhoto,
                  onEdit: () => _showEditDialog(context),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.fullNameController,
                maxLength: _ProfileDimensions.maxFullNameLength,
                decoration: const InputDecoration(
                  labelText: _ProfileCopy.fullName,
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: _ProfileCopy.phoneNumber,
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: widget.addressController,
                decoration: const InputDecoration(
                  labelText: _ProfileCopy.address,
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: widget.dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: _ProfileCopy.dateOfBirth,
                  prefixIcon: Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: widget.genderController,
                decoration: const InputDecoration(
                  labelText: _ProfileCopy.gender,
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(_ProfileCopy.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<BusinessAdminBloc>().add(
                BusinessAdminProfileUpdateSubmitted(
                  UpdateProfileRequestDto(
                    fullName: widget.fullNameController.text.trim(),
                    phone: widget.phoneController.text.trim(),
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
      widget.addressController.text = _ProfileCopy.defaultAddress;
    }
    if (widget.dateOfBirthController.text.trim().isEmpty) {
      widget.dateOfBirthController.text = _ProfileCopy.defaultDateOfBirth;
    }
    if (widget.genderController.text.trim().isEmpty) {
      widget.genderController.text = _ProfileCopy.defaultGender;
    }
  }
}

class _DesktopProfileLayout extends StatelessWidget {
  final ProfileDto profile;
  final _ProfileEditableDetails editableDetails;
  final Uint8List? avatarBytes;
  final VoidCallback onChangePhoto;
  final VoidCallback onEdit;

  const _DesktopProfileLayout({
    required this.profile,
    required this.editableDetails,
    required this.avatarBytes,
    required this.onChangePhoto,
    required this.onEdit,
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

  const _MobileProfileLayout({
    required this.profile,
    required this.editableDetails,
    required this.avatarBytes,
    required this.onChangePhoto,
    required this.onEdit,
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
            child: _EditProfileButton(onPressed: onEdit),
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

  const _PersonalInformationCard({
    required this.profile,
    required this.editableDetails,
    required this.onEdit,
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
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: _ProfileDimensions.infoAspectRatio,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.xl,
            crossAxisSpacing: AppSpacing.xxl,
            children: [
              _DesktopInfoItem(
                icon: Icons.badge_outlined,
                label: _ProfileCopy.fullName,
                value: editableDetails.fullName,
              ),
              _DesktopInfoItem(
                icon: Icons.mail_outline,
                label: _ProfileCopy.email,
                value: profile.email,
              ),
              _DesktopInfoItem(
                icon: Icons.phone_outlined,
                label: _ProfileCopy.phoneNumber,
                value: editableDetails.phone,
              ),
              _DesktopInfoItem(
                icon: Icons.location_on_outlined,
                label: _ProfileCopy.address,
                value: editableDetails.address,
              ),
              _DesktopInfoItem(
                icon: Icons.cake_outlined,
                label: _ProfileCopy.dateOfBirth,
                value: editableDetails.dateOfBirth,
              ),
              _DesktopInfoItem(
                icon: Icons.person_outline,
                label: _ProfileCopy.gender,
                value: editableDetails.gender,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Align(
            alignment: Alignment.centerRight,
            child: _EditProfileButton(onPressed: onEdit),
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

String _avatarStorageKey(String profileEmail) =>
    '${_ProfileCopy.avatarStoragePrefix}${profileEmail.trim().toLowerCase()}';

class _ProfileCopy {
  const _ProfileCopy._();

  static const personalInformation = 'Personal Information';
  static const fullName = 'Full Name';
  static const email = 'Email';
  static const phoneNumber = 'Phone Number';
  static const address = 'Address';
  static const dateOfBirth = 'Date of Birth';
  static const gender = 'Gender';
  static const editProfile = 'Edit Profile';
  static const cancel = 'Cancel';
  static const photoUpdated = 'Profile photo updated';
  static const photoUpdateFailed = 'Unable to update profile photo';
  static const avatarFallbackKey = 'business_admin_profile';
  static const avatarStoragePrefix = 'business_admin_avatar_';
  static const defaultAddress = 'Ha Noi';
  static const defaultDateOfBirth = '11/7/1996';
  static const defaultGender = 'Male';
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
  static const infoAspectRatio = 4.4;
  static const editButtonWidth = 180.0;
  static const editButtonHeight = 52.0;
  static const maxFullNameLength = 100;
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
