class GradeRange {
  final String rangeId;
  final String gradingSystemId; 
  final double min; // Changed from int to double
  final double max; // Changed from int to double
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
        min: (map['min'] is int) 
            ? (map['min'] as int).toDouble() 
            : (map['min'] ?? 0.0), // Changed to handle both int and double
        max: (map['max'] is int) 
            ? (map['max'] as int).toDouble() 
            : (map['max'] ?? 0.0), // Changed to handle both int and double
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