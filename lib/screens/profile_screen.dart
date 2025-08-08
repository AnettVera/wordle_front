// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import '../services/stats_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar estadísticas al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().fetchUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StatsProvider>().fetchUserStats(),
          ),
        ],
        elevation: 0,
      ),
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.darkGrey,
                  child: Icon(Icons.person, size: 48, color: AppColors.text),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenidx a Wordle',
                  style: const TextStyle(fontSize: 16, color: AppColors.text),
                ),

                // Mostrar si está vinculado a Alexa
                if (statsProvider.userStats?.isLinked == true)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, color: AppColors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Vinculado con Alexa',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Mostrar error si existe
                if (statsProvider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade300, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statsProvider.error!,
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Indicador de carga
                if (statsProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.text),
                  ),

                // Estadísticas principales
                if (statsProvider.userStats != null) ...[
                  _buildMainStats(statsProvider.userStats!),
                  const SizedBox(height: 24),
                  _buildStreakStats(statsProvider.userStats!),
                  const SizedBox(height: 24),
                  _buildDistributionChart(statsProvider),
                ] else if (!statsProvider.isLoading) ...[
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No hay estadísticas disponibles.\n¡Juega tu primer juego con Alexa!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.text, fontSize: 16),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    bool shouldLogout = await _showLogoutDialog(context);
                    if (shouldLogout) {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      200,
                      50,
                    ), // Ancho y alto más pequeños
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainStats(UserStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatBox(
          label: 'Jugados',
          value: '${stats.totalGames}',
          color: AppColors.text,
        ),
        _StatBox(
          label: 'Ganados',
          value: '${stats.wins}',
          color: AppColors.green,
        ),
        _StatBox(
          label: '% Victorias',
          value: '${stats.winPercentage}%',
          color: AppColors.yellow,
        ),
      ],
    );
  }

  Widget _buildStreakStats(UserStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatBox(
          label: 'Racha actual',
          value: '${stats.currentStreak}',
          color: AppColors.green,
        ),
        _StatBox(
          label: 'Mejor racha',
          value: '${stats.maxStreak}',
          color: AppColors.yellow,
        ),
        _StatBox(
          label: 'Promedio',
          value: stats.averageAttempts.toStringAsFixed(1),
          color: AppColors.text,
        ),
      ],
    );
  }

  Widget _buildDistributionChart(StatsProvider statsProvider) {
    final percentages = statsProvider.getAttemptDistributionPercentages();
    final stats = statsProvider.userStats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución de intentos',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(6, (index) {
          final attemptNumber = index + 1;
          final count = stats.attemptDistribution[index];
          final percentage = percentages[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '$attemptNumber',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: stats.wins > 0 ? percentage / 100 : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: AppColors.text),
              ),
              content: const Text(
                '¿Estás seguro de que quieres cerrar sesión?',
                style: TextStyle(color: AppColors.text),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.text),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
