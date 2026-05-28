class AppConstants {
  static const String manifestApiUrl = 'https://webavatar.didthat.cc/manifest.json';
  static const String avatarBaseUrl = 'https://webavatar.didthat.cc/live';

  static String buildAvatarUrl({required String id, required String avatar}) {
    return '$avatarBaseUrl?id=$id&avatar=$avatar';
  }
}
