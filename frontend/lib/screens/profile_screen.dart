import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ================= PROFILE AVATAR =================
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyan, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.navyBlue,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.cyan,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= NAME =================
                Text(
                  user?.name ?? 'Guest User',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // ================= EMAIL =================
                Text(
                  user?.email ?? 'guest@musiverse.com',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.cyan),
                ),

                const SizedBox(height: 40),

                // ================= STATS =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite,
                          count: musicProvider.likedSongs.length,
                          label: 'Liked Songs',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.history,
                          count: musicProvider.recentlyPlayed.length,
                          label: 'Recently Played',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ================= OPTIONS =================
                _buildOption(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _buildOption(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildOption(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  onTap: () {},
                ),
                _buildOption(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                _buildOption(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {},
                ),

                const SizedBox(height: 32),

                // ================= LOGOUT =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        authProvider.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.navyBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.cyan),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.lightGrey),
      onTap: onTap,
    );
  }
}

// ================= STAT CARD =================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyBlue.withOpacity(0.5),
            AppColors.darkViolet.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.cyan, size: 32),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.lightGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
