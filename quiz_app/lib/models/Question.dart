class Question {
  final String type; // "single", "multiple", or "true_false"
  final String questionText;
  final List<String> options;
  final List<int> correctAnswers;

  Question({
    required this.type,
    required this.questionText,
    required this.options,
    required this.correctAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'] as String,
      questionText: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswers: List<int>.from(json['correctAnswers']),
    );
  }
}