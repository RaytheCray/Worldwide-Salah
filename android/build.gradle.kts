// Top-level Gradle build file for your Flutter Android project (Kotlin DSL)

import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Use Kotlin 2.0+ (fully compatible with Java 21)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.0")
        // Android Gradle Plugin compatible with Gradle 8 and Java 21
        classpath("com.android.tools.build:gradle:8.5.2")
    }
}

// Repositories used by all subprojects
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define shared build directory
rootProject.buildDir = file("../build")

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// Clean task for the entire project
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

// --- 🔧 Force all subprojects (plugins, libraries, etc.) to use Java 21 ---
subprojects {
    afterEvaluate {
        // Apply Java 21 compile options globally
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_21
                targetCompatibility = JavaVersion.VERSION_21
            }
        }

        // Apply Kotlin JVM target 21 globally
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "21"
            }
        }
    }
}
