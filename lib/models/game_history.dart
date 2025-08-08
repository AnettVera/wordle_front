// lib/models/game_history.dart
class GameHistory {
  final String id;
  final String targetWord;
  final bool isWon;
  final bool isLost;
  final int attemptsUsed;
  final int attemptsLeft;
  final List<String> attempts;
  final DateTime? completedAt;
  final DateTime? gameStartedAt;
  final int? duration;
  final int score;
  final String difficulty;

  GameHistory({
    required this.id,
    required this.targetWord,
    required this.isWon,
    required this.isLost,
    required this.attemptsUsed,
    required this.attemptsLeft,
    required this.attempts,
    this.completedAt,
    this.gameStartedAt,
    this.duration,
    required this.score,
    required this.difficulty,
  });

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      id: _safeString(json['id']),
      targetWord: _safeString(json['targetWord']),
      isWon: json['isWon'] ?? false,
      isLost: json['isLost'] ?? false,
      attemptsUsed: _safeInt(json['attemptsUsed']),
      attemptsLeft: _safeInt(json['attemptsLeft']),
      attempts: _safeStringList(json['attempts']),
      completedAt: _safeDateTime(json['completedAt']),
      gameStartedAt: _safeDateTime(json['gameStartedAt']),
      duration: _safeInt(json['duration']),
      score: _safeInt(json['score']),
      difficulty: _safeString(json['difficulty'], defaultValue: 'unknown'),
    );
  }

  // Métodos auxiliares para conversión segura de tipos
  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static int _safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static List<String> _safeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => _safeString(item)).toList();
    }
    return [];
  }

  static DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value - $e');
        return null;
      }
    }
    return null;
  }
}

class GameSummary {
  final int totalGames;
  final int wonGames;
  final int lostGames;
  final int winRate;
  final double averageAttempts;
  final GameHistory? bestGame;
  final int recentStreak;
  final List<FavoriteLetter> favoriteStartingLetters;

  GameSummary({
    required this.totalGames,
    required this.wonGames,
    required this.lostGames,
    required this.winRate,
    required this.averageAttempts,
    this.bestGame,
    required this.recentStreak,
    required this.favoriteStartingLetters,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      totalGames: GameHistory._safeInt(json['totalGames']),
      wonGames: GameHistory._safeInt(json['wonGames']),
      lostGames: GameHistory._safeInt(json['lostGames']),
      winRate: GameHistory._safeInt(json['winRate']),
      averageAttempts: _safeDouble(json['averageAttempts']),
      bestGame: json['bestGame'] != null && json['bestGame'] is Map<String, dynamic>
          ? GameHistory.fromJson(json['bestGame']) 
          : null,
      recentStreak: GameHistory._safeInt(json['recentStreak']),
      favoriteStartingLetters: _safeFavoriteLettersList(json['favoriteStartingLetters']),
    );
  }

  static double _safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static List<FavoriteLetter> _safeFavoriteLettersList(dynamic value) {
    if (value == null || value is! List) return [];
    
    return value
        .where((item) => item is Map<String, dynamic>)
        .map((item) => FavoriteLetter.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

class FavoriteLetter {
  final String letter;
  final int count;

  FavoriteLetter({
    required this.letter,
    required this.count,
  });

  factory FavoriteLetter.fromJson(Map<String, dynamic> json) {
    return FavoriteLetter(
      letter: GameHistory._safeString(json['letter']),
      count: GameHistory._safeInt(json['count']),
    );
  }
}

class PaginationInfo {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  final int currentPage;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.currentPage,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: GameHistory._safeInt(json['total']),
      limit: GameHistory._safeInt(json['limit'], defaultValue: 50),
      offset: GameHistory._safeInt(json['offset']),
      hasMore: json['hasMore'] ?? false,
      currentPage: GameHistory._safeInt(json['currentPage'], defaultValue: 1),
      totalPages: GameHistory._safeInt(json['totalPages'], defaultValue: 1),
    );
  }
}

class MonthlyStats {
  final int year;
  final int month;
  final String monthName;
  final int totalGames;
  final int totalWins;
  final int winRate;
  final Map<int, DailyStats> dailyStats;

  MonthlyStats({
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalGames,
    required this.totalWins,
    required this.winRate,
    required this.dailyStats,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    final dailyStatsMap = <int, DailyStats>{};
    final dailyStatsData = json['dailyStats'];
    
    if (dailyStatsData is Map<String, dynamic>) {
      dailyStatsData.forEach((key, value) {
        final day = int.tryParse(key);
        if (day != null && value is Map<String, dynamic>) {
          dailyStatsMap[day] = DailyStats.fromJson(value);
        }
      });
    }

    return MonthlyStats(
      year: GameHistory._safeInt(json['year'], defaultValue: DateTime.now().year),
      month: GameHistory._safeInt(json['month'], defaultValue: DateTime.now().month),
      monthName: GameHistory._safeString(json['monthName']),
      totalGames: GameHistory._safeInt(json['totalGames']),
      totalWins: GameHistory._safeInt(json['totalWins']),
      winRate: GameHistory._safeInt(json['winRate']),
      dailyStats: dailyStatsMap,
    );
  }
}

class DailyStats {
  final int games;
  final int wins;
  final List<int> attempts;

  DailyStats({
    required this.games,
    required this.wins,
    required this.attempts,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      games: GameHistory._safeInt(json['games']),
      wins: GameHistory._safeInt(json['wins']),
      attempts: _safeIntList(json['attempts']),
    );
  }

  static List<int> _safeIntList(dynamic value) {
    if (value == null || value is! List) return [];
    
    return value
        .map((item) => GameHistory._safeInt(item))
        .toList();
  }

  double get averageAttempts {
    if (attempts.isEmpty) return 0.0;
    return attempts.reduce((a, b) => a + b) / attempts.length;
  }
}