class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String username;
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String message;

  // Constructor
  LoginResponse(
      {required this.accessToken,
      required this.refreshToken,
      required this.username,
      required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.gender,
      required this.image,
      required this.message});

  // Factory constructor for creating an instance from a JSON object
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
        accessToken: json['accessToken'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        username: json['username'] ?? '',
        id: json['id'] ?? 0,
        email: json['email'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        gender: json['gender'] ?? '',
        image: json['image'] ?? '',
        message: json['message'] ?? '');
  }

  // Method to convert the object back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'username': username,
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }
}
