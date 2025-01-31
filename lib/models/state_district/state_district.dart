class District {
  String state;
  String district;

  District({required this.state, required this.district});

  // Convert a District object into a Map object for database insertion
  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'district': district,
    };
  }
}