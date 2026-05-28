import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/vrm_manifest.dart';

class ApiService {
  Future<VrmManifest> fetchVrmManifest() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.manifestApiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return VrmManifest.fromJson(data);
      } else {
        throw Exception('Failed to load avatars (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
