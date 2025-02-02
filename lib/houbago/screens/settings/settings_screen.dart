import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      appBar: AppBar(
        backgroundColor: HoubagoTheme.backgroundLight,
        title: Text(
          'Objectifs',
          style: HoubagoTheme.textTheme.titleLarge,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDailyObjectif(),
          const SizedBox(height: 20),
          Text(
            'Objectifs en cours',
            style: HoubagoTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildObjectifCard(
            'Livraisons de la semaine',
            '12/20',
            0.6,
            HoubagoTheme.primary,
            Icons.local_shipping_rounded,
          ),
          const SizedBox(height: 12),
          _buildObjectifCard(
            'Satisfaction clients',
            '4.8/5.0',
            0.95,
            Colors.amber,
            Icons.star_rounded,
          ),
          const SizedBox(height: 12),
          _buildObjectifCard(
            'Temps moyen de livraison',
            '18/15 min',
            0.75,
            Colors.green,
            Icons.timer_rounded,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Challenges',
                style: HoubagoTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Voir tout',
                  style: TextStyle(color: HoubagoTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildChallengeCard(
            'Champion de la semaine',
            'Effectuez 25 livraisons cette semaine',
            '🏆 Badge Or + 50€ bonus',
            Colors.orange,
            0.32,
            '8/25',
          ),
          const SizedBox(height: 12),
          _buildChallengeCard(
            'Expert de la rapidité',
            'Maintenez une moyenne de 12min par livraison',
            '⚡ Badge Éclair + 30€ bonus',
            Colors.blue,
            0.85,
            '11/12 min',
          ),
          const SizedBox(height: 24),
          _buildRewardsSection(),
        ],
      ),
    );
  }

  Widget _buildDailyObjectif() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HoubagoTheme.primary, HoubagoTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.calendar_today, color: Colors.white),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Objectif du jour',
            style: HoubagoTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '5 livraisons restantes',
            style: HoubagoTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.58,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '7/12 livraisons',
            style: HoubagoTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectifCard(String title, String value, double progress, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: HoubagoTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: HoubagoTheme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(String title, String description, String reward, Color color, double progress, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: HoubagoTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: HoubagoTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'En cours',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: HoubagoTheme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.card_giftcard, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  reward,
                  style: HoubagoTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Récompenses débloquées',
                  style: HoubagoTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '3/12',
                  style: TextStyle(
                    color: HoubagoTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRewardBadge('🏃', 'Sprint', true),
                _buildRewardBadge('⭐', 'Elite', true),
                _buildRewardBadge('🎯', 'Précision', true),
                _buildRewardBadge('🌟', 'Expert', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardBadge(String emoji, String label, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: unlocked ? Colors.amber.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: unlocked ? Colors.grey[800] : Colors.grey[400],
            fontWeight: unlocked ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
