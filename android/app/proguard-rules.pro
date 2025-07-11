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
