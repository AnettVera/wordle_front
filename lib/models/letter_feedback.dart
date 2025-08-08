// Agregar este modelo a tu wordle_api_service.dart

class LetterFeedback {
  final String letter;
  final String status; // 'correct_pos', 'correct_wrong_pos', 'not_in_word'

  LetterFeedback({
    required this.letter,
    required this.status,
  });

  factory LetterFeedback.fromJson(Map<String, dynamic> json) {
    return LetterFeedback(
      letter: json['letter'] ?? '',
      status: json['status'] ?? 'not_in_word',
    );
  }
}