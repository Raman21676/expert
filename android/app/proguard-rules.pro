# ProGuard rules for LingoNative AI

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.lingonative.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep SQLite classes
-keep class android.database.sqlite.** { *; }

# Keep FFI classes
-keep class dart.ffi.** { *; }

# Keep model classes
-keep class com.lingonative.lingo_native_ai.** { *; }

# Fix for Play Core missing classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
