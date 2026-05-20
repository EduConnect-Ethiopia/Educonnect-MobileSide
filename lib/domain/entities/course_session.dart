class CourseSession {
  const CourseSession({
    required this.id,
    required this.courseId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    this.status = 0,
  });

  final String id;
  final String courseId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;
  final int status; // 0=Scheduled, 1=InProgress, 2=Completed, 3=Cancelled

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isLive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isCompleted => DateTime.now().isAfter(endTime) || status == 2;
  bool get isCancelled => status == 3;

  String get statusText {
    if (isCancelled) return 'Cancelled';
    if (isCompleted) return 'Completed';
    if (isLive) return 'Live Now';
    return 'Upcoming';
  }

  CourseSession copyWith({
    String? id,
    String? courseId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? meetingUrl,
    int? status,
  }) {
    return CourseSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      status: status ?? this.status,
    );
  }
}
