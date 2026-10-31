import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';
import 'register_guide_screen.dart';
import 'register_provider_screen.dart';
import 'register_tourist_screen.dart';

class RegisterChooserScreen extends StatelessWidget {
  const RegisterChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Horizon Travel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Account Type',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.navyPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose how you would like to experience Horizon Travel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Tourist Card
            _buildRoleCard(
              context: context,
              title: 'Tourist / Traveler',
              description: 'Discover & book hotel rooms, rides, attractions, hire local tour guides, and organize travel groups.',
              icon: Icons.luggage_outlined,
              iconColor: AppColors.primary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterTouristScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Tour Guide Card
            _buildRoleCard(
              context: context,
              title: 'Tour Guide',
              description: 'List your availability, guide tourists through local sights, manage hire requests, and broadcast your live meetup location.',
              icon: Icons.person_pin_circle_outlined,
              iconColor: AppColors.tealSuccess,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterGuideScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Service Provider Card
            _buildRoleCard(
              context: context,
              title: 'Service Provider',
              description: 'List and manage hotel slots, flights, buses, and entertainment venues. Track incoming tourist bookings and payments.',
              icon: Icons.business_center_outlined,
              iconColor: AppColors.coralAccent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterProviderScreen()),
                );
              },
            ),
            const SizedBox(height: 32),

            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withValues(alpha: 0.15),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
