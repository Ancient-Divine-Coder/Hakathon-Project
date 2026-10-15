class GeofenceZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String blockName;
  final String wifiSsid;

  const GeofenceZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.blockName,
    required this.wifiSsid,
  });

  GeofenceZone copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    String? blockName,
    String? wifiSsid,
  }) {
    return GeofenceZone(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      blockName: blockName ?? this.blockName,
      wifiSsid: wifiSsid ?? this.wifiSsid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'blockName': blockName,
      'wifiSsid': wifiSsid,
    };
  }

  factory GeofenceZone.fromMap(Map<String, dynamic> map, [String? id]) {
    return GeofenceZone(
      id: id ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 50.0,
      blockName: map['blockName']?.toString() ?? '',
      wifiSsid: map['wifiSsid']?.toString() ?? '',
    );
  }
}
