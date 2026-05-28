class VrmManifest {
  final List<String> vrmList;

  VrmManifest({required this.vrmList});

  factory VrmManifest.fromJson(Map<String, dynamic> json) {
    return VrmManifest(
      vrmList: json['VRM'] != null ? List<String>.from(json['VRM']) : [],
    );
  }
}
