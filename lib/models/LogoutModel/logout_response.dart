class LogoutResponse {
  final String? data;

  // Constructor
  LogoutResponse(
      {required this.data});

  // Factory constructor for creating an instance from a JSON object
  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
        data: json['data'] ?? '');
  }

  // Method to convert the object back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}
