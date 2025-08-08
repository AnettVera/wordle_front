// lib/utils/history_utils.dart
import 'package:intl/intl.dart';
import '../models/game_history.dart';

class HistoryUtils {
  static String formatDuration(int? minutes) {
    if (minutes == null) return 'N/A';
    
    if (minutes < 60) {
      return '${minutes}min';
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    
    return '${hours}h ${remainingMinutes}min';
  }

  static String getStreakText(int streak) {
    if (streak == 0) return 'Sin racha actual';
    if (streak == 1) return '1 victoria seguida';
    return '$streak victorias seguidas';
  }

  static String getWinRateText(int winRate) {
    if (winRate == 0) return 'Sin victorias aún';
    if (winRate == 100) return '¡Perfecto! 100%';
    return '$winRate% de victorias';
  }

  static String getPerformanceLevel(int winRate) {
    if (winRate >= 90) return 'Experto';
    if (winRate >= 75) return 'Avanzado';
    if (winRate >= 60) return 'Intermedio';
    if (winRate >= 40) return 'Principiante';
    return 'En aprendizaje';
  }

  static List<GameHistory> filterGamesByDateRange(
    List<GameHistory> games,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return games.where((game) {
      if (game.completedAt == null) return false;
      
      final gameDate = game.completedAt!;
      
      if (startDate != null && gameDate.isBefore(startDate)) {
        return false;
      }
      
      if (endDate != null && gameDate.isAfter(endDate)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  static Map<String, int> getWordLengthDistribution(List<GameHistory> games) {
    final distribution = <String, int>{};
    
    for (final game in games) {
      final length = game.targetWord.length.toString();
      distribution[length] = (distribution[length] ?? 0) + 1;
    }
    
    return distribution;
  }

  static List<GameHistory> getTopScores(List<GameHistory> games, {int limit = 10}) {
    final wonGames = games.where((g) => g.isWon).toList();
    wonGames.sort((a, b) => b.score.compareTo(a.score));
    return wonGames.take(limit).toList();
  }

  static double calculateAverageScore(List<GameHistory> games) {
    final wonGames = games.where((g) => g.isWon).toList();
    if (wonGames.isEmpty) return 0.0;
    
    final totalScore = wonGames.fold(0, (sum, game) => sum + game.score);
    return totalScore / wonGames.length;
  }

  static Map<int, int> getAttemptsDistribution(List<GameHistory> games) {
    final distribution = <int, int>{};
    
    for (int i = 1; i <= 6; i++) {
      distribution[i] = 0;
    }
    
    for (final game in games.where((g) => g.isWon)) {
      final attempts = game.attemptsUsed;
      if (attempts >= 1 && attempts <= 6) {
        distribution[attempts] = (distribution[attempts] ?? 0) + 1;
      }
    }
    
    return distribution;
  }

  static String getMostCommonStartingLetter(List<GameHistory> games) {
    final letterCount = <String, int>{};
    
    for (final game in games) {
      if (game.targetWord.isNotEmpty) {
        final firstLetter = game.targetWord[0].toUpperCase();
        letterCount[firstLetter] = (letterCount[firstLetter] ?? 0) + 1;
      }
    }
    
    if (letterCount.isEmpty) return 'N/A';
    
    final mostCommon = letterCount.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return '${mostCommon.key} (${mostCommon.value} veces)';
  }

  static List<String> getHardestWords(List<GameHistory> games, {int limit = 5}) {
    final lostGames = games.where((g) => g.isLost).toList();
    final wordCount = <String, int>{};
    
    for (final game in lostGames) {
      wordCount[game.targetWord] = (wordCount[game.targetWord] ?? 0) + 1;
    }
    
    final sortedWords = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedWords
        .take(limit)
        .map((entry) => entry.key.toUpperCase())
        .toList();
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Ahora mismo';
        }
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return weeks == 1 ? 'Hace 1 semana' : 'Hace $weeks semanas';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}