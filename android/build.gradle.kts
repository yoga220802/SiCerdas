// File build.gradle.kts untuk level project Android (android/build.gradle.kts)
// File ini mengatur konfigurasi build untuk keseluruhan project Android,
// termasuk mendaftarkan plugin dan repository yang akan digunakan oleh semua modul.

buildscript {
    // UPDATE VERSI KOTLIN DI SINI
    // Library Firebase membutuhkan metadata Kotlin versi 2.1.0,
    // sementara projectmu mengharapkan 1.8.0. Kita naikkan versi Kotlin.
    // Coba dengan 1.9.23 dulu. Jika masih error, kita bisa coba versi yang lebih tinggi
    // yang kompatibel dengan metadata 2.1.0 (misalnya Kotlin 2.0.0 atau 2.1.0 jika sudah stabil
    // dan didukung oleh versi Flutter-mu).
    val kotlinVersion = "2.1.21" // <--- VERSI KOTLIN DIPERBARUI

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0") 
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion") 
        classpath("com.google.gms:google-services:4.4.1") 
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
