import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

/// FFI Bindings for llama.cpp
/// 
/// This class provides Dart bindings to the llama.cpp shared library
/// for running Qwen2.5-1.5B-Instruct on Android devices.
/// 
/// NOTE: The actual C++ wrapper needs to be compiled and included as
/// native libraries in android/app/src/main/jniLibs/

// C function signatures
typedef LlamaInitNative = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Utf8> modelPath,
  ffi.Int32 nCtx,
  ffi.Int32 nThreads,
);
typedef LlamaInit = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Utf8> modelPath,
  int nCtx,
  int nThreads,
);

typedef LlamaGenerateNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<ffi.Void> ctx,
  ffi.Pointer<Utf8> prompt,
  ffi.Int32 maxTokens,
  ffi.Float temperature,
  ffi.Float topP,
);
typedef LlamaGenerate = ffi.Pointer<Utf8> Function(
  ffi.Pointer<ffi.Void> ctx,
  ffi.Pointer<Utf8> prompt,
  int maxTokens,
  double temperature,
  double topP,
);

typedef LlamaFreeNative = ffi.Void Function(ffi.Pointer<ffi.Void> ctx);
typedef LlamaFree = void Function(ffi.Pointer<ffi.Void> ctx);

typedef LlamaGetContextSizeNative = ffi.Int32 Function(ffi.Pointer<ffi.Void> ctx);
typedef LlamaGetContextSize = int Function(ffi.Pointer<ffi.Void> ctx);

/// LlamaCppBindings - FFI wrapper for llama.cpp
class LlamaCppBindings {
  late final ffi.DynamicLibrary _lib;
  late final LlamaInit _llamaInit;
  late final LlamaGenerate _llamaGenerate;
  late final LlamaFree _llamaFree;
  late final LlamaGetContextSize? _llamaGetContextSize;

  ffi.Pointer<ffi.Void>? _context;
  bool _isInitialized = false;

  /// Constructor - loads the native library
  LlamaCppBindings() {
    _loadLibrary();
    _lookupFunctions();
  }

  void _loadLibrary() {
    if (Platform.isAndroid) {
      try {
        _lib = ffi.DynamicLibrary.open('libllama.so');
      } catch (e) {
        throw Exception('Failed to load libllama.so: $e\n'
            'Make sure the native library is included in android/app/src/main/jniLibs/');
      }
    } else if (Platform.isIOS) {
      _lib = ffi.DynamicLibrary.process();
    } else if (Platform.isLinux) {
      _lib = ffi.DynamicLibrary.open('libllama.so');
    } else if (Platform.isMacOS) {
      _lib = ffi.DynamicLibrary.open('libllama.dylib');
    } else {
      throw UnsupportedError('Platform ${Platform.operatingSystem} not supported');
    }
  }

  void _lookupFunctions() {
    _llamaInit = _lib
        .lookup<ffi.NativeFunction<LlamaInitNative>>('llama_init')
        .asFunction();
    _llamaGenerate = _lib
        .lookup<ffi.NativeFunction<LlamaGenerateNative>>('llama_generate')
        .asFunction();
    _llamaFree = _lib
        .lookup<ffi.NativeFunction<LlamaFreeNative>>('llama_free')
        .asFunction();

    // Optional function
    try {
      _llamaGetContextSize = _lib
          .lookup<ffi.NativeFunction<LlamaGetContextSizeNative>>('llama_get_context_size')
          .asFunction();
    } catch (e) {
      _llamaGetContextSize = null;
    }
  }

  /// Initialize the model
  /// 
  /// [modelPath] - Absolute path to the .gguf model file
  /// [contextSize] - Context window size (default: 4096)
  /// [nThreads] - Number of threads for inference (default: 4)
  Future<void> initialize(
    String modelPath, {
    int contextSize = 4096,
    int nThreads = 4,
  }) async {
    if (_isInitialized) return;

    final pathPtr = modelPath.toNativeUtf8();
    try {
      _context = _llamaInit(pathPtr, contextSize, nThreads);

      if (_context == ffi.nullptr || _context == null) {
        throw Exception('Failed to initialize llama.cpp model at $modelPath');
      }

      _isInitialized = true;
    } finally {
      malloc.free(pathPtr);
    }
  }

  /// Generate a response from the model
  /// 
  /// [prompt] - The input prompt
  /// [maxTokens] - Maximum tokens to generate (default: 200)
  /// [temperature] - Sampling temperature (default: 0.7)
  /// [topP] - Nucleus sampling parameter (default: 0.9)
  String generate(
    String prompt, {
    int maxTokens = 200,
    double temperature = 0.7,
    double topP = 0.9,
  }) {
    if (!_isInitialized || _context == null) {
      throw Exception('Model not initialized. Call initialize() first.');
    }

    final promptPtr = prompt.toNativeUtf8();
    try {
      final resultPtr = _llamaGenerate(
        _context!,
        promptPtr,
        maxTokens,
        temperature,
        topP,
      );

      if (resultPtr == ffi.nullptr) {
        throw Exception('Generation returned null');
      }

      final result = resultPtr.toDartString();
      malloc.free(resultPtr);

      return result;
    } finally {
      malloc.free(promptPtr);
    }
  }

  /// Get the current context size (if supported)
  int? getContextSize() {
    if (_context == null || _llamaGetContextSize == null) return null;
    return _llamaGetContextSize!(_context!);
  }

  /// Check if the model is initialized
  bool get isInitialized => _isInitialized;

  /// Free resources and unload the model
  void dispose() {
    if (_context != null && _context != ffi.nullptr) {
      _llamaFree(_context!);
      _context = null;
      _isInitialized = false;
    }
  }
}

/// Simplified C++ wrapper header (for reference)
/* 
// llama_wrapper.h - This needs to be compiled with llama.cpp
#ifndef LLAMA_WRAPPER_H
#define LLAMA_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

void* llama_init(const char* model_path, int n_ctx, int n_threads);
const char* llama_generate(void* ctx, const char* prompt, int max_tokens, float temperature, float top_p);
void llama_free(void* ctx);
int llama_get_context_size(void* ctx);

#ifdef __cplusplus
}
#endif

#endif
*/
