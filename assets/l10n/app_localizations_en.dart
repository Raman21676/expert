// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LingoNative AI';

  @override
  String get welcome => 'Welcome to LingoNative AI';

  @override
  String get welcomeSubtitle =>
      'Your personal AI language tutor that works completely offline';

  @override
  String get selectNativeLanguage => 'Select your native language';

  @override
  String get selectTargetLanguage => 'Which language do you want to learn?';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get proficiencyBeginner => 'Beginner';

  @override
  String get proficiencyIntermediate => 'Intermediate';

  @override
  String get proficiencyAdvanced => 'Advanced';

  @override
  String get startLearning => 'Start Learning';

  @override
  String get continueText => 'Continue';

  @override
  String get chatPlaceholder => 'Type your message...';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingModel => 'Loading AI model...';

  @override
  String get errorLoadingModel => 'Error loading AI model';

  @override
  String get errorGeneral => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get settings => 'Settings';

  @override
  String get vocabulary => 'Vocabulary';

  @override
  String get progress => 'Progress';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get logout => 'Clear Data';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get typing => 'AI is typing...';

  @override
  String get noMessages => 'Start a conversation with your AI tutor!';

  @override
  String get wordLearned => 'Word learned';

  @override
  String get mistakeCorrected => 'Mistake corrected';

  @override
  String get streak => 'Day Streak';

  @override
  String get totalLessons => 'Total Lessons';

  @override
  String get wordsLearned => 'Words Learned';
}
