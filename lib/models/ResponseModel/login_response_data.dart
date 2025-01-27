class LoginResponseData {
  final String accessToken;
  final String refreshToken;
  final String encryptionKey;

  LoginResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.encryptionKey,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      encryptionKey: json['encryptionKey'] as String,
    );
  }
}
