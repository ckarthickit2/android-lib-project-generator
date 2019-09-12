# Proguard Steps
# Shrink -> Optimize -> Obfuscate -> PreVerify
# First 3 stages need Entry Points to be defined via -keep option

# Entry Points

-keep public interface * {*;}
-keep public enum * {*;}
-keep public abstract class * {*;}
-keep !class **.internal.** {*;}
#-keep !public class **.internal.**$Companion {*;}
-keep public class **$Companion {*;}
-keep public class **$DefaultImpls {*;}
-keep public class * extends **Throwable {*;}

-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod
#-keeppackagenames com.att.nexgen
-printseeds build/outputs/mapping/proguard-seeds.log
# Android Specific
-assumenosideeffects class android.util.Log {
  public static *** v(...);
}
