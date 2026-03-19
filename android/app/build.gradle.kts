import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔥 1. ЗАГРУЗКА КЛЮЧЕЙ ИЗ ФАЙЛА key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.midas.fastable"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Включаем desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.midas.fastable"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ✅ вместо resConfigs(...)
        androidResources {
            localeFilters += listOf("en", "ru", "es", "pt")
        }

        // Включаем MultiDex
        multiDexEnabled = true
    }

    // 🔥 2. НАСТРОЙКА КОНФИГУРАЦИИ ПОДПИСИ
    signingConfigs {
        create("release") {
            // Читаем данные из key.properties
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
    }

    buildTypes {
        release {
            // 🔥 3. ПРИМЕНЯЕМ РЕЛИЗНУЮ ПОДПИСЬ
            signingConfig = signingConfigs.getByName("release")

            // 🔥 4. ВКЛЮЧАЕМ ОБФУСКАЦИЮ И СЖАТИЕ
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// ✅ современный способ вместо kotlinOptions.jvmTarget
kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}

dependencies {
    // Добавляем зависимость для desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
