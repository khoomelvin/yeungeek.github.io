title: eclipse中使用gradle构建android
date: 2014-09-15 17:16:01
tags:
- Eclipse
- Gradle
- Android Stuido
categories:
- Gradle
---

在java构建中，有ant,maven,ant+ivy等等工具，一度以来maven一直是主流，不过冗余的依赖管理配置、复杂并且难以扩展的构建生命周期，非常困扰。  
直到`gradle`的出现，基于groovy的构建工具，既保持了Maven的优点，又通过使用Groovy定义的DSL，克服了 Maven中使用XML繁冗以及不灵活等缺点。  
gradle的使用越来越广泛，尤其是在android的构建上，目前android studio就直接支持gradle，为android的开发者提供了便利。  
不过目前android studio还是beta阶段，使用eclipse的开发者还是相当多，如何让eclipse也支持gradle呢？
#eclipse生成gradle 
使用eclipse adt工具，可以让当前的工程生成对应的gradle文件。
``` java
1. Update your Eclipse ADT Plugin (you must have version 22.0 or higher).
2. In Eclipse, select File > Export.
3. In the window that appears, open Android and select Generate Gradle build files.
```

生成的gradle文件(build.gradle)，一般是这样的，示例的工程为library。
``` gradle
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:0.12.+'
    }
}
 
apply plugin: 'android-library'
 
repositories {
    mavenCentral()
}
 
dependencies {
    compile fileTree(dir: 'libs', include: '*.jar')
}
 
android {
    compileSdkVersion 17
    buildToolsVersion "20.0.0"
 
    defaultConfig {
            applicationId "com.jasmine"
            minSdkVersion 9
            targetSdkVersion 17
    }
     
    buildTypes {
        debug {
            applicationIdSuffix ".debug"
        }
        
    }
 
    lintOptions
            {
                abortOnError false
            }
 
    sourceSets {
        main {
            manifest.srcFile 'AndroidManifest.xml'
            java.srcDirs = ['src']
            resources.srcDirs = ['src']
            aidl.srcDirs = ['src']
            renderscript.srcDirs = ['src']
            res.srcDirs = ['res']
            assets.srcDirs = ['assets']
        }
 
        // Move the tests to tests/java, tests/res, etc...
        instrumentTest.setRoot('tests')
 
        // Move the build types to build-types/<type>
        // For instance, build-types/debug/java, build-types/debug/AndroidManifest.xml, ...
        // This moves them out of them default location under src/<type>/... which would
        // conflict with src/ being used by the main source set.
        // Adding new build types or product flavors should be accompanied
        // by a similar customization.
        debug.setRoot('build-types/debug')
        release.setRoot('build-types/release')
    }
}
```

#eclipse classpath和project生成
要让eclipse支持gradle，其实就是能够解决依赖的问题，可以通过修改.classpath和.project来解决。

##增加gradle插件
`apply plugin: 'maven'` 解析一些依赖  
`apply plugin: 'eclipse'` 可以编译eclipse工程  

##build.gradle增加classpath和project支持
``` gradle
////////////////////// configure eclipse //////////////////////
eclipse.classpath.plusConfigurations += configurations.compile
//.classpath
eclipse.classpath.file {
    beforeMerged { classpath ->
        classpath.entries.removeAll() { c ->
            c.kind == 'src'
        }
    }
    // Direct manipulation of the generated classpath XML
    withXml {
        def node = it.asNode()
        // Main source
        node.appendNode('classpathentry kind="src" path="src"')
        // test build type source directory
//        node.appendNode('classpathentry kind="src" path="src/test/java"')
        // Generated code directory
        node.appendNode('classpathentry kind="src" path="gen"')
        // Filter out dependencies unwanted for Eclipse
        node.children().removeAll() { c ->
            def path = c.attribute('path')
            path != null && (
                    path.contains('/com.android.support/support-v4')
            )
        }
    }
}
//.project
eclipse.project {
    name = 'playpay-sdk'
    // Letting Eclipse know that the project is Android
    natures 'com.android.ide.eclipse.adt.AndroidNature'
    buildCommand 'com.android.ide.eclipse.adt.ResourceManagerBuilder'
    buildCommand 'com.android.ide.eclipse.adt.PreCompilerBuilder'
    buildCommand 'com.android.ide.eclipse.adt.ApkBuilder'
}
```

这段内容主要是为了能够生成`.classpath`和`.project`

# eclipse工程更新

在根目录执行 gradle命令  `gradle cleanEclipse eclipse` 重新生成eclipse工程。  
导入工程，**File -> Import -> General -> Existing Projects into Workspace**.  
不要使用导入Android工程，不然会修改刚才生成的.project和.classpath。  
如果遇到eclipse依赖引用问题，可以重新打开工程进行刷新

# 完整示例
{% gist /yeungeek/85f81d5e73ff178e0f3a %}


