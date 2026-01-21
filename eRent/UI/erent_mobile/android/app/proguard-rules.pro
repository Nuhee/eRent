# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Stripe specific rules
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$g { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error { *; }

# Additional Stripe classes that might be missing
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider** { *; }

# Google Play Core classes
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep custom application class
-keep public class * extends android.app.Application

# Keep Activity classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class * extends android.app.Fragment

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep generic signatures
-keepattributes Signature

# Keep source file names
-keepattributes SourceFile

# Keep line numbers
-keepattributes LineNumberTable

# Keep annotations
-keepattributes *Annotation*

# Keep exceptions
-keepattributes Exceptions

# Keep inner classes
-keepattributes InnerClasses

# Keep synthetic methods
-keepattributes Synthetic

# Keep bridge methods
-keepattributes BridgeMethods

# Keep method parameters
-keepattributes MethodParameters

# Keep native method names
-keepattributes Native

# Keep generic signatures
-keepattributes Signature

# Keep source file names
-keepattributes SourceFile

# Keep line numbers
-keepattributes LineNumberTable

# Keep annotations
-keepattributes *Annotation*

# Keep exceptions
-keepattributes Exceptions

# Keep inner classes
-keepattributes InnerClasses

# Keep synthetic methods
-keepattributes Synthetic

# Keep bridge methods
-keepattributes BridgeMethods

# Keep method parameters
-keepattributes MethodParameters

# Keep native method names
-keepattributes Native
