# LingoNative AI - Model Selection Guide

> **Last Updated:** February 10, 2026  
> **Purpose:** Help choose the best LLM for your mobile app

---

## 🎯 Quick Recommendation

### For Most Users: **SmolLM2-360M-Instruct-Q4_K_M**
- **Size:** 258 MB ✅
- **Speed:** Fast on mid-range phones
- **Quality:** Good for language tutoring
- **Languages:** English + major European languages
- **APK Size:** ~310 MB total

### For Low-End Devices: **SmolLM2-135M-Instruct-Q4_K_M**
- **Size:** 100 MB ✅
- **Speed:** Very fast on all devices
- **Quality:** Adequate for basic conversations
- **Best for:** Simple vocabulary, basic phrases
- **APK Size:** ~150 MB total

---

## 📊 Model Comparison

| Model | Size | Params | Speed | Quality | Languages | APK Est. |
|-------|------|--------|-------|---------|-----------|----------|
| **SmolLM2-360M** | 258 MB | 360M | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | EN, FR, DE, ES, IT | ~310 MB |
| **SmolLM2-135M** | 100 MB | 135M | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | EN (best), others basic | ~150 MB |
| Qwen2.5-0.5B | 468 MB | 500M | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 29 languages | ~520 MB |
| ~~Qwen2.5-1.5B~~ | ~~1.0 GB~~ | ~~1.5B~~ | ~~⭐⭐~~ | ~~⭐⭐⭐⭐⭐~~ | ~~29 languages~~ | ~~Too large~~ |

---

## 🥇 SmolLM2-360M (RECOMMENDED)

### Pros
- ✅ Perfect size (258 MB < 300MB target)
- ✅ Fast inference (5-10 tokens/sec on mid-range)
- ✅ Apache 2.0 license (Play Store OK)
- ✅ Instruction-tuned for conversations
- ✅ Good for language tutoring scenarios

### Cons
- ⚠️ Primarily English-focused
- ⚠️ Limited non-European language support
- ⚠️ May struggle with complex grammar explanations

### Best For
- English → French/Spanish/German learning
- Basic vocabulary tutoring
- Simple conversation practice
- Mid-range Android devices (4GB+ RAM)

### Download
```bash
huggingface-cli download bartowski/SmolLM2-360M-Instruct-GGUF \
  SmolLM2-360M-Instruct-Q4_K_M.gguf \
  --local-dir assets/models
```

---

## 🥈 SmolLM2-135M (Ultra-Light)

### Pros
- ✅ Extremely small (100 MB)
- ✅ Very fast (15+ tokens/sec)
- ✅ Runs on low-end devices (2GB RAM)
- ✅ Tiny APK size (~150 MB)

### Cons
- ⚠️ Limited capabilities
- ⚠️ Best for English only
- ⚠️ Struggles with complex queries
- ⚠️ Shorter context window

### Best For
- Low-end Android devices
- Basic vocabulary flashcards
- Simple Q&A
- First-time app users

### Download
```bash
huggingface-cli download bartowski/SmolLM2-135M-Instruct-GGUF \
  SmolLM2-135M-Instruct-Q4_K_M.gguf \
  --local-dir assets/models
```

---

## 🥉 Qwen2.5-0.5B (Multilingual)

### Pros
- ✅ 29+ languages supported
- ✅ Same architecture as larger Qwen
- ✅ Excellent for Hindi, Arabic, Chinese, etc.
- ✅ Apache 2.0 license

### Cons
- ⚠️ Larger size (468 MB)
- ⚠️ APK will be ~520 MB
- ⚠️ Slower on older devices
- ⚠️ More memory usage

### Best For
- Apps targeting non-European languages
- Hindi, Arabic, Chinese, Japanese, Korean
- When size is less important than language coverage

### Download
```bash
huggingface-cli download Qwen/Qwen2.5-0.5B-Instruct-GGUF \
  qwen2.5-0.5b-instruct-q4_k_m.gguf \
  --local-dir assets/models
```

---

## 🔧 How to Switch Models

### 1. Download Your Chosen Model

```bash
cd lingo_native_ai/assets/models

# Option 1: SmolLM2-360M (Recommended)
huggingface-cli download bartowski/SmolLM2-360M-Instruct-GGUF \
  SmolLM2-360M-Instruct-Q4_K_M.gguf --local-dir .

# Option 2: SmolLM2-135M (Ultra-light)
huggingface-cli download bartowski/SmolLM2-135M-Instruct-GGUF \
  SmolLM2-135M-Instruct-Q4_K_M.gguf --local-dir .

# Option 3: Qwen2.5-0.5B (Multilingual)
huggingface-cli download Qwen/Qwen2.5-0.5B-Instruct-GGUF \
  qwen2.5-0.5b-instruct-q4_k_m.gguf --local-dir .
```

### 2. Update Code Configuration

Edit `lib/services/llm/enhanced_llm_service.dart`:

```dart
// For SmolLM2-360M
static const String modelFileName = 'SmolLM2-360M-Instruct-Q4_K_M.gguf';
static const String modelName = 'SmolLM2-360M-Instruct';

// For SmolLM2-135M
// static const String modelFileName = 'SmolLM2-135M-Instruct-Q4_K_M.gguf';
// static const String modelName = 'SmolLM2-135M-Instruct';

// For Qwen2.5-0.5B
// static const String modelFileName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf';
// static const String modelName = 'Qwen2.5-0.5B-Instruct';
```

### 3. Update pubspec.yaml

```yaml
flutter:
  assets:
    - assets/models/SmolLM2-360M-Instruct-Q4_K_M.gguf
    # Remove other model references
```

### 4. Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📱 Device Recommendations

| Device RAM | Recommended Model | Expected Performance |
|------------|-------------------|---------------------|
| 2 GB | SmolLM2-135M | Good (10+ tok/s) |
| 3-4 GB | SmolLM2-360M | Excellent (5-8 tok/s) |
| 6-8 GB | Qwen2.5-0.5B | Good (3-5 tok/s) |
| 8+ GB | Any model | Excellent |

---

## 🌍 Language Support

### SmolLM2 Models
- **Best:** English
- **Good:** French, German, Spanish, Italian
- **Limited:** Other languages

### Qwen2.5 Models
- **Full Support (29+):** 
  - Chinese, English, French, Spanish, Portuguese
  - German, Italian, Russian, Japanese, Korean
  - Arabic, Hindi, Vietnamese, Thai, Indonesian
  - And more...

---

## ⚖️ Trade-offs Summary

| Priority | Choose | Reason |
|----------|--------|--------|
| Smallest APK | SmolLM2-135M | 100 MB model |
| Best balance | SmolLM2-360M | 258 MB, good quality |
| Most languages | Qwen2.5-0.5B | 29 languages |
| Best quality | Qwen2.5-0.5B | More parameters |
| Fastest inference | SmolLM2-135M | Fewest parameters |
| Low-end devices | SmolLM2-135M | Minimal RAM usage |

---

## ✅ Final Recommendation

**Start with SmolLM2-360M-Instruct-Q4_K_M (258 MB)**

This gives you:
- ✅ Under 300MB target
- ✅ Fast enough for good UX
- ✅ Good teaching capabilities
- ✅ Reasonable language coverage
- ✅ Play Store acceptable size (~310 MB APK)

**You can always upgrade later** if you need more languages or better quality!

---

## 📞 Model Issues?

If you experience:
- **Slow responses:** Try SmolLM2-135M
- **Poor quality:** Try Qwen2.5-0.5B
- **Memory crashes:** Reduce context size in code
- **Language issues:** Switch to Qwen2.5 for better multilingual

---

**Document Version:** 1.0  
**Models Tested:** February 10, 2026  
**Recommended:** SmolLM2-360M-Instruct-Q4_K_M
