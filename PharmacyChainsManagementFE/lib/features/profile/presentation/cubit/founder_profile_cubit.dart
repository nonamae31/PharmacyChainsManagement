import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/founder_profile.dart';
import '../../domain/repositories/founder_profile_repository.dart';
import 'founder_profile_state.dart';

class FounderProfileCubit extends Cubit<FounderProfileState> {
  final FounderProfileRepository _repository;

  FounderProfileCubit({required FounderProfileRepository repository})
      : _repository = repository,
        super(FounderProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(FounderProfileLoading());
    try {
      // First try to load from cache
      final cached = await _repository.getCachedProfile();
      if (cached != null) {
        emit(FounderProfileLoaded(cached));
      }
      
      // Then load from network
      final profile = await _repository.getProfile(userId);
      emit(FounderProfileLoaded(profile));
    } catch (e) {
      if (state is! FounderProfileLoaded) {
        emit(FounderProfileError('Failed to load profile: $e'));
      }
    }
  }

  Future<void> updateProfile(FounderProfile updatedProfile) async {
    FounderProfile? lastProfile;
    if (state is FounderProfileLoaded) {
      lastProfile = (state as FounderProfileLoaded).profile;
    } else if (state is FounderProfileUpdateSuccess) {
      lastProfile = (state as FounderProfileUpdateSuccess).profile;
    }

    if (lastProfile != null) {
      emit(FounderProfileUpdating(lastProfile));
    } else {
      emit(FounderProfileLoading());
    }

    try {
      final profile = await _repository.updateProfile(updatedProfile);
      emit(FounderProfileUpdateSuccess(profile));
      // Optionally return to Loaded state
      emit(FounderProfileLoaded(profile));
    } catch (e) {
      emit(FounderProfileError('Failed to update profile: $e', lastProfile: lastProfile));
      if (lastProfile != null) {
        // Recover state
        emit(FounderProfileLoaded(lastProfile));
      }
    }
  }

  Future<void> updateAvatar(List<int> bytes, String fileName) async {
    FounderProfile? lastProfile;
    if (state is FounderProfileLoaded) {
      lastProfile = (state as FounderProfileLoaded).profile;
    } else if (state is FounderProfileUpdateSuccess) {
      lastProfile = (state as FounderProfileUpdateSuccess).profile;
    }

    if (lastProfile == null) return;

    emit(FounderProfileUpdating(lastProfile));

    try {
      final imageUrl = await _repository.uploadAvatar(bytes, fileName);
      final updated = lastProfile.copyWith(profilePhotoUri: imageUrl);
      final profile = await _repository.updateProfile(updated);
      
      emit(FounderProfileUpdateSuccess(profile));
      emit(FounderProfileLoaded(profile));
    } catch (e) {
      emit(FounderProfileError('Failed to upload avatar: $e', lastProfile: lastProfile));
      emit(FounderProfileLoaded(lastProfile));
    }
  }
}
