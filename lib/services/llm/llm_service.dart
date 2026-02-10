import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'llama_cpp_bindings.dart';

/// High-level LLM Service
/// 
/// Manages model loading, inference, and resource cleanup.
/// Uses singleton pattern for app-wide access.
class LLMService {
  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  static LLMService get instance => _instance;

  LlamaCppBindings? _bindings;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _modelPath;

  // Default inference parameters optimized for language learning
  static const int defaultMaxTokens = 200;
  static const double defaultTemperature = 0.7;
  static const double defaultTopP = 0.9;

  // Stream controller for generation progress
  final _progressController = StreamController<String>.broadcast();
  Stream<String> get progressStream => _progressController.stream;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Initialize the LLM service
  /// 
  /// This copies the model from assets to app documents directory
  /// and loads it into memory.
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    _progressController.add('Loading AI model...');

    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _modelPath = '${appDir.path}/SmolLM2-360M-Instruct-Q4_K_M.gguf';
      final modelFile = File(_modelPath!);

      // Copy model from assets if not exists
      if (!await modelFile.exists()) {
        _progressController.add('Copying model to device storage...');
        await _copyModelFromAssets(_modelPath!);
      }

      // Verify model file
      if (!await modelFile.exists()) {
        throw Exception('Model file not found at $_modelPath');
      }

      final fileSize = await modelFile.length();
      if (fileSize < 100000000) { // Less than 100MB is suspicious
        throw Exception('Model file appears to be incomplete ($fileSize bytes)');
      }

      // Initialize llama.cpp
      _progressController.add('Initializing inference engine...');
      _bindings = LlamaCppBindings();
      
      // Use smaller context on low-memory devices
      final contextSize = await _getOptimalContextSize();
      final nThreads = await _getOptimalThreadCount();

      await _bindings!.initialize(
        _modelPath!,
        contextSize: contextSize,
        nThreads: nThreads,
      );

      _isInitialized = true;
      _progressController.add('AI ready!');
      
    } catch (e, stackTrace) {
      _progressController.add('Error: $e');
      throw Exception('Failed to initialize LLM: $e\n$stackTrace');
    } finally {
      _isLoading = false;
    }
  }

  /// Copy model from Flutter assets to device storage
  Future<void> _copyModelFromAssets(String destinationPath) async {
    try {
      // Try to load from assets
      final byteData = await rootBundle.load('assets/models/SmolLM2-360M-Instruct-Q4_K_M.gguf');
      final buffer = byteData.buffer;
      
      final file = File(destinationPath);
      await file.create(recursive: true);
      await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        flush: true,
      );
      
    } catch (e) {
      throw Exception('Failed to copy model from assets: $e\n'
          'Make sure the model file is included in pubspec.yaml assets');
    }
  }

  /// Determine optimal context size based on available memory
  Future<int> _getOptimalContextSize() async {
    // On older devices or low-memory devices, use smaller context
    // Qwen2.5-1.5B with 2K context uses ~600MB RAM
    // With 4K context uses ~1GB RAM
    
    // For MacBook Pro 2016 (8GB RAM), use 2048 to be safe
    // For modern Android phones (8GB+ RAM), can use 4096
    
    if (Platform.isAndroid) {
      // Conservative for mobile
      return 2048;
    }
    
    // Desktop/development - can use more
    return 4096;
  }

  /// Determine optimal thread count
  Future<int> _getOptimalThreadCount() async {
    // Use half the available cores for inference
    // Leave cores for UI and other tasks
    final cores = Platform.numberOfProcessors;
    return (cores / 2).clamp(2, 6).toInt();
  }

  /// Generate a response from the AI
  /// 
  /// [prompt] - The formatted prompt with context
  /// [maxTokens] - Maximum tokens to generate
  /// [temperature] - Creativity parameter (0.0 - 1.0)
  Future<String> generateResponse(
    String prompt, {
    int maxTokens = defaultMaxTokens,
    double temperature = defaultTemperature,
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw Exception('LLM not initialized. Call initialize() first.');
    }

    try {
      final response = _bindings!.generate(
        prompt,
        maxTokens: maxTokens,
        temperature: temperature,
        topP: defaultTopP,
      );

      // Clean up response
      return _cleanResponse(response);
    } catch (e) {
      throw Exception('Generation failed: $e');
    }
  }

  /// Stream a response (for future implementation with token streaming)
  Stream<String> generateResponseStream(
    String prompt, {
    int maxTokens = defaultMaxTokens,
  }) async* {
    // TODO: Implement token streaming when llama.cpp bindings support it
    // For now, just yield the complete response
    final response = await generateResponse(prompt, maxTokens: maxTokens);
    yield response;
  }

  /// Clean up the generated response
  String _cleanResponse(String response) {
    return response
        .trim()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Max 2 newlines
        .replaceAll(RegExp(r'User:.*'), '') // Remove any "User:" that model might add
        .replaceAll(RegExp(r'Assistant:.*'), '') // Remove any "Assistant:" prefix
        .trim();
  }

  /// Get model information
  Map<String, dynamic> getModelInfo() {
    return {
      'model': 'SmolLM2-360M-Instruct',
      'quantization': 'Q4_K_M',
      'size': '258MB',
      'contextSize': _bindings?.getContextSize(),
      'initialized': _isInitialized,
    };
  }

  /// Unload the model to free memory
  Future<void> unloadModel() async {
    if (_bindings != null) {
      _bindings!.dispose();
      _bindings = null;
      _isInitialized = false;
    }
  }

  /// Dispose the service
  void dispose() {
    unloadModel();
    _progressController.close();
  }
}
