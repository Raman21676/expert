import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';

/// Progress Screen
/// 
/// Shows user learning statistics and achievements
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseHelper.instance;
    final stats = await db.getStats();
    
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with streak
                    _buildStreakHeader(profile?.learningStreak ?? 0),
                    const SizedBox(height: 24),
                    
                    // Stats grid
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    
                    // Proficiency section
                    _buildProficiencySection(),
                    const SizedBox(height: 24),
                    
                    // Achievements
                    _buildAchievementsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStreakHeader(int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  streak == 1 ? 'Day Streak' : 'Days Streak',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final messages = _stats['messages'] ?? 0;
    final vocabulary = _stats['vocabulary'] ?? 0;
    final activeMistakes = _stats['activeMistakes'] ?? 0;
    final masteredMistakes = _stats['masteredMistakes'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          icon: Icons.chat_bubble_outline,
          value: messages.toString(),
          label: 'Messages',
          color: AppTheme.primaryColor,
        ),
        _buildStatCard(
          icon: Icons.book_outlined,
          value: vocabulary.toString(),
          label: 'Words Learned',
          color: AppTheme.secondaryColor,
        ),
        _buildStatCard(
          icon: Icons.error_outline,
          value: activeMistakes.toString(),
          label: 'Active Mistakes',
          color: AppTheme.warning,
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          value: masteredMistakes.toString(),
          label: 'Mastered',
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProficiencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Level',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProficiencyBar('Beginner', 0.3, Colors.green),
                const SizedBox(height: 12),
                _buildProficiencyBar('Intermediate', 0.0, Colors.orange),
                const SizedBox(height: 12),
                _buildProficiencyBar('Advanced', 0.0, Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProficiencyBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildAchievementTile(
          icon: Icons.emoji_events,
          title: 'First Steps',
          description: 'Send your first message',
          unlocked: (_stats['messages'] ?? 0) > 0,
        ),
        _buildAchievementTile(
          icon: Icons.book,
          title: 'Word Collector',
          description: 'Learn 10 words',
          unlocked: (_stats['vocabulary'] ?? 0) >= 10,
        ),
        _buildAchievementTile(
          icon: Icons.local_fire_department,
          title: 'On Fire',
          description: '7 day streak',
          unlocked: false, // TODO: Get actual streak
        ),
      ],
    );
  }

  Widget _buildAchievementTile({
    required IconData icon,
    required String title,
    required String description,
    required bool unlocked,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: unlocked ? AppTheme.accentColor : Colors.grey[400],
          size: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: unlocked ? null : Colors.grey[500],
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: unlocked ? null : Colors.grey[400],
          ),
        ),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: AppTheme.success)
            : Icon(Icons.lock_outline, color: Colors.grey[400]),
      ),
    );
  }
}
