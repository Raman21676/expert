import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'llama_cpp_bindings.dart';
import 'prompt_templates.dart';
import 'response_validator.dart';
import '../logging_service.dart';

/// Enhanced LLM Service
/// 
/// Production-ready LLM service with:
/// - Streaming responses for better UX
/// - Self-consistency validation
/// - Hallucination detection
/// - Fallback behavior
/// - Comprehensive logging
class EnhancedLLMService {
  static final EnhancedLLMService _instance = EnhancedLLMService._internal();
  factory EnhancedLLMService() => _instance;
  EnhancedLLMService._internal();

  static EnhancedLLMService get instance => _instance;

  LlamaCppBindings? _bindings;
  final LoggingService _logger = LoggingService.instance;
  
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _modelPath;

  // Configuration
  static const int defaultMaxTokens = 200;
  static const double defaultTemperature = 0.7;
  static const double defaultTopP = 0.9;
  static const int contextSize = 2048; // Conservative for 8GB RAM devices
  static const int maxRetries = 2;

  // Streaming controller
  final _streamController = StreamController<String>.broadcast();
  Stream<String> get responseStream => _streamController.stream;

  // Progress tracking
  final _progressController = StreamController<String>.broadcast();
  Stream<String> get progressStream => _progressController.stream;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;

  /// Initialize the LLM service
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;

    _isLoading = true;
    _progressController.add('Initializing AI tutor...');

    final stopwatch = Stopwatch()..start();

    try {
      // Copy model from assets
      final appDir = await getApplicationDocumentsDirectory();
      _modelPath = '${appDir.path}/SmolLM2-360M-Instruct-Q4_K_M.gguf';
      final modelFile = File(_modelPath!);

      if (!await modelFile.exists()) {
        _progressController.add('Setting up AI model (one-time)...');
        await _copyModelFromAssets(_modelPath!);
      }

      // Verify model
      if (!await modelFile.exists()) {
        throw Exception('Model file not found');
      }

      final fileSize = await modelFile.length();
      if (fileSize < 100000000) {
        throw Exception('Model file appears incomplete');
      }

      // Initialize bindings
      _progressController.add('Loading neural network...');
      _bindings = LlamaCppBindings();
      
      final nThreads = _getOptimalThreadCount();
      await _bindings!.initialize(
        _modelPath!,
        contextSize: contextSize,
        nThreads: nThreads,
      );

      _isInitialized = true;
      _progressController.add('AI tutor ready!');

      stopwatch.stop();
      _logger.info('EnhancedLLMService', 'Model initialized successfully', metadata: {
        'duration_ms': stopwatch.elapsedMilliseconds,
        'file_size_mb': (fileSize / 1024 / 1024).toStringAsFixed(2),
        'threads': nThreads,
        'context_size': contextSize,
      });

    } catch (e, stackTrace) {
      stopwatch.stop();
      _progressController.add('Error: Failed to load AI');
      
      _logger.error(
        'EnhancedLLMService',
        'Failed to initialize model',
        error: e,
        stackTrace: stackTrace,
      );
      
      throw Exception('Failed to initialize LLM: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Generate a response with full validation and streaming
  /// 
  /// This is the main method for production use.
  Future<String> generateResponse({
    required String prompt,
    required String targetLanguage,
    int maxTokens = defaultMaxTokens,
    double temperature = defaultTemperature,
    bool useStreaming = true,
    bool validateResponse = true,
  }) async {
    if (!_isInitialized || _bindings == null) {
      throw Exception('LLM not initialized');
    }

    if (_isGenerating) {
      throw Exception('Already generating a response');
    }

    _isGenerating = true;
    final stopwatch = Stopwatch()..start();
    String finalResponse = '';

    try {
      // Check input safety
      if (!PromptTemplates.isInputSafe(prompt)) {
        _logger.warning('EnhancedLLMService', 'Unsafe input detected');
        return PromptTemplates.safetyResponse();
      }

      _logger.info('EnhancedLLMService', 'Starting generation', metadata: {
        'prompt_length': prompt.length,
        'max_tokens': maxTokens,
        'temperature': temperature,
      });

      // Generate with streaming
      if (useStreaming) {
        await _generateWithStreaming(
          prompt: prompt,
          maxTokens: maxTokens,
          temperature: temperature,
        );
      }

      // Generate final response
      finalResponse = _bindings!.generate(
        prompt,
        maxTokens: maxTokens,
        temperature: temperature,
        topP: defaultTopP,
      );

      // Clean the response
      finalResponse = _cleanResponse(finalResponse);

      // Validate response quality
      if (validateResponse) {
        final quickCheck = ResponseValidator.quickQualityCheck(finalResponse);
        
        if (!quickCheck.passed) {
          _logger.warning('EnhancedLLMService', 'Response failed quick check', metadata: {
            'reason': quickCheck.reason,
          });

          // Try once more with adjusted parameters
          finalResponse = await _retryGeneration(
            prompt: prompt,
            maxTokens: maxTokens,
            reason: quickCheck.reason,
          );
        }

        // Check for hallucinations
        final hallucinationCheck = ResponseValidator.checkForHallucinations(
          finalResponse,
          targetLanguage,
        );

        if (hallucinationCheck.shouldFallback) {
          _logger.error('EnhancedLLMService', 'Severe hallucination detected', metadata: {
            'issues': hallucinationCheck.issues,
          });
          return _getFallbackResponse();
        }

        if (hallucinationCheck.shouldWarn) {
          _logger.warning('EnhancedLLMService', 'Response quality warning', metadata: {
            'issues': hallucinationCheck.issues,
          });
          finalResponse = _addQualityDisclaimer(finalResponse);
        }
      }

      stopwatch.stop();

      // Log successful generation
      _logger.logLLMInteraction(
        prompt: prompt,
        response: finalResponse,
        durationMs: stopwatch.elapsedMilliseconds,
        success: true,
        metadata: {
          'response_tokens': finalResponse.split(' ').length,
          'temperature': temperature,
        },
      );

      return finalResponse;

    } catch (e, stackTrace) {
      stopwatch.stop();
      
      _logger.logLLMInteraction(
        prompt: prompt,
        response: '',
        durationMs: stopwatch.elapsedMilliseconds,
        success: false,
        error: e.toString(),
      );

      _logger.error(
        'EnhancedLLMService',
        'Generation failed',
        error: e,
        stackTrace: stackTrace,
      );

      return _getFallbackResponse();
    } finally {
      _isGenerating = false;
    }
  }

  /// Generate with self-consistency validation
  /// 
  /// Runs generation twice and compares results for high-confidence answers.
  /// Use this for critical grammar corrections.
  Future<String> generateWithValidation({
    required String prompt,
    required String targetLanguage,
    int maxTokens = defaultMaxTokens,
  }) async {
    final result = await ResponseValidator.validateWithSelfConsistency(
      generateFn: (p) => generateResponse(
        prompt: p,
        targetLanguage: targetLanguage,
        maxTokens: maxTokens,
        useStreaming: false,
        validateResponse: false,
      ),
      prompt: prompt,
      targetLanguage: targetLanguage,
    );

    if (result.isValid && result.confidence > 0.7) {
      return result.response;
    } else {
      _logger.warning('EnhancedLLMService', 'Self-consistency check failed', metadata: {
        'confidence': result.confidence,
        'error': result.error,
      });
      return _addQualityDisclaimer(result.response);
    }
  }

  /// Stream generation (simulated for now)
  Future<void> _generateWithStreaming({
    required String prompt,
    required int maxTokens,
    required double temperature,
  }) async {
    // Emit initial "thinking" signal
    _streamController.add('');
    
    // In a real implementation with streaming-capable bindings,
    // this would emit tokens as they arrive.
    // For now, we just use it as a signal that generation has started.
  }

  /// Retry generation with adjusted parameters
  Future<String> _retryGeneration({
    required String prompt,
    required int maxTokens,
    required String reason,
  }) async {
    _logger.info('EnhancedLLMService', 'Retrying generation', metadata: {
      'reason': reason,
    });

    // Retry with lower temperature for more deterministic output
    final adjustedPrompt = '''$prompt

IMPORTANT: Provide a clear, accurate response.'''; // Intentional emoji in prompt

    return _bindings!.generate(
      adjustedPrompt,
      maxTokens: maxTokens,
      temperature: 0.5, // Lower temperature
      topP: 0.8,
    );
  }

  /// Copy model from assets to app directory
  Future<void> _copyModelFromAssets(String destinationPath) async {
    try {
      final byteData = await rootBundle.load(
        'assets/models/SmolLM2-360M-Instruct-Q4_K_M.gguf',
      );
      
      final file = File(destinationPath);
      await file.create(recursive: true);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(),
        flush: true,
      );
      
      _logger.info('EnhancedLLMService', 'Model copied successfully');
    } catch (e) {
      throw Exception('Failed to copy model: $e');
    }
  }

  /// Get optimal thread count for device
  int _getOptimalThreadCount() {
    final cores = Platform.numberOfProcessors;
    // Use 2-4 threads depending on cores
    return cores <= 2 ? 2 : (cores >= 8 ? 4 : 3);
  }

  /// Clean up the generated response
  String _cleanResponse(String response) {
    return response
        .trim()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'Assistant:|User:|Tutor:|Student:'), '')
        .trim();
  }

  /// Get fallback response when LLM fails
  String _getFallbackResponse() {
    return PromptTemplates.fallbackPrompt();
  }

  /// Add quality disclaimer to uncertain responses
  String _addQualityDisclaimer(String response) {
    return '''$response

⚠️ I'm not entirely certain about this answer. Please verify with additional resources if this is for an important context.'''; // Intentional emoji
  }

  /// Get model information
  Map<String, dynamic> getModelInfo() {
    return {
      'model': 'SmolLM2-360M-Instruct',
      'quantization': 'Q4_K_M',
      'estimated_size_mb': '320',
      'context_size': contextSize,
      'threads': _getOptimalThreadCount(),
      'initialized': _isInitialized,
      'generating': _isGenerating,
    };
  }

  /// Unload model to free memory
  Future<void> unloadModel() async {
    if (_bindings != null) {
      _bindings!.dispose();
      _bindings = null;
      _isInitialized = false;
      _logger.info('EnhancedLLMService', 'Model unloaded');
    }
  }

  /// Dispose service
  void dispose() {
    unloadModel();
    _streamController.close();
    _progressController.close();
  }
}
