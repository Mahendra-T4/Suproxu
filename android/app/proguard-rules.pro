# Flutter/Dart/Kotlin classes
-keep class ** { *; }
-keepclassmembers class ** { *; }

# Keep model classes
-keep class com.example.suproxu.** { *; }
-keepclassmembers class com.example.suproxu.** { *; }

# Keep Dio classes
-keep class io.flutter.** { *; }
-keepclassmembers class io.flutter.** { *; }

# Keep JSON serialization
-keepclassmembers class * {
  *** fromJson(...);
  *** toJson(...);
}

# Keep all Dart/Flutter reflection
-keep class dart.** { *; }
-keepclassmembers class dart.** { *; }

# Allow missing classes (optional dependencies)
-dontwarn com.google.android.play.core.**
-dontnote com.google.android.play.core.**

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Suppress warnings about unresolved references
-ignorewarnings

