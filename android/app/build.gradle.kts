// File build.gradle.kts untuk modul aplikasi (android/app/build.gradle.kts)
// File ini mengatur konfigurasi build spesifik untuk modul aplikasi Flutter-mu.

plugins {
    id("com.android.application") 
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_sicerdas" // GANTI DENGAN NAMESPACE PROYEKMU
    compileSdk = flutter.compileSdkVersion
    
    // SOLUSI MASALAH NDK: Update ndkVersion ke yang dibutuhkan plugin
    ndkVersion = "27.0.12077973" // Sebelumnya flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.project_sicerdas" // GANTI DENGAN APPLICATION ID PROYEKMU
        
        // SOLUSI MASALAH minSdkVersion: Naikkan minSdk ke 23
        minSdk = 23 // Sebelumnya flutter.minSdkVersion
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.." 
}

dependencies {
    implementation(kotlin("stdlib"))

    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // Pastikan versi BoM stabil & terbaru

    implementation("com.google.firebase:firebase-auth-ktx") 
    implementation("com.google.firebase:firebase-database-ktx") 
    implementation("com.google.firebase:firebase-analytics-ktx") 

    // implementation("androidx.multidex:multidex:2.0.1") // Biasanya tidak perlu jika minSdk sudah 21+
}

apply(plugin = "com.google.gms.google-services")
