# Godot JNI and Android activity
-keep class org.godotengine.** { *; }
-keep class com.godot.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}

# AdMob, Play services, and the Poing Godot bridge
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.ump.** { *; }
-keep class com.poingstudios.** { *; }
-keep class com.poing.** { *; }

-dontwarn com.google.android.gms.**
-dontwarn com.google.android.ump.**
-dontwarn org.godotengine.**
