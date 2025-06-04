plugins {
    id("com.android.application") 
    id("kotlin-android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.project_sicerdas"
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
        applicationId = "com.example.project_sicerdas"
        
        minSdk = 23
        
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

    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    implementation("com.google.firebase:firebase-auth-ktx") 
    implementation("com.google.firebase:firebase-database-ktx") 
    implementation("com.google.firebase:firebase-analytics-ktx") 

    // implementation("androidx.multidex:multidex:2.0.1")
}

apply(plugin = "com.google.gms.google-services")
