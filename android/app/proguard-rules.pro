# Flutter et Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Conserve les noms des classes (utile pour les erreurs Firebase, Retrofit...)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# Evite d’obfusquer les classes liées à Firebase Messaging, si tu l’utilises
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Pour Gson (si utilisé)
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*
# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task