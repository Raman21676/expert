# LingoNative AI - Complete Setup Guide

> **Goal:** Get the app running on your Android device  
> **Time Required:** 2-3 hours (first time)  
> **Difficulty:** Intermediate  
> **Last Updated:** February 10, 2026

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] macOS computer (MacBook Pro 2016 or newer)
- [ ] 10GB free disk space
- [ ] Android phone for testing (Android 7.0+)
- [ ] USB cable to connect phone to Mac
- [ ] Stable internet connection (for downloads)

---

## 🎯 Overview of Steps

```
Step 1: Install Flutter SDK         (15 min)
Step 2: Install Android Studio      (20 min)
Step 3: Install Python & Tools      (10 min)
Step 4: Clone Repository            (5 min)
Step 5: Download AI Model           (10 min, 320MB)
Step 6: Build Native Libraries      (30 min)
Step 7: Configure Device            (10 min)
Step 8: Run the App                 (5 min)
────────────────────────────────────────────
Total: ~2 hours (mostly waiting)
```

---

## Step 1: Install Flutter SDK

### 1.1 Download Flutter

```bash
# Open Terminal (Cmd+Space, type "Terminal")

# Navigate to home directory
cd ~

# Clone Flutter repository
git clone https://github.com/flutter/flutter.git -b stable

# This downloads ~1GB and takes 5-10 minutes
```

### 1.2 Add Flutter to PATH

```bash
# Open your shell profile
nano ~/.zshrc

# Add this line at the bottom:
export PATH="$PATH:$HOME/flutter/bin"

# Save: Ctrl+O, Enter, Ctrl+X

# Reload profile
source ~/.zshrc
```

### 1.3 Verify Installation

```bash
# Check Flutter version
flutter --version

# Expected output:
# Flutter 3.19.0 • channel stable • https://github.com/flutter/flutter.git
# Framework • revision ...
# Engine • revision ...
# Tools • Dart 3.3.0 • DevTools 2.31.0

# Run Flutter doctor
flutter doctor
```

**Expected Output:**
```
[✓] Flutter (Channel stable, 3.19.0, on macOS ...)
[!] Android toolchain - develop for Android devices
    ✗ Android SDK not found
[!] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
```

The warnings are expected - we'll fix them in Step 2.

---

## Step 2: Install Android Studio

### 2.1 Download & Install

1. Go to: https://developer.android.com/studio
2. Click "Download Android Studio"
3. Open the downloaded `.dmg` file
4. Drag Android Studio to Applications
5. Open Android Studio from Applications

### 2.2 First Launch Setup

1. Open Android Studio
2. Choose "Do not import settings" → OK
3. Select "Standard" installation type
4. Choose your UI theme (Darcula recommended)
5. **Important:** When SDK components screen appears, let it download everything
6. Click "Finish" and wait (10-15 minutes)

### 2.3 Install NDK (Critical)

1. In Android Studio, click **Tools → SDK Manager**
2. Click **SDK Tools** tab
3. Check ☑️ **NDK (Side by side)** version 26.1.10909125
4. Check ☑️ **CMake** version 3.22.1
5. Check ☑️ **Android SDK Command-line Tools**
6. Click **Apply** → **OK**
7. Wait for download (10-15 minutes)

### 2.4 Accept Licenses

```bash
# In Terminal
flutter doctor --android-licenses

# Type 'y' for each prompt (press Enter multiple times)
```

### 2.5 Verify Android Setup

```bash
flutter doctor

# Should now show:
[✓] Android toolchain - develop for Android devices (Android SDK 34.0.0)
```

---

## Step 3: Install Python & Tools

### 3.1 Install Homebrew (if not installed)

```bash
# Check if Homebrew is installed
brew --version

# If not installed, run:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3.2 Install Python

```bash
# Install Python 3.10
brew install python@3.10

# Verify
python3 --version
# Python 3.10.x
```

### 3.3 Install HuggingFace CLI

```bash
# Install huggingface-hub
pip3 install huggingface-hub

# Verify
huggingface-cli --version
```

### 3.4 Install CMake

```bash
# Install CMake
brew install cmake

# Verify
cmake --version
# cmake version 3.28.x
```

---

## Step 4: Clone Repository

### 4.1 Set Up SSH Key (for GitHub)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Press Enter for default location
# Press Enter twice for no passphrase

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub | pbcopy
```

### 4.2 Add Key to GitHub

1. Go to: https://github.com/settings/keys
2. Click **New SSH key**
3. Title: "MacBook Pro"
4. Paste the key (already copied)
5. Click **Add SSH key**

### 4.3 Clone the Repository

```bash
# Navigate to where you want the project
cd ~/Documents  # or Desktop, etc.

# Clone repository
git clone git@github.com:Raman21676/expert.git

# Navigate to project
cd expert/lingo_native_ai

# Get dependencies
flutter pub get

# This downloads packages and takes 5-10 minutes
```

---

## Step 5: Download AI Model

### 5.1 Create Models Directory

```bash
# In the project directory
mkdir -p assets/models
```

### 5.2 Download Qwen Model (320MB)

```bash
# Download the model
huggingface-cli download \
  Qwen/Qwen2.5-1.5B-Instruct-GGUF \
  qwen2.5-1.5b-instruct-q4_k_m.gguf \
  --local-dir assets/models

# This takes 5-10 minutes depending on internet speed
```

### 5.3 Verify Download

```bash
# Check file exists
ls -lh assets/models/

# Expected output:
# qwen2.5-1.5b-instruct-q4_k_m.gguf    320M

# Verify file size is around 320MB
```

**Alternative: Manual Download**
If CLI fails:
1. Go to: https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF
2. Find file: `qwen2.5-1.5b-instruct-q4_k_m.gguf`
3. Click download icon
4. Move file to: `assets/models/`

---

## Step 6: Build Native Libraries (llama.cpp)

### 6.1 Create Build Script

```bash
# Navigate to scripts directory
cd scripts

# Create build script
cat > build_llama_cpp_android.sh << 'EOF'
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building llama.cpp for Android...${NC}"

# Check for Android NDK
if [ -z "$ANDROID_HOME" ]; then
    ANDROID_HOME=$HOME/Library/Android/sdk
fi

NDK_VERSION="26.1.10909125"
ANDROID_NDK="$ANDROID_HOME/ndk/$NDK_VERSION"

if [ ! -d "$ANDROID_NDK" ]; then
    echo -e "${RED}ERROR: Android NDK not found at $ANDROID_NDK${NC}"
    echo "Please install NDK version $NDK_VERSION in Android Studio"
    exit 1
fi

echo -e "${GREEN}✓ Found Android NDK at $ANDROID_NDK${NC}"

# Clone llama.cpp if not exists
if [ ! -d "llama.cpp" ]; then
    echo -e "${YELLOW}Cloning llama.cpp...${NC}"
    git clone https://github.com/ggerganov/llama.cpp.git
fi

cd llama.cpp
git pull  # Update to latest

# Build directories
BUILD_DIR_ARM64="build-android-arm64"
BUILD_DIR_ARMV7="build-android-armv7"

# Build for ARM64
echo -e "${YELLOW}Building for ARM64...${NC}"
mkdir -p $BUILD_DIR_ARM64
cd $BUILD_DIR_ARM64

cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-24 \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    ..

make -j4

if [ ! -f "libllama.so" ]; then
    echo -e "${RED}ERROR: ARM64 build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ ARM64 build successful${NC}"
cd ..

# Build for ARMv7
echo -e "${YELLOW}Building for ARMv7...${NC}"
mkdir -p $BUILD_DIR_ARMV7
cd $BUILD_DIR_ARMV7

cmake \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=armeabi-v7a \
    -DANDROID_PLATFORM=android-24 \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_SERVER=OFF \
    -DLLAMA_BUILD_TESTS=OFF \
    ..

make -j4

if [ ! -f "libllama.so" ]; then
    echo -e "${RED}ERROR: ARMv7 build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ ARMv7 build successful${NC}"
cd ../..

# Copy libraries to Flutter project
echo -e "${YELLOW}Copying libraries to project...${NC}"

JNI_LIBS_DIR="../android/app/src/main/jniLibs"
mkdir -p $JNI_LIBS_DIR/arm64-v8a
mkdir -p $JNI_LIBS_DIR/armeabi-v7a

cp llama.cpp/$BUILD_DIR_ARM64/libllama.so $JNI_LIBS_DIR/arm64-v8a/
cp llama.cpp/$BUILD_DIR_ARMV7/libllama.so $JNI_LIBS_DIR/armeabi-v7a/

echo -e "${GREEN}✓ Libraries copied successfully!${NC}"
echo -e "${GREEN}✓ ARM64: $JNI_LIBS_DIR/arm64-v8a/libllama.so${NC}"
echo -e "${GREEN}✓ ARMv7: $JNI_LIBS_DIR/armmeabi-v7a/libllama.so${NC}"

echo -e "${GREEN}Build complete! 🎉${NC}"
EOF

# Make script executable
chmod +x build_llama_cpp_android.sh
```

### 6.2 Run Build Script

```bash
# Run the build script
./build_llama_cpp_android.sh

# This takes 20-30 minutes on first run
# Subsequent runs are faster (5 minutes)
```

**What happens:**
1. Downloads llama.cpp source (~100MB)
2. Compiles for ARM64 (15 min)
3. Compiles for ARMv7 (15 min)
4. Copies .so files to correct location

### 6.3 Verify Libraries

```bash
# Check libraries exist
ls -la ../android/app/src/main/jniLibs/arm64-v8a/
ls -la ../android/app/src/main/jniLibs/armeabi-v7a/

# Should show: libllama.so in both directories
```

---

## Step 7: Configure Android Device

### 7.1 Enable Developer Options

1. Open **Settings** on your Android phone
2. Scroll down to **About phone**
3. Tap **Build number** 7 times
4. Enter your PIN/password
5. "You are now a developer!" message appears

### 7.2 Enable USB Debugging

1. Go to **Settings → System → Developer options**
2. Turn ON ☑️ **USB debugging**
3. Turn ON ☑️ **Stay awake** (optional, helpful for development)

### 7.3 Connect Device to Mac

1. Connect phone to Mac with USB cable
2. On phone, tap "Allow USB debugging?" → **Allow**
3. Select "File transfer" or "MTP" mode (not charging only)

### 7.4 Verify Connection

```bash
# In Terminal
cd ~/Documents/expert/lingo_native_ai  # or your path

# List connected devices
flutter devices

# Expected output:
# 1 connected device:
# SM G973F (mobile) • RF8M... • android-arm64 • Android 12 (API 31)
```

If device doesn't appear:
- Try different USB cable
- Try different USB port
- Restart ADB: `adb kill-server && adb start-server`

---

## Step 8: Run the App

### 8.1 Build and Run

```bash
# Make sure you're in the project directory
cd ~/Documents/expert/lingo_native_ai

# Run the app
flutter run

# Or run in release mode (faster, but longer build)
flutter run --release
```

### 8.2 First Launch

1. App will show splash screen
2. Navigate through onboarding:
   - Welcome screen
   - Select native language
   - Select target language
   - Select proficiency level
   - Enter your name
3. Chat screen opens
4. AI model loads (first time: 10-20 seconds)
5. Type a message and test!

### 8.3 Hot Reload During Development

While app is running:
- Press `r` in terminal → Hot reload (fast)
- Press `R` in terminal → Hot restart (full reload)
- Press `q` → Quit

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] `flutter doctor` shows all checks passed
- [ ] App launches without crash
- [ ] Onboarding screens work
- [ ] Language selection saves
- [ ] Profile creation works
- [ ] Chat interface displays
- [ ] AI responds to messages (once model works)
- [ ] Chat history persists after restart

---

## 🐛 Troubleshooting

### Issue: "Android SDK not found"

```bash
# Set ANDROID_HOME
export ANDROID_HOME=$HOME/Library/Android/sdk

# Add to ~/.zshrc to make permanent
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
source ~/.zshrc
```

### Issue: "NDK not found"

1. Open Android Studio
2. Tools → SDK Manager → SDK Tools
3. Install NDK (Side by side) 26.1.10909125
4. Retry build

### Issue: "CMake not found"

```bash
brew install cmake
```

### Issue: "Model file not found"

```bash
# Verify file exists
ls -la assets/models/

# If missing, re-download:
huggingface-cli download Qwen/Qwen2.5-1.5B-Instruct-GGUF qwen2.5-1.5b-instruct-q4_k_m.gguf --local-dir assets/models
```

### Issue: "Native library not found"

```bash
# Rebuild native libraries
cd scripts
./build_llama_cpp_android.sh
```

### Issue: "Out of memory" during inference

Edit `lib/services/llm/enhanced_llm_service.dart`:
```dart
static const int contextSize = 1024; // Reduce from 2048
```

---

## 🎉 Success!

You now have:
- ✅ Flutter development environment
- ✅ Android Studio with NDK
- ✅ AI model downloaded
- ✅ Native libraries built
- ✅ App running on device

**Next Steps:**
- Read `DEVELOPER_GUIDE.md` for daily workflow
- Read `PROJECT_DOCUMENTATION.md` for architecture
- Start developing features!

---

**Questions?** Check `TROUBLESHOOTING.md` or file an issue on GitHub.
