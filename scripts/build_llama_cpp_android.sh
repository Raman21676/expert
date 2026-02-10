#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Building llama.cpp for Android (LingoNative AI)      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for Android NDK
if [ -z "$ANDROID_HOME" ]; then
    ANDROID_HOME=$HOME/Library/Android/sdk
    echo -e "${YELLOW}ANDROID_HOME not set, using default: $ANDROID_HOME${NC}"
fi

# Auto-detect NDK version
NDK_VERSION=$(ls $ANDROID_HOME/ndk/ | head -1)
if [ -z "$NDK_VERSION" ]; then
    echo -e "${RED}ERROR: No Android NDK found!${NC}"
    echo "Please install Android NDK:"
    echo "1. Open Android Studio"
    echo "2. Tools → SDK Manager → SDK Tools"
    echo "3. Check 'NDK (Side by side)'"
    echo "4. Click Apply"
    exit 1
fi

ANDROID_NDK="$ANDROID_HOME/ndk/$NDK_VERSION"

echo -e "${GREEN}✓ Found Android NDK $NDK_VERSION at $ANDROID_NDK${NC}"
echo ""

# Create output directories
JNI_LIBS_DIR="../android/app/src/main/jniLibs"
mkdir -p "$JNI_LIBS_DIR/arm64-v8a"
mkdir -p "$JNI_LIBS_DIR/armeabi-v7a"

# Clone or update llama.cpp
if [ ! -d "llama.cpp" ]; then
    echo -e "${YELLOW}📥 Cloning llama.cpp repository...${NC}"
    git clone https://github.com/ggerganov/llama.cpp.git
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Failed to clone llama.cpp${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}🔄 Updating llama.cpp repository...${NC}"
    cd llama.cpp
    git pull
    cd ..
fi

echo -e "${GREEN}✓ llama.cpp ready${NC}"
echo ""

# Function to build for a specific ABI
build_for_abi() {
    local ABI=$1
    local BUILD_DIR=$2
    
    echo -e "${YELLOW}🔨 Building for $ABI...${NC}"
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM=android-24 \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLAMA_BUILD_SERVER=OFF \
        -DLLAMA_BUILD_TESTS=OFF \
        -DLLAMA_BUILD_EXAMPLES=OFF \
        ..
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: CMake configuration failed for $ABI${NC}"
        cd ../..
        return 1
    fi
    
    # Build with 4 parallel jobs
    make -j4
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Build failed for $ABI${NC}"
        cd ../..
        return 1
    fi
    
    # Copy the library
    if [ -f "libllama.so" ]; then
        cp "libllama.so" "$JNI_LIBS_DIR/$ABI/"
        echo -e "${GREEN}✓ $ABI library built and copied${NC}"
    else
        echo -e "${RED}ERROR: libllama.so not found for $ABI${NC}"
        cd ../..
        return 1
    fi
    
    cd ../..
    return 0
}

# Build for ARM64
cd llama.cpp
build_for_abi "arm64-v8a" "build-android-arm64"
if [ $? -ne 0 ]; then
    echo -e "${RED}ARM64 build failed!${NC}"
    exit 1
fi
echo ""

# Build for ARMv7
build_for_abi "armeabi-v7a" "build-android-armv7"
if [ $? -ne 0 ]; then
    echo -e "${RED}ARMv7 build failed!${NC}"
    exit 1
fi
echo ""

cd ..

# Verify outputs
echo -e "${YELLOW}📋 Verifying outputs...${NC}"
echo ""

if [ -f "$JNI_LIBS_DIR/arm64-v8a/libllama.so" ]; then
    echo -e "${GREEN}✓ ARM64 library: $(ls -lh $JNI_LIBS_DIR/arm64-v8a/libllama.so | awk '{print $5}')${NC}"
else
    echo -e "${RED}✗ ARM64 library missing!${NC}"
    exit 1
fi

if [ -f "$JNI_LIBS_DIR/armeabi-v7a/libllama.so" ]; then
    echo -e "${GREEN}✓ ARMv7 library: $(ls -lh $JNI_LIBS_DIR/armeabi-v7a/libllama.so | awk '{print $5}')${NC}"
else
    echo -e "${RED}✗ ARMv7 library missing!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Build Completed Successfully! 🎉              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Output locations:${NC}"
echo "  • ARM64: $JNI_LIBS_DIR/arm64-v8a/libllama.so"
echo "  • ARMv7: $JNI_LIBS_DIR/armeabi-v7a/libllama.so"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Run app: flutter run"
echo ""
