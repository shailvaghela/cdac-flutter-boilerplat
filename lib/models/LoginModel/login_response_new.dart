class LoginResponseNew {
  final String accessToken;
  final String refreshToken;
  final String secureKey;

  // Constructor
  LoginResponseNew(
      {required this.accessToken,
        required this.refreshToken,
        required this.secureKey,
      });

  // Factory constructor for creating an instance from a JSON object
  factory LoginResponseNew.fromJson(Map<String, dynamic> json) {
    return LoginResponseNew(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        secureKey: json['secureKey'] ?? '');
  }

  // Method to convert the object back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'secureKey': secureKey,
    };
  }
}
