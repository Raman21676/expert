import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';

/// Language Selection Screen
/// 
/// Allows user to select native and target languages
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _currentStep = 0;
  String? _selectedNativeLanguage;
  String? _selectedTargetLanguage;
  String _selectedProficiency = 'beginner';

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'Your Language' : 'Learning Language'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 32),
              
              // Step content
              Expanded(
                child: _currentStep == 0
                    ? _buildNativeLanguageStep()
                    : _currentStep == 1
                        ? _buildTargetLanguageStep()
                        : _buildProficiencyStep(),
              ),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    _currentStep == 2 ? 'Continue' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNativeLanguageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your native language?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us explain concepts in a way you understand.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: LanguageProvider.supportedLanguages.length,
            itemBuilder: (context, index) {
              final entry = LanguageProvider.supportedLanguages.entries.elementAt(index);
              final code = entry.key;
              final info = entry.value;
              final isSelected = _selectedNativeLanguage == code;

              return _buildLanguageCard(
                code: code,
                flag: info['flag']!,
                nativeName: info['nativeName']!,
                englishName: info['name']!,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedNativeLanguage = code),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTargetLanguageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which language do you want to learn?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can learn any language except your native one.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: LanguageProvider.supportedLanguages.length,
            itemBuilder: (context, index) {
              final entry = LanguageProvider.supportedLanguages.entries.elementAt(index);
              final code = entry.key;
              final info = entry.value;
              final isSelected = _selectedTargetLanguage == code;
              final isDisabled = code == _selectedNativeLanguage;

              return _buildLanguageCard(
                code: code,
                flag: info['flag']!,
                nativeName: info['nativeName']!,
                englishName: info['name']!,
                isSelected: isSelected,
                isDisabled: isDisabled,
                onTap: isDisabled ? null : () => setState(() => _selectedTargetLanguage = code),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProficiencyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your level?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us tailor lessons to your skill level.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        _buildProficiencyCard(
          level: 'beginner',
          title: 'Beginner',
          subtitle: 'I\'m just starting out',
          icon: Icons.school,
        ),
        const SizedBox(height: 12),
        _buildProficiencyCard(
          level: 'intermediate',
          title: 'Intermediate',
          subtitle: 'I know some basics',
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 12),
        _buildProficiencyCard(
          level: 'advanced',
          title: 'Advanced',
          subtitle: 'I want to master the language',
          icon: Icons.emoji_events,
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String code,
    required String flag,
    required String nativeName,
    required String englishName,
    required bool isSelected,
    bool isDisabled = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey[100]
                : isSelected
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[300]!
                  : isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey[200]!,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nativeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDisabled ? Colors.grey : null,
                          ),
                    ),
                    Text(
                      englishName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected && !isDisabled)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              if (isDisabled)
                Icon(
                  Icons.block,
                  color: Colors.grey[400],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProficiencyCard({
    required String level,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedProficiency == level;

    return InkWell(
      onTap: () => setState(() => _selectedProficiency = level),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedNativeLanguage != null;
      case 1:
        return _selectedTargetLanguage != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _onContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Save selections and navigate to profile setup
      final provider = context.read<LanguageProvider>();
      provider.setNativeLanguage(_selectedNativeLanguage!);
      provider.setTargetLanguage(_selectedTargetLanguage!);
      provider.setProficiencyLevel(_selectedProficiency);
      
      Navigator.of(context).pushNamed('/profile-setup');
    }
  }
}
