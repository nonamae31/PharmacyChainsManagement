class FounderProfile {
  final String userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? profilePhotoUri;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;

  const FounderProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.profilePhotoUri,
    this.address,
    this.dateOfBirth,
    this.gender,
  });

  FounderProfile copyWith({
    String? fullName,
    String? phone,
    String? profilePhotoUri,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return FounderProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      profilePhotoUri: profilePhotoUri ?? this.profilePhotoUri,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }
}
