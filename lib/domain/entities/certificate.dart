class Certificate {
  const Certificate({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.learnerName,
    required this.issuedAt,
    required this.uniqueCode,
    this.thumbnailUrl,
    this.pdfUrl,
    this.verificationUrl,
  });

  final String id;
  final String courseId;
  final String courseTitle;
  final String learnerName;
  final DateTime issuedAt;
  final String uniqueCode;
  final String? thumbnailUrl;
  final String? pdfUrl;
  final String? verificationUrl;

  String get shareVerificationUrl =>
      verificationUrl ?? 'https://verify.educonnect.et/$uniqueCode';
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.earnedAt,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime earnedAt;
}
