import '../entities/founder_profile.dart';

abstract class FounderProfileRepository {
  Future<FounderProfile> getProfile(String userId);
  Future<FounderProfile> updateProfile(FounderProfile profile);
  Future<String> uploadAvatar(List<int> bytes, String fileName);
  Future<void> cacheProfile(FounderProfile profile);
  Future<FounderProfile?> getCachedProfile();
}
