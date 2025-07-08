class FaceVerifyResult {
  final bool isSuccess;
  final String? sign;
  final String? liveRate;
  final String? similarity;
  final String? errorDomain;
  final String? errorCode;
  final String? errorReason;
  final String? message;

  FaceVerifyResult({
    required this.isSuccess,
    this.sign,
    this.liveRate,
    this.similarity,
    this.errorDomain,
    this.errorCode,
    this.errorReason,
    this.message,
  });

  factory FaceVerifyResult.fromMap(Map<dynamic, dynamic> map) {
    return FaceVerifyResult(
      isSuccess: map['isSuccess'] ?? false,
      sign: map['sign'],
      liveRate: map['liveRate'],
      similarity: map['similarity'],
    );
  }

  factory FaceVerifyResult.failure({
    required String code,
    required String message,
    dynamic details,
  }) {
    return FaceVerifyResult(
      isSuccess: false,
      errorCode: code,
      message: message,
      errorDomain: details is Map ? details['domain'] : null,
      errorReason: details is Map ? details['reason'] : null,
    );
  }
}