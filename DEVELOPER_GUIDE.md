# LingoNative AI - Developer Guide

> **For:** Developers continuing this project  
> **Prerequisites:** macOS, Android device for testing  
> **Time to Setup:** ~2 hours  
> **Last Updated:** February 10, 2026

---

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone git@github.com:Raman21676/expert.git
cd expert/lingo_native_ai

# 2. Install dependencies
flutter pub get

# 3. Download AI model (320MB)
mkdir -p assets/models
huggingface-cli download Qwen/Qwen2.5-1.5B-Instruct-GGUF \
  qwen2.5-1.5b-instruct-q4_k_m.gguf \
  --local-dir assets/models

# 4. Build native libraries (one-time)
cd ../scripts
chmod +x build_llama_cpp_android.sh
./build_llama_cpp_android.sh

# 5. Run on device
flutter run
```

---

## 📋 Prerequisites

### Required Software

| Software | Version | Purpose | Install Command |
|----------|---------|---------|-----------------|
| Flutter | 3.10+ | Framework | `git clone https://github.com/flutter/flutter.git` |
| Dart | 3.0+ | Language | Bundled with Flutter |
| Android SDK | API 24+ | Android dev | Via Android Studio |
| Android NDK | r26+ | Native code | Via Android Studio |
| CMake | 3.22+ | Build tool | `brew install cmake` |
| Python | 3.10+ | Model tools | `brew install python@3.10` |
| Git | 2.30+ | Version control | `brew install git` |

### Hardware Requirements

**Development Machine (Your MacBook Pro 2016):**
- macOS 12+ (Monterey or newer)
- 8GB RAM minimum (16GB recommended)
- 50GB free disk space
- Intel i5 or better

**Test Device:**
- Android 7.0+ (API 24)
- 4GB RAM minimum
- 1GB free storage
- ARM64 or ARMv7 processor

---

## 🔧 Step-by-Step Setup

### Step 1: Install Flutter

```bash
# Download Flutter stable
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter doctor -v
```

**Expected Output:**
```
[✓] Flutter (Channel stable, 3.19.0, ...)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio
```

### Step 2: Install Android Studio

1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Install and open Android Studio
3. Go to **Settings → SDK Manager**
4. Install:
   - ✅ Android SDK Platform (API 24-34)
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools
   - ✅ Android Emulator (optional)
   - ✅ Android NDK (Side by side) 26.1.10909125

```bash
# Accept licenses
flutter doctor --android-licenses
```

### Step 3: Install Python & Tools

```bash
# Install Python
brew install python@3.10

# Install HuggingFace CLI
pip3 install huggingface-hub

# Verify
huggingface-cli --version
```

### Step 4: Clone Repository

```bash
# Clone with SSH
git clone git@github.com:Raman21676/expert.git

# Navigate to project
cd expert/lingo_native_ai

# Get Flutter dependencies
flutter pub get
```

### Step 5: Download AI Model

```bash
# Create models directory
mkdir -p assets/models

# Download Qwen2.5-1.5B-Instruct (320MB)
huggingface-cli download \
  Qwen/Qwen2.5-1.5B-Instruct-GGUF \
  qwen2.5-1.5b-instruct-q4_k_m.gguf \
  --local-dir assets/models

# Verify download
ls -lh assets/models/
# Should show: qwen2.5-1.5b-instruct-q4_k_m.gguf (~320MB)
```

**Alternative: Manual Download**
1. Visit: https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF
2. Download: `qwen2.5-1.5b-instruct-q4_k_m.gguf`
3. Move to: `assets/models/`

### Step 6: Build Native Libraries (llama.cpp)

```bash
# Navigate to scripts
cd scripts

# Make script executable
chmod +x build_llama_cpp_android.sh

# Run build script
./build_llama_cpp_android.sh
```

**What this does:**
1. Clones llama.cpp repository
2. Builds for Android ARM64
3. Builds for Android ARMv7
4. Copies .so files to `android/app/src/main/jniLibs/`

**Expected Output:**
```
✅ llama.cpp compiled for Android ARM64!
✅ llama.cpp compiled for Android ARMv7!
✅ Libraries copied to jniLibs!
```

### Step 7: Run the App

```bash
# Connect Android device via USB
# Enable USB debugging on device

# Verify device connection
flutter devices

# Run app
flutter run

# Or run in release mode
flutter run --release
```

---

## 🏗️ Project Structure for Developers

### Where to Find Things

| What You're Looking For | Location |
|------------------------|----------|
| Database operations | `lib/core/database/` |
| AI/LLM logic | `lib/services/llm/` |
| UI screens | `lib/screens/` |
| State management | `lib/providers/` |
| App themes | `lib/core/theme/` |
| String translations | `assets/l10n/*.arb` |
| Build scripts | `scripts/` |
| Native libs | `android/app/src/main/jniLibs/` |

### Key Files to Understand

```dart
// START HERE - Main entry point
lib/main.dart
  → Sets up providers
  → Configures routing
  → Initializes services

// DATABASE - How data is stored
lib/core/database/database_helper.dart
  → 4 tables: user_profile, chat_messages, learned_vocabulary, mistake_log
  → Automatic compression after 100 messages

// AI LOGIC - How the LLM works
lib/services/llm/enhanced_llm_service.dart
  → Streaming responses
  → Validation & retry logic
  → Hallucination detection

// PROMPTS - How we talk to the AI
lib/services/llm/prompt_templates.dart
  → Chain-of-Thought instructions
  → Few-shot examples
  → Level-specific guidelines

// SAFETY - Quality control
lib/services/llm/response_validator.dart
  → Self-consistency checks
  → Repetition detection
  → Gibberish filtering
```

---

## 🧪 Development Workflow

### Daily Development

```bash
# 1. Start of day
git pull origin main
flutter pub get

# 2. Run app in debug mode
flutter run

# 3. Make changes...
# Edit files in lib/

# 4. Hot reload (press 'r' in terminal)
# or Hot restart (press 'R')

# 5. Commit changes
git add -A
git commit -m "[PHASE-X] What you changed"
git push origin main
```

### Testing Changes

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/database_test.dart

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Check for issues
flutter doctor
```

---

## 🔍 Debugging

### Enable Logging

```dart
// In main.dart, before runApp
await LoggingService.instance.initialize();

// Log files saved to:
// Android: /Android/data/com.lingonative/files/logs/
```

### Export Logs

```dart
// Add button in Settings screen:
ElevatedButton(
  onPressed: () async {
    final logs = await LoggingService.instance.exportLogs();
    // Share logs via email, etc.
  },
  child: Text('Export Debug Logs'),
)
```

### Common Debug Commands

```bash
# Check Flutter setup
flutter doctor -v

# List connected devices
flutter devices

# Run with verbose logging
flutter run --verbose

# Profile performance
flutter run --profile

# Build release APK
flutter build apk --release

# View device logs
flutter logs
```

---

## 📦 Building for Release

### Build APK

```bash
# Debug APK (for testing)
flutter build apk

# Release APK (for distribution)
flutter build apk --release

# Split by architecture (recommended)
flutter build apk --split-per-abi --release
```

**Output Locations:**
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`
- Split: `build/app/outputs/flutter-apk/*-release.apk`

### Sign the APK

```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Configure signing in android/app/build.gradle
# (Already configured in this project)

# Build signed APK
flutter build apk --release
```

---

## 🐛 Troubleshooting

### Issue: `flutter doctor` shows Android SDK issues

**Solution:**
```bash
# Accept all licenses
flutter doctor --android-licenses

# If that fails, check SDK path
flutter config --android-sdk /path/to/android/sdk
```

### Issue: Model file not found

**Solution:**
```bash
# Verify file exists
ls -la assets/models/

# Check pubspec.yaml has:
flutter:
  assets:
    - assets/models/

# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

### Issue: FFI/Dynamic library errors

**Solution:**
```bash
# Native libs not built
ls android/app/src/main/jniLibs/
# Should show: arm64-v8a/libllama.so, armeabi-v7a/libllama.so

# Rebuild native libs
cd scripts
./build_llama_cpp_android.sh
```

### Issue: Out of memory during inference

**Solution:**
```dart
// In enhanced_llm_service.dart, reduce context:
static const int contextSize = 1024; // Instead of 2048

// Reduce threads:
int _getOptimalThreadCount() => 2; // Instead of 3-4
```

### Issue: Slow responses

**Solution:**
```dart
// Reduce max tokens
maxTokens: 100, // Instead of 200

// Disable self-consistency validation
validateResponse: false, // Skip double-check
```

---

## 📚 Learning Resources

### Flutter
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Dart FFI](https://dart.dev/guides/libraries/c-interop)

### LLM/AI
- [llama.cpp Documentation](https://github.com/ggerganov/llama.cpp)
- [Qwen Model Card](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct)
- [GGUF Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)

### Android
- [Android NDK Guide](https://developer.android.com/ndk/guides)
- [CMake for Android](https://developer.android.com/ndk/guides/cmake)

---

## 🤝 Contributing

### Code Style

```dart
// Use trailing commas for better diffs
final user = User(
  name: 'John',
  age: 30,  // <-- trailing comma
);

// Document public APIs
/// Creates a new user profile
/// 
/// [name] must not be empty
/// [language] must be a valid language code
Future<void> createProfile({
  required String name,
  required String language,
}) async {...}

// Use const constructors where possible
const SizedBox(height: 16);  // Good
SizedBox(height: 16);        // Avoid
```

### Testing Requirements

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for critical flows
- Maintain >80% code coverage

### Commit Guidelines

```bash
# Format: [TYPE] Brief description

[PHASE-3] Add vocabulary screen
[FIX] Resolve database migration issue
[UI] Update chat bubble colors
[TEST] Add unit tests for validator
[DOCS] Update API documentation
```

---

## 📞 Support

**Stuck?**
1. Check this guide
2. Review `PROJECT_DOCUMENTATION.md`
3. Check logs: `LoggingService.instance.exportLogs()`
4. Search [Flutter Issues](https://github.com/flutter/flutter/issues)
5. File issue on project GitHub

---

**Happy Coding! 🚀**
