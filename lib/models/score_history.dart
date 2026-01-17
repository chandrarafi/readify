class ScoreHistory {
  final String userName;
  final int score;
  final int totalQuestions;
  final DateTime date;
  final String category; // 'Tebak Kata', dll

  ScoreHistory({
    required this.userName,
    required this.score,
    required this.totalQuestions,
    required this.date,
    required this.category,
  });

  int get percentage => ((score / totalQuestions) * 100).round();

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory ScoreHistory.fromJson(Map<String, dynamic> json) {
    return ScoreHistory(
      userName: json['userName'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
    );
  }
}
