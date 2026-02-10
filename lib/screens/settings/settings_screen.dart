import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/logging_service.dart';

/// Settings Screen
/// 
/// App settings and configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader('Profile'),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(userProvider.name ?? 'User'),
            subtitle: Text(
              'Learning ${languageProvider.targetLanguageName ?? ''}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Edit profile
            },
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // TODO: Implement theme switching
            },
          ),
          const Divider(),

          // Learning Section
          _buildSectionHeader('Learning'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Native Language'),
            subtitle: Text(languageProvider.nativeLanguageName ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Change native language
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Target Language'),
            subtitle: Text(languageProvider.targetLanguageName ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Change target language
            },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Proficiency Level'),
            subtitle: Text(
              languageProvider.proficiencyLevel.toUpperCase(),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Change level
            },
          ),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Daily Reminders'),
            subtitle: const Text('Remind me to practice'),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
          const Divider(),

          // Data Section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download your learning data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from backup'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Import
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red[300]),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red[300]),
            ),
            subtitle: const Text('Delete everything permanently'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _confirmClearData,
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About LingoNative AI'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show help
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Export Debug Logs'),
            subtitle: const Text('For troubleshooting'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportLogs,
          ),
          const SizedBox(height: 32),

          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _exportData() async {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  Future<void> _exportLogs() async {
    try {
      final logs = await LoggingService.instance.exportLogs();
      
      // Show dialog with logs (truncated)
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Debug Logs'),
            content: SingleChildScrollView(
              child: Text(
                logs.length > 1000 ? '${logs.substring(0, 1000)}...' : logs,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Share logs
                  Navigator.pop(context);
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your chat history, vocabulary, and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<UserProvider>().deleteProfile();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LingoNative AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your personal AI language tutor that works completely offline.',
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            const Text('• 100% Offline - no internet needed'),
            const Text('• AI-powered personalized learning'),
            const Text('• Privacy-first - data stays on device'),
            const Text('• 13+ languages supported'),
            const SizedBox(height: 16),
            Text(
              'Model: SmolLM2-360M-Instruct',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
