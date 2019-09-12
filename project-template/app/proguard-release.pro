
-printseeds build/outputs/mapping/proguard-seeds.log
-dontobfuscate
# Android Specific
-assumenosideeffects class android.util.Log {
  public static *** v(...);
}
