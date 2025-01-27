class RegisterResponseData {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String mobile;

  RegisterResponseData({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });

  factory RegisterResponseData.fromJson(Map<String, dynamic> json) {
    return RegisterResponseData(
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      mobile: json['mobile'] as String,
    );
  }
}
