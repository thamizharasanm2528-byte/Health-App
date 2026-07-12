# Flutter Obfuscation & Shrinking Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class org.chromium.** { *; }

# Keep Hive database models and serialization classes
-keep class com.example.health_companion.** { *; }
-keep class * extends io.hive.HiveObject { *; }
-keep class io.hive.** { *; }

# Keep Local Notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep Health Connect classes
-keep class androidx.health.connect.client.** { *; }
-keep class com.google.android.apps.healthdata.** { *; }

# Keep Alarm package service and receiver
-keep class com.gdelataillade.alarm.** { *; }

# Flutter Deferred Components (Play Store split install / Play Core) ignore rules
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn com.google.android.gms.internal.**

