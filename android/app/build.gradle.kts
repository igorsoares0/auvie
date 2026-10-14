import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (docs/RELEASE.md): android/key.properties, never committed.
// Without it, release builds stop with a message, unless debug signing is
// asked for explicitly (AUVIE_DEBUG_SIGNING=true or -Pauvie.debugSigning=true)
// to try a release build on a phone.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null
val debugSigning = System.getenv("AUVIE_DEBUG_SIGNING") == "true" ||
    project.findProperty("auvie.debugSigning") == "true"

android {
    namespace = "app.auvie"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "app.auvie"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 10+: MediaStore writes without storage permission, scoped
        // storage and GL ES 3 everywhere (see docs/PLANO-IMPLEMENTACAO-ANDROID.md).
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    sourceSets {
        // DevelopReference (CPU oracle of develop.frag) and the shared vectors
        // are used by both JVM and on-device tests.
        getByName("test").java.directories.add("src/sharedTest/kotlin")
        getByName("androidTest") {
            java.directories.add("src/sharedTest/kotlin")
            assets.directories.add("../../test_fixtures")
        }
    }

    testOptions {
        unitTests.all {
            it.systemProperty("fixtures.dir", rootProject.file("../test_fixtures").absolutePath)
        }
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasReleaseKey -> signingConfigs.getByName("release")
                debugSigning -> signingConfigs.getByName("debug")
                else -> null
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// A release that would go out unsigned (or debug-signed by accident) stops here.
tasks.matching { it.name == "packageRelease" || it.name == "signReleaseBundle" }.configureEach {
    doFirst {
        if (!hasReleaseKey && !debugSigning) {
            throw GradleException(
                "No release key: create android/key.properties (docs/RELEASE.md), " +
                    "or set AUVIE_DEBUG_SIGNING=true to try a release build on a phone.",
            )
        }
    }
}

// integration_test (the on-device perf test) pulls an old AndroidX Test
// runner into the debug app; keep the one our instrumented tests use.
configurations.configureEach {
    resolutionStrategy.force(
        "androidx.test:runner:${libs.versions.androidxTestRunner.get()}",
    )
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(libs.androidx.activity.ktx)
    implementation(libs.androidx.exifinterface)
    implementation(libs.kotlinx.coroutines.android)
    implementation(libs.media3.common)
    implementation(libs.media3.effect)
    implementation(libs.media3.exoplayer)
    implementation(libs.media3.transformer)
    implementation(libs.androidx.work.runtime.ktx)

    testImplementation(libs.junit)
    testImplementation(libs.truth)
    testImplementation(libs.org.json)

    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.truth)
    androidTestImplementation(libs.androidx.work.testing)
}
