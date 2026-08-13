plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cvgenerator"
    compileSdk = flutter.compileSdkVersion

    // `ndkVersion` n'est pas déclaré ici, mais cela ne dispense PAS d'installer
    // le NDK : le plugin Gradle de Flutter impose sa propre valeur par défaut
    // (28.2.13676358, définie dans FlutterExtension.kt du SDK). Le plugin
    // Android Gradle valide alors cette version et tente de la télécharger.
    //
    // Le NDK doit donc être installé, même sans code natif dans le projet :
    //   SDK Manager → SDK Tools → NDK (Side by side) → 28.2.13676358
    //
    // Pour épingler une autre version déjà présente sur la machine, ajouter
    // ici `ndkVersion = "<version installée>"` : la déclaration explicite prend
    // le pas sur le défaut de Flutter.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.cvgenerator"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
