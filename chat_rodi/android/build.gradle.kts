allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // Register before evaluationDependsOn can eagerly evaluate :app and its plugin projects.
    // The library's own build script may set an older compileSdk, so override it after its
    // Android extension has been configured.
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.compileSdk = 36
    }

    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
