# Keep Google Play Services classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Phenotype related classes (fixes Phenotype.API issues)
-keep class com.google.android.gms.phenotype.** { *; }
-keep class com.google.android.gms.phenotype.Phenotype { *; }
-keep class com.google.android.gms.phenotype.Phenotype$* { *; }
-keepclassmembers class com.google.android.gms.phenotype.** { *; }

# Keep SecurityException related classes
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.internal.phenotype.** { *; }
-keepclassmembers class com.google.android.gms.internal.phenotype.** { *; }

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent proguard from stripping interface information from Firebase classes
-keep public class com.google.firebase.** {
  public *;
}

# Keep the classes used by reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
