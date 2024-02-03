class SavedLocation {
  final String id;
  final double latitude;
  final double longitude;
  final String createdBy;

  SavedLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
    };
  }

  factory SavedLocation.fromMap(Map<String, dynamic> map) {
    return SavedLocation(
      id: map['id'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      createdBy: map['createdBy'] as String,
    );
  }

  SavedLocation copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? createdBy,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
