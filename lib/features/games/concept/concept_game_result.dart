class ConceptGameResult {
  const ConceptGameResult({
    required this.won,
    required this.score,
    required this.total,
    required this.message,
  });

  final bool won;
  final int score;
  final int total;
  final String message;

  double get profit => won ? score * 2.0 : score.toDouble();
  double get revenue => score * 3.0;
  double get cost => total.toDouble();
}
