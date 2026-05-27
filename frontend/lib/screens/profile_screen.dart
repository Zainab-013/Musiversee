import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
    });
  }

  Future<void> _togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
    setState(() {
      _pushNotifications = value;
    });
  }

  Future<void> _toggleEmailNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', value);
    setState(() {
      _emailNotifications = value;
    });
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final nameController = TextEditingController(text: authProvider.user?.name);
    final emailController = TextEditingController(text: authProvider.user?.email);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isLoading = context.watch<AuthProvider>().isLoading;
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit Profile Details',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: AppColors.lightGrey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.cyan),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: AppColors.lightGrey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.cyan),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.white),
                        decoration: const InputDecoration(
                          labelText: 'New Password (Optional)',
                          hintText: 'Leave empty to keep unchanged',
                          labelStyle: TextStyle(color: AppColors.lightGrey),
                          hintStyle: TextStyle(color: AppColors.darkGrey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.lightGrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.cyan),
                          ),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      isLoading
                          ? const CircularProgressIndicator(color: AppColors.cyan)
                          : ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() {});
                                final success = await authProvider.updateProfile(
                                  nameController.text.trim(),
                                  emailController.text.trim(),
                                  passwordController.text.isNotEmpty ? passwordController.text.trim() : null,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success ? 'Profile updated successfully' : 'Failed to update profile',
                                      ),
                                      backgroundColor: success ? AppColors.cyan : AppColors.primaryRed,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Save Details', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(color: AppColors.white)),
                    subtitle: const Text('Get real-time updates when new songs are released', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                    value: _pushNotifications,
                    activeColor: AppColors.cyan,
                    onChanged: (val) async {
                      await _togglePushNotifications(val);
                      setModalState(() {});
                    },
                  ),
                  const Divider(color: AppColors.darkGrey),
                  SwitchListTile(
                    title: const Text('Email Notifications', style: TextStyle(color: AppColors.white)),
                    subtitle: const Text('Receive weekly digests and music recommendations', style: TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                    value: _emailNotifications,
                    activeColor: AppColors.cyan,
                    onChanged: (val) async {
                      await _toggleEmailNotifications(val);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyBottomSheet(BuildContext context) {
    final musicProvider = context.read<MusicProvider>();
    musicProvider.fetchHiddenSongs();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Privacy Settings',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your hidden songs. Unhide a song to restore it to your Home and Library screens.',
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer<MusicProvider>(
                      builder: (context, music, child) {
                        if (music.hiddenSongs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open, size: 64, color: AppColors.cyan),
                                SizedBox(height: 12),
                                Text(
                                  'No Hidden Songs',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Songs you delete will appear here.',
                                  style: TextStyle(color: AppColors.lightGrey, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: music.hiddenSongs.length,
                          itemBuilder: (context, index) {
                            final song = music.hiddenSongs[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.darkGrey,
                                    width: 50,
                                    height: 50,
                                    child: const Icon(Icons.music_note, color: AppColors.cyan),
                                  ),
                                ),
                              ),
                              title: Text(song.name, style: const TextStyle(color: AppColors.white)),
                              subtitle: Text(song.singer, style: const TextStyle(color: AppColors.lightGrey, fontSize: 12)),
                              trailing: TextButton.icon(
                                icon: const Icon(Icons.visibility, color: AppColors.cyan, size: 18),
                                label: const Text('Unhide', style: TextStyle(color: AppColors.cyan)),
                                onPressed: () async {
                                  await music.unhideSong(song);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('"${song.name}" has been unhidden!'),
                                        backgroundColor: AppColors.cyan,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.cyan),
              SizedBox(width: 10),
              Text('Help & FAQs', style: TextStyle(color: AppColors.white)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _FAQTile(
                  question: 'How do I download songs?',
                  answer: 'Musiverse currently supports high-quality streaming. Offline download support is coming in version 2.0!',
                ),
                Divider(color: AppColors.darkGrey),
                _FAQTile(
                  question: 'How do I hide a song?',
                  answer: 'Go to the Manage Songs screen and click the Delete icon. The song will only be hidden for you.',
                ),
                Divider(color: AppColors.darkGrey),
                _FAQTile(
                  question: 'Who do I contact for support?',
                  answer: 'For account issues or music submissions, contact us at support@musiverse.com',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.cyan)),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cyan, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.cyan.withOpacity(0.4), blurRadius: 10),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: AppColors.navyBlue,
                  child: Icon(Icons.music_note, size: 40, color: AppColors.cyan),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Musiverse',
                style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.cyan, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'A premium, immersive music streaming and sharing experience built using Flutter and Spring Boot.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.lightGrey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text(
                '© 2026 Musiverse Team',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.cyan)),
            ),
          ],
        );
      },
    );
  }

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
                  onTap: () => _showEditProfileBottomSheet(context),
                ),
                _buildOption(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _showNotificationsBottomSheet(context),
                ),
                _buildOption(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  onTap: () => _showPrivacyBottomSheet(context),
                ),
                _buildOption(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _showHelpSupportDialog(context),
                ),
                _buildOption(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () => _showAboutDialog(context),
                ),

                const SizedBox(height: 32),

                // ================= LOGOUT =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (!context.mounted) return;
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

// ================= FAQ TILE =================
class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(color: AppColors.lightGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
