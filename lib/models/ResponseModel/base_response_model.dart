class BaseResponse<T> {
  final String status;
  final String message;
  final T? content; // Can represent either `data` or `error`

  BaseResponse({
    required this.status,
    required this.message,
    this.content,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      content: json.containsKey('data')
          ? fromJsonT(json['data'])
          : fromJsonT(json['error']),
    );
  }
}
