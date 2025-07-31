class LetterFeedback{
  final String letter;
  final LetterStatus status;
  LetterFeedback(this.letter, this.status);
}

enum LetterStatus {
  correct, //color verde
  present, //color amarillo
  absent, //color gris
}

class WordleAttempt {
  final List<LetterFeedback> letters;
  WordleAttempt(this.letters);
}