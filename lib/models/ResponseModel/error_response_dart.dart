class ErrorResponseData {
  final String? errorDetails;

  ErrorResponseData({this.errorDetails});

  factory ErrorResponseData.fromJson(Map<String, dynamic> json) {
    return ErrorResponseData(
      errorDetails: json['error'] as String?,
    );
  }
}
