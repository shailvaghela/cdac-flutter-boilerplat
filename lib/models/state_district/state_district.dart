class District {
  int id;
  String state;
  String district;

  District({required this.id, required this.state, required this.district});

  // Convert a District object into a Map object for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'state': state,
      'district': district,
    };
  }
}