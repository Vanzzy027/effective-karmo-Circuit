plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}



android {
    namespace = "com.example.karmo"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Change from 8 to 17
        targetCompatibility = JavaVersion.VERSION_17  // Change from 8 to 17
    }

    kotlinOptions {
        jvmTarget = "17"  // Change from "1.8" to "17"
    }

    defaultConfig {
        applicationId = "com.example.karmo"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
