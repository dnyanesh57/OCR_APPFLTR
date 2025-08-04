buildscript {
    val kotlin_version by extra("1.9.20") // Ensure this matches your project's Kotlin version
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0") // Or your project's AGP version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // This line tells Gradle where to find the google-services plugin
        classpath("com.google.gms:google-services:4.4.2") 
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File("../build")
subprojects {
    project.buildDir = File("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
