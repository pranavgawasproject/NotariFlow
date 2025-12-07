# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep optional ML Kit text recognition language models
# These are optional dependencies that may not be included
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# If you only need Latin script, you can ignore the warnings for other scripts
-keep class com.google.mlkit.vision.text.latin.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Firestore classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
