// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../theme/app_theme.dart';
import '../models/game_history.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HistoryProvider>();
      provider.loadGameHistory(clearPrevious: true);
      provider.loadMonthlyStats();
    });

    // Scroll listener para paginación
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HistoryProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Mi Historial',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.text,
          unselectedLabelColor: AppColors.text.withOpacity(0.6),
          indicatorColor: AppColors.green,
          tabs: const [
            Tab(text: 'Historial', icon: Icon(Icons.history)),
            Tab(text: 'Estadísticas', icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildHistoryTab(), _buildStatsTab()],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.games.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.text.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refreshHistory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.text,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildFilterBar(provider),
            if (provider.summary != null) _buildSummaryCard(provider.summary!),
            Expanded(
              child: provider.games.isEmpty
                  ? _buildEmptyState()
                  : _buildGamesList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(HistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildFilterButton('all', 'Todos', provider)),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton('won', 'Ganados', provider)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('lost', 'Perdidos', provider),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.text),
            onPressed: () => provider.refreshHistory(),
          ),
        ],
      ),
    );
  }

  // Reemplaza el método _buildFilterButton en history_screen.dart

  Widget _buildFilterButton(
    String value,
    String label,
    HistoryProvider provider,
  ) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });

        // Si ya hay datos cargados, usar filtrado del lado cliente
        if (provider.games.isNotEmpty ||
            provider.games.isEmpty && !provider.isLoading) {
          if (value == 'all' && provider.games.isEmpty) {
            // Solo recargar si no hay datos y se selecciona 'all'
            provider.loadGameHistory(filter: value, clearPrevious: true);
          } else {
            // Usar filtrado del lado cliente
            provider.changeFilter(value);
          }
        } else {
          // Cargar datos por primera vez
          provider.loadGameHistory(filter: value, clearPrevious: true);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : AppColors.darkGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.green
                : AppColors.cellBorder.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(GameSummary summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cellBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Juegos', summary.totalGames.toString()),
              _buildStat('Ganados', summary.wonGames.toString()),
              _buildStat('% Victoria', '${summary.winRate}%'),
              _buildStat('Racha', summary.recentStreak.toString()),
            ],
          ),
          if (summary.averageAttempts > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Promedio de intentos: ${summary.averageAttempts.toStringAsFixed(1)}',
              style: TextStyle(
                color: AppColors.text.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.text.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.text.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No hay juegos en tu historial',
            style: TextStyle(
              color: AppColors.text.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Juega algunas partidas para ver tu progreso aquí',
            style: TextStyle(
              color: AppColors.text.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.green;
      case 'medium':
        return AppColors.yellow;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.darkGrey;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'FÁCIL';
      case 'medium':
        return 'MEDIO';
      case 'hard':
        return 'DIFÍCIL';
      default:
        return 'N/A';
    }
  }

  Color _getCalendarDayColor(DailyStats? dayStats) {
    if (dayStats == null || dayStats.games == 0) {
      return AppColors.darkGrey;
    }

    final winRate = dayStats.wins / dayStats.games;
    if (winRate == 1.0) {
      return AppColors.green.withOpacity(0.8);
    } else if (winRate >= 0.5) {
      return AppColors.green.withOpacity(0.4);
    } else {
      return Colors.red.withOpacity(0.3);
    }
  }

  Widget _buildGamesList(HistoryProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshHistory(),
      color: AppColors.green,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.games.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.games.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.green),
              ),
            );
          }
          return _buildGameCard(provider.games[index]);
        },
      ),
    );
  }

  Widget _buildGameCard(GameHistory game) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: game.isWon ? AppColors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game.targetWord.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: game.isWon ? AppColors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  game.isWon ? 'GANADO' : 'PERDIDO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.casino_outlined,
                size: 16,
                color: AppColors.text.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                '${game.attemptsUsed}/6 intentos',
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.star_outline,
                size: 16,
                color: AppColors.text.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                '${game.score} pts',
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(game.difficulty),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDifficultyLabel(game.difficulty),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (game.completedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              dateFormat.format(game.completedAt!),
              style: TextStyle(
                color: AppColors.text.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Consumer<HistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }

        if (provider.monthlyStats == null) {
          return const Center(
            child: Text(
              'No hay estadísticas disponibles',
              style: TextStyle(color: AppColors.text),
            ),
          );
        }

        return _buildMonthlyStats(provider.monthlyStats!);
      },
    );
  }

  Widget _buildMonthlyStats(MonthlyStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stats.monthName.toUpperCase()} ${stats.year}',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthlyOverview(stats),
          const SizedBox(height: 24),
          _buildCalendarView(stats),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(MonthlyStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cellBorder.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('Juegos', stats.totalGames.toString()),
          _buildStat('Victorias', stats.totalWins.toString()),
          _buildStat('% Victoria', '${stats.winRate}%'),
        ],
      ),
    );
  }

  Widget _buildCalendarView(MonthlyStats stats) {
    final daysInMonth = DateTime(stats.year, stats.month + 1, 0).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendario de juegos',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final dayStats = stats.dailyStats[day];

            return Container(
              decoration: BoxDecoration(
                color: _getCalendarDayColor(dayStats),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.cellBorder.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dayStats != null && dayStats.games > 0)
                      Text(
                        '${dayStats.wins}/${dayStats.games}',
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.7),
                          fontSize: 8,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
