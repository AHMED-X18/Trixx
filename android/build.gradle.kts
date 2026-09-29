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
// Older plugins (e.g. isar_flutter_libs 3.1.0) don't declare a namespace and
// target an outdated compileSdk, which recent AGP versions reject.
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
            ?: return@afterEvaluate
        if (android.namespace == null) {
            android.namespace = project.group.toString()
        }
        android.compileSdk = 36
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
