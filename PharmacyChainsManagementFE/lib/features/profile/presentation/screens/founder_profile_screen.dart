import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/founder_profile_cubit.dart';
import '../cubit/founder_profile_state.dart';
import '../../domain/entities/founder_profile.dart';

class FounderProfileScreen extends StatefulWidget {
  const FounderProfileScreen({super.key});

  @override
  State<FounderProfileScreen> createState() => _FounderProfileScreenState();
}

class _FounderProfileScreenState extends State<FounderProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile using the user id from AuthBloc if possible, or a default one
    String userId = '';
    // Assuming AuthBloc has a property or we can get user info. 
    // If not, just use a dummy or get it from secure storage.
    // Let's call loadProfile with whatever we have.
    context.read<FounderProfileCubit>().loadProfile(userId);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null && mounted) {
      final bytes = await pickedFile.readAsBytes();
      context.read<FounderProfileCubit>().updateAvatar(bytes, pickedFile.name);
    }
  }

  void _showEditProfile(BuildContext context, FounderProfile profile) {
    if (MediaQuery.of(context).size.width > 800) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            child: BlocProvider.value(
              value: context.read<FounderProfileCubit>(),
              child: _EditProfileForm(profile: profile, isWeb: true),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => BlocProvider.value(
          value: context.read<FounderProfileCubit>(),
          child: _EditProfileForm(profile: profile, isWeb: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Founder Profile')),
      body: BlocConsumer<FounderProfileCubit, FounderProfileState>(
        listener: (context, state) {
          if (state is FounderProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FounderProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        },
        builder: (context, state) {
          if (state is FounderProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          FounderProfile? profile;
          if (state is FounderProfileLoaded) {
            profile = state.profile;
          } else if (state is FounderProfileUpdating) {
            profile = state.currentProfile;
          } else if (state is FounderProfileUpdateSuccess) {
            profile = state.profile;
          } else if (state is FounderProfileError && state.lastProfile != null) {
            profile = state.lastProfile;
          }

          if (profile == null) {
            return const Center(child: Text('Could not load profile.'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FounderProfileCubit>().loadProfile(profile!.userId),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildWebLayout(context, profile!);
                } else {
                  return _buildMobileLayout(context, profile!);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, FounderProfile profile) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Avatar & Quick Info
            Expanded(
              flex: 1,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      _buildAvatar(profile, radius: 80),
                      const SizedBox(height: 24),
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Founder',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            // Right Column: Details & Edit
            Expanded(
              flex: 2,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information', style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem(context, Icons.badge, 'Full Name', profile.fullName)),
                          Expanded(child: _buildInfoItem(context, Icons.email, 'Email', profile.email)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem(context, Icons.phone, 'Phone Number', profile.phone ?? 'Not provided')),
                          Expanded(child: _buildInfoItem(context, Icons.location_on, 'Address', profile.address ?? 'Not provided')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildInfoItem(context, Icons.cake, 'Date of Birth', profile.dateOfBirth != null ? '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}' : 'Not provided')),
                          Expanded(child: _buildInfoItem(context, Icons.person_outline, 'Gender', profile.gender ?? 'Not provided')),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          ),
                          onPressed: () => _showEditProfile(context, profile),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, FounderProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: _buildAvatar(profile, radius: 50)),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.badge),
          title: const Text('Full Name'),
          subtitle: Text(profile.fullName),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Email'),
          subtitle: Text(profile.email),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Phone Number'),
          subtitle: Text(profile.phone ?? 'Not provided'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Address'),
          subtitle: Text(profile.address ?? 'Not provided'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.cake),
          title: const Text('Date of Birth'),
          subtitle: Text(profile.dateOfBirth != null ? '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}' : 'Not provided'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Gender'),
          subtitle: Text(profile.gender ?? 'Not provided'),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          onPressed: () => _showEditProfile(context, profile),
        ),
      ],
    );
  }

  Widget _buildAvatar(FounderProfile profile, {required double radius}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profile.profilePhotoUri != null && profile.profilePhotoUri!.isNotEmpty
                ? (profile.profilePhotoUri!.startsWith('http')
                    ? CachedNetworkImageProvider(profile.profilePhotoUri!)
                    : FileImage(File(profile.profilePhotoUri!)) as ImageProvider)
                : null,
            child: profile.profilePhotoUri == null || profile.profilePhotoUri!.isEmpty
                ? Icon(Icons.person, size: radius, color: Colors.grey)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: radius * 0.36,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: Icon(Icons.camera_alt, size: radius * 0.36, color: Colors.white),
              onPressed: _pickImage,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  final FounderProfile profile;
  final bool isWeb;

  const _EditProfileForm({required this.profile, this.isWeb = false});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _genderController;
  DateTime? _selectedDate;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _addressController = TextEditingController(text: widget.profile.address ?? '');
    _genderController = TextEditingController(text: widget.profile.gender ?? '');
    _selectedDate = widget.profile.dateOfBirth;

    _nameController.addListener(_markDirty);
    _phoneController.addListener(_markDirty);
    _addressController.addListener(_markDirty);
    _genderController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final updated = widget.profile.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _genderController.text.trim(),
        dateOfBirth: _selectedDate,
      );
      context.read<FounderProfileCubit>().updateProfile(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: widget.isWeb
            ? const EdgeInsets.all(32)
            : EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: widget.isWeb
              ? SingleChildScrollView(child: _buildFormFields(context))
              : _buildFormFields(context),
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
              Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
                    return 'Phone number must start with 0 and have 10 digits';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  if (value.trim().length < 5) {
                    return 'Address must be at least 5 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _genderController.text.isNotEmpty ? _genderController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _genderController.text = value;
                    _markDirty();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FormField<DateTime>(
                initialValue: _selectedDate,
                validator: (value) {
                  if (value == null) return 'Please select your date of birth';
                  final age = DateTime.now().year - value.year;
                  if (age < 18) return 'You must be at least 18 years old';
                  return null;
                },
                builder: (FormFieldState<DateTime> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.cake),
                        title: const Text('Date of Birth'),
                        subtitle: Text(state.value != null ? '${state.value!.day}/${state.value!.month}/${state.value!.year}' : 'Select Date'),
                        trailing: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: state.value ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                                _isDirty = true;
                              });
                              state.didChange(date);
                            }
                          },
                          child: const Text('Select'),
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              BlocConsumer<FounderProfileCubit, FounderProfileState>(
                listener: (context, state) {
                  if (state is FounderProfileUpdateSuccess) {
                    setState(() {
                      _isDirty = false;
                    });
                    Navigator.of(context).pop();
                  }
                },
                builder: (context, state) {
                  final isLoading = state is FounderProfileUpdating;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
  }
}
