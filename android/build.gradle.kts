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
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid: (Project) -> Unit = { proj ->
        val android = proj.extensions.findByName("android")
        if (android != null) {
            var success = false
            try {
                val method = android::class.java.getMethod("compileSdkVersion", java.lang.Integer.TYPE)
                method.invoke(android, 36)
                success = true
            } catch (e: Exception) {}
            
            if (!success) {
                try {
                    val method = android::class.java.getMethod("setCompileSdk", java.lang.Integer::class.java)
                    method.invoke(android, 36)
                } catch (e: Exception) {}
            }
        }
    }

    if (project.state.executed) {
        configureAndroid(project)
    } else {
        project.afterEvaluate {
            configureAndroid(project)
        }
    }
}

subprojects {
    tasks.configureEach {
        if (name.startsWith("compile") && name.endsWith("Kotlin")) {
            try {
                val javaCompileTaskName = name.replace("Kotlin", "JavaWithJavac")
                val javaCompileTask = project.tasks.findByName(javaCompileTaskName) as? JavaCompile
                if (javaCompileTask != null) {
                    val targetCompat = javaCompileTask.targetCompatibility.toString()
                    val kotlinOptions = property("kotlinOptions")
                    if (kotlinOptions != null) {
                        val setJvmTarget = kotlinOptions::class.java.getMethod("setJvmTarget", String::class.java)
                        setJvmTarget.invoke(kotlinOptions, targetCompat)
                    }
                }
            } catch (e: Exception) {}
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
