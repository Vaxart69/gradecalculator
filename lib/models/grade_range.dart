class GradeRange {
  final String rangeId;
  final String courseId;
  final int min;
  final int max;
  final double grade; 

  GradeRange({
    required this.rangeId,
    required this.courseId,
    required this.min,
    required this.max,
    required this.grade,
  });

  factory GradeRange.fromMap(Map<String, dynamic> map) => GradeRange(
        rangeId: map['rangeId'] ?? '',
        courseId: map['courseId'] ?? '',
        min: map['min'] ?? 0,
        max: map['max'] ?? 0,
        grade: (map['grade'] is int)
            ? (map['grade'] as int).toDouble()
            : (map['grade'] ?? 0.0),
      );

  Map<String, dynamic> toMap() => {
        'rangeId': rangeId,
        'courseId': courseId,
        'min': min,
        'max': max,
        'grade': grade,
      };
}