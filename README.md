# IconHUD-Android

iOS version is here.  
https://github.com/Tueno/IconHUD/

*This is alpha version, so There is a possibility of containing some bugs.*

<p align="center">
<img src="sample/iconhud_sample.png" alt="iconhud_sample"/>
<img src="sample/screen_sample.png" alt="screen_sample" width="400"/>
</p>

## Features

* IconHUD places information of your app on icon. (version, branch, commit ID, build date, build flavor etc...)
* It does NOT process icon image file in your project's asset.
* It does NOT work on release build. (If BuildType name is "Release".)

## Installation
```
brew tap tueno/iconhud-android
brew install iconhud-android
```

## Usage

Add the script below to build.gradle(app).  
```
// iconhud
task iconhud {
    doLast {
        def path   = '/usr/local/bin/iconhud-android'
        def binary = new File(path)
        android.applicationVariants.all { variant ->
            variant.outputs.each { output ->
                exec {
                    if (binary.exists()) {
                        executable path
                        args "--build-type-name", variant.buildType.name, "--build-flavor-name", variant.flavorName, "--output-path", output.outputFile
                        ignoreExitValue true
                    }
                }
            }
        }
    }
}
gradle.buildFinished { result ->
    // You can add exclusion rule here.
    if (!result.failure
            && !project.gradle.startParameter.taskNames.contains("test")
            && !project.gradle.startParameter.taskNames.contains("ktlint")
            && !project.gradle.startParameter.taskNames.contains("dependencies")) {
        iconhud.execute()
    }
}
```

## Notice

* If you don't need to process icon on debug build, use `--ignore-debug-build` option.
