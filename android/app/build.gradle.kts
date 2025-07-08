plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "site.xxsy.match"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "site.xxsy.match"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

         // 添加 NDK 配置（必须）
        ndk {
            abiFilters.add("armeabi-v7a")
            abiFilters.add("arm64-v8a")
        }

        // 解决 64k 方法数限制（如需）
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

     // 解决依赖冲突（如有需要）
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core-ktx:1.12.0")
            force("com.squareup.okhttp3:okhttp:4.12.0") // 使用腾讯云 SDK 兼容的版本
        }
    }
}

// 添加到项目级 build.gradle.kts 的 repositories
repositories {
    google()
    mavenCentral()
    // 添加腾讯云仓库
    maven { 
        url = uri("https://mirrors.tencent.com/nexus/repository/maven-public/") 
    }
}

dependencies {

    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar", "*.aar"))))
    
    // 腾讯云人脸核身 SDK 依赖
    implementation(files("libs/WbCloudFaceLiveSdk-face-v6.6.2-8e4718fc.aar"))
    implementation(files("libs/WbCloudNormal-v5.1.10-4e3e198.aar"))
    implementation("androidx.recyclerview:recyclerview:1.1.0")
    implementation("androidx.legacy:legacy-support-v4:1.0.0")
    implementation("androidx.appcompat:appcompat:1.1.0")
    implementation("com.alibaba:fastjson:1.2.83")
    implementation("com.facebook.fresco:fresco:2.5.0")
    implementation("com.facebook.fresco:animated-gif:2.5.0")
    implementation("com.github.bumptech.glide:glide:4.9.0")
    implementation("androidx.webkit:webkit:1.5.0")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.google.code.gson:gson:2.8.9")
    implementation("com.android.support:appcompat-v7:23.0.1")
}

flutter {
    source = "../.."
}
