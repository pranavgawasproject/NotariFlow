# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ML Kit - Suppress warnings for optional language dependencies
# These classes are referenced by the plugin but not included in the app
# unless you explicitly add the dependencies.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep the main ML Kit text recognition classes that ARE present
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# General ML Kit
-keep class com.google.mlkit.common.** { *; }
-dontwarn com.google.mlkit.common.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firestore
-keep class com.google.cloud.firestore.** { *; }
-dontwarn com.google.cloud.firestore.**
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**

# General Android
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
