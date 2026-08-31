plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.navtrip_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.navtrip_ai"
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

val envFile = File(projectDir, "../../.env")
val envMap = mutableMapOf<String, String>()
if (envFile.exists()) {
    envFile.forEachLine { rawLine ->
        val line = rawLine.trim()
        if (line.isNotEmpty() && !line.startsWith("#") && line.contains("=")) {
            val parts = line.split("=", limit = 2)
            envMap[parts[0].trim()] = parts[1].trim()
        }
    }
}

val generateGoogleServicesJson = tasks.register("generateGoogleServicesJson") {
    val targetFile = File(projectDir, "google-services.json")
    outputs.file(targetFile)

    doLast {
        val apiKey = envMap["FIREBASE_ANDROID_API_KEY"]
            ?: System.getenv("FIREBASE_ANDROID_API_KEY")
            ?: envMap["FIREBASE_API_KEY"]
            ?: System.getenv("FIREBASE_API_KEY")
            ?: ""
        val appId = envMap["FIREBASE_ANDROID_APP_ID"]
            ?: System.getenv("FIREBASE_ANDROID_APP_ID")
            ?: envMap["FIREBASE_APP_ID"]
            ?: System.getenv("FIREBASE_APP_ID")
            ?: "1:776147368178:android:7f4547a9090cbc8e2f786b"
        val projectNumber = envMap["FIREBASE_MESSAGING_SENDER_ID"]
            ?: System.getenv("FIREBASE_MESSAGING_SENDER_ID")
            ?: "776147368178"
        val projectId = envMap["FIREBASE_PROJECT_ID"]
            ?: System.getenv("FIREBASE_PROJECT_ID")
            ?: "navtrip-ai"
        val storageBucket = envMap["FIREBASE_STORAGE_BUCKET"]
            ?: System.getenv("FIREBASE_STORAGE_BUCKET")
            ?: "navtrip-ai.firebasestorage.app"
        val clientId = envMap["FIREBASE_ANDROID_CLIENT_ID"]
            ?: System.getenv("FIREBASE_ANDROID_CLIENT_ID")
            ?: ""

        if (apiKey.isNotEmpty()) {
            val content = """{
  "project_info": {
    "project_number": "$projectNumber",
    "project_id": "$projectId",
    "storage_bucket": "$storageBucket"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "$appId",
        "android_client_info": {
          "package_name": "com.example.navtrip_ai"
        }
      },
      "oauth_client": [
        {
          "client_id": "$clientId",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "$apiKey"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
"""
            targetFile.writeText(content)
            logger.lifecycle("Generated google-services.json from environment variables.")
        }
    }
}

tasks.matching { it.name.startsWith("process") && it.name.endsWith("GoogleServices") }.configureEach {
    dependsOn(generateGoogleServicesJson)
}
tasks.named("preBuild").configure {
    dependsOn(generateGoogleServicesJson)
}
