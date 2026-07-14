import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../auth/login_screen.dart';
import '../../settings/category_management_screen.dart';
import '../../../providers/theme_provider.dart';

class SettingsProfileTab extends StatefulWidget {
  const SettingsProfileTab({super.key});

  @override
  State<SettingsProfileTab> createState() => _SettingsProfileTabState();
}

class _SettingsProfileTabState extends State<SettingsProfileTab> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.uploadAvatar(image.path);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avatar updated successfully'), backgroundColor: AppColors.income),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error ?? 'Failed to update avatar'), backgroundColor: AppColors.expense),
          );
        }
      }
    }
  }

  Future<void> _deleteAvatar() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.deleteAvatar();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar deleted successfully'), backgroundColor: AppColors.income),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Failed to delete avatar'), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController.text = user?.fullName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Update Profile Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.updateProfile(_nameController.text.trim());
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.income),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.error ?? 'Failed to update profile'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _emailController.text = user?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Change Registered Email'),
        content: TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'New Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = _emailController.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) return;
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.requestChangeEmail(newEmail, '');
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email change verification sent / updated!'), backgroundColor: AppColors.income),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.error ?? 'Failed to update email'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'New Password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldP = _oldPasswordController.text;
              final newP = _newPasswordController.text;
              if (oldP.isEmpty || newP.length < 6) return;
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.changePassword(oldP, newP);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully'), backgroundColor: AppColors.income),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.error ?? 'Password update failed'), backgroundColor: AppColors.expense),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info header
              const SizedBox(height: 12),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: user?.avatar == null || user!.avatar!.isEmpty
                          ? const Icon(Icons.person, size: 54, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: _pickAvatar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (user?.avatar != null && user!.avatar!.isNotEmpty)
                Center(
                  child: TextButton(
                    onPressed: _deleteAvatar,
                    child: const Text('Remove avatar avatar', style: TextStyle(color: AppColors.expense, fontSize: 13)),
                  ),
                ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  user?.fullName ?? 'Standard User',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  user?.email ?? 'user@domain.com',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? 'USER',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Settings Panels
              const Text('ACCOUNT OPERATIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),

              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Update Display Name',
                onTap: _showEditProfileDialog,
              ),
              _buildSettingsTile(
                icon: Icons.email_outlined,
                title: 'Update Email Address',
                onTap: _showChangeEmailDialog,
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password Security',
                onTap: _showChangePasswordDialog,
              ),
              
              const SizedBox(height: 24),
              const Text('CLASSIFICATION CONFIGS', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              
              _buildSettingsTile(
                icon: Icons.category_outlined,
                title: 'Manage Categories',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text('PREFERENCES', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 12),

              _buildThemeToggleTile(context),

              const SizedBox(height: 48),

              // Logout CTA Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out Session'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Confirm Log Out'),
        content: const Text('Are you sure you want to end your session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildThemeToggleTile(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: AppColors.primary,
        ),
        title: const Text(
          'Dark Theme Mode',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        trailing: Switch(
          value: themeProvider.isDarkMode,
          onChanged: (val) {
            themeProvider.toggleTheme();
          },
        ),
      ),
    );
  }
}
