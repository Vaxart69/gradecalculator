class GradeRange {
  final String rangeId;
  final String gradingSystemId; 
  final int min;
  final int max;
  final double grade; 

  GradeRange({
    required this.rangeId,
    required this.gradingSystemId,
    required this.min,
    required this.max,
    required this.grade,
  });

  factory GradeRange.fromMap(Map<String, dynamic> map) => GradeRange(
        rangeId: map['rangeId'] ?? '',
        gradingSystemId: map['gradingSystemId'] ?? '',
        min: map['min'] ?? 0,
        max: map['max'] ?? 0,
        grade: (map['grade'] is int)
            ? (map['grade'] as int).toDouble()
            : (map['grade'] ?? 0.0),
      );

  Map<String, dynamic> toMap() => {
        'rangeId': rangeId,
        'gradingSystemId': gradingSystemId,
        'min': min,
        'max': max,
        'grade': grade,
      };
}