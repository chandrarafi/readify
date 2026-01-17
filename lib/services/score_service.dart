import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/score_history.dart';

class ScoreService {
  static const String _keyScoreHistory = 'score_history';

  // Simpan skor baru
  Future<void> saveScore(ScoreHistory score) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_keyScoreHistory);
    
    List<ScoreHistory> history = [];
    if (historyJson != null) {
      final List<dynamic> decoded = json.decode(historyJson);
      history = decoded.map((item) => ScoreHistory.fromJson(item)).toList();
    }
    
    history.add(score);
    
    // Simpan maksimal 50 history terakhir
    if (history.length > 50) {
      history = history.sublist(history.length - 50);
    }
    
    final encoded = json.encode(history.map((s) => s.toJson()).toList());
    await prefs.setString(_keyScoreHistory, encoded);
  }

  // Ambil semua history
  Future<List<ScoreHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_keyScoreHistory);
    
    if (historyJson == null) return [];
    
    final List<dynamic> decoded = json.decode(historyJson);
    final history = decoded.map((item) => ScoreHistory.fromJson(item)).toList();
    
    // Sort by date descending (terbaru dulu)
    history.sort((a, b) => b.date.compareTo(a.date));
    
    return history;
  }

  // Hapus semua history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScoreHistory);
  }

  // Get statistik
  Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    
    if (history.isEmpty) {
      return {
        'totalGames': 0,
        'averageScore': 0,
        'highestScore': 0,
        'lowestScore': 0,
      };
    }
    
    final totalGames = history.length;
    final totalScore = history.fold<int>(0, (sum, item) => sum + item.percentage);
    final averageScore = (totalScore / totalGames).round();
    final highestScore = history.map((h) => h.percentage).reduce((a, b) => a > b ? a : b);
    final lowestScore = history.map((h) => h.percentage).reduce((a, b) => a < b ? a : b);
    
    return {
      'totalGames': totalGames,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
    };
  }
}
