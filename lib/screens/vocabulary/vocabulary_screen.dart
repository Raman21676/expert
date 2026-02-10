import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database/database_helper.dart';
import '../../core/database/models/vocabulary.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';

/// Vocabulary Screen
/// 
/// Displays user's learned vocabulary words
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  List<Vocabulary> _vocabulary = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    final userProvider = context.read<UserProvider>();
    final targetLanguage = userProvider.targetLanguage;
    
    final db = DatabaseHelper.instance;
    final vocab = await db.getAllVocabulary(
      language: targetLanguage,
    );
    
    setState(() {
      _vocabulary = vocab;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vocabulary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Sort options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vocabulary.isEmpty
              ? _buildEmptyState()
              : _buildVocabularyList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No words yet!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with your AI tutor\nto build your vocabulary.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vocabulary.length,
      itemBuilder: (context, index) {
        final vocab = _vocabulary[index];
        return _buildVocabularyCard(vocab);
      },
    );
  }

  Widget _buildVocabularyCard(Vocabulary vocab) {
    final proficiencyColor = _getProficiencyColor(vocab.proficiency);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vocab.word,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vocab.translation,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: proficiencyColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: proficiencyColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${vocab.proficiency}/5',
                        style: TextStyle(
                          color: proficiencyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (vocab.exampleSentence != null && vocab.exampleSentence!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Example:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                vocab.exampleSentence!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  'Reviewed ${vocab.reviewCount} times',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProficiencyColor(int level) {
    switch (level) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return AppTheme.success;
      default:
        return Colors.grey;
    }
  }
}
