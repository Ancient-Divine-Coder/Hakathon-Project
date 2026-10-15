enum VerificationMode {
  facial,
  rfid,
  manual,
}

class BiometricVerificationResult {
  final String id;
  final String facultyId;
  final VerificationMode mode;
  final DateTime timestamp;
  final double confidenceScore;
  final bool isLivenessPassed;
  final bool isMatch;
  final String gateTurnstile;
  final bool isInsideGeofence;
  final String? networkSsid;

  const BiometricVerificationResult({
    required this.id,
    required this.facultyId,
    required this.mode,
    required this.timestamp,
    required this.confidenceScore,
    required this.isLivenessPassed,
    required this.isMatch,
    this.gateTurnstile = 'Gate A-12 Turnstile',
    this.isInsideGeofence = true,
    this.networkSsid = 'SKIT-Campus-5G',
  });

  BiometricVerificationResult copyWith({
    String? id,
    String? facultyId,
    VerificationMode? mode,
    DateTime? timestamp,
    double? confidenceScore,
    bool? isLivenessPassed,
    bool? isMatch,
    String? gateTurnstile,
    bool? isInsideGeofence,
    String? networkSsid,
  }) {
    return BiometricVerificationResult(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      mode: mode ?? this.mode,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      isLivenessPassed: isLivenessPassed ?? this.isLivenessPassed,
      isMatch: isMatch ?? this.isMatch,
      gateTurnstile: gateTurnstile ?? this.gateTurnstile,
      isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
      networkSsid: networkSsid ?? this.networkSsid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facultyId': facultyId,
      'mode': mode.name,
      'timestamp': timestamp.toIso8601String(),
      'confidenceScore': confidenceScore,
      'isLivenessPassed': isLivenessPassed,
      'isMatch': isMatch,
      'gateTurnstile': gateTurnstile,
      'isInsideGeofence': isInsideGeofence,
      'networkSsid': networkSsid,
    };
  }

  factory BiometricVerificationResult.fromMap(
    Map<String, dynamic> map, [
    String? id,
  ]) {
    DateTime parsedTime = DateTime.now();
    if (map['timestamp'] != null) {
      parsedTime =
          DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now();
    }

    return BiometricVerificationResult(
      id: id ?? map['id']?.toString() ?? '',
      facultyId: map['facultyId']?.toString() ?? '',
      mode: VerificationMode.values.firstWhere(
        (e) => e.name == map['mode'],
        orElse: () => VerificationMode.facial,
      ),
      timestamp: parsedTime,
      confidenceScore: (map['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      isLivenessPassed: map['isLivenessPassed'] as bool? ?? false,
      isMatch: map['isMatch'] as bool? ?? false,
      gateTurnstile: map['gateTurnstile']?.toString() ?? 'Gate A-12 Turnstile',
      isInsideGeofence: map['isInsideGeofence'] as bool? ?? false,
      networkSsid: map['networkSsid']?.toString(),
    );
  }
}
