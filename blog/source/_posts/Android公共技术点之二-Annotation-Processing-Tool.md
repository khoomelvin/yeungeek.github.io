title: "Android公共技术点之二-Annotation Processing Tool"
date: 2016-04-27 15:31:54
tags:
- android
- annotation
- apt
categories:
- publicTech
---
在技术点之一中介绍到编译时注解，使用APT工具进行自动解析，这次介绍的就是Annotation Processing Tool，官方说明：
> The command-line utility apt, annotation processing tool, finds and executes annotation processors based on the annotations present in the set of specified source files being examined. The annotation processors use a set of reflective APIs and supporting infrastructure to perform their processing of program annotations (JSR 175)
<!-- more -->

## 介绍
编译时注解在项目编译的时候生成新的Java文件，这样可以减少手动的代码输入，而且可以不用使用反射，对程序不会造成性能影响。  

## AbstractProcessor
这是处理器的API，所有的处理器都是基于AbstractProcessor
```
public class MyProcessor extends AbstractProcessor {
	@Override
	public boolean process(Set<? extends TypeElement> annoations,
			RoundEnvironment env) {
		return false;
	}

    @Override
   public Set<String> getSupportedAnnotationTypes() {
       return Collections.singleton(PojoString.class.getCanonicalName());
   }

   @Override
   public SourceVersion getSupportedSourceVersion() {
       return SourceVersion.latestSupported();
   }

	@Override
	public synchronized void init(ProcessingEnvironment processingEnv) {
		super.init(processingEnv);
	}

}
```
* `init(ProcessingEnvironment processingEnv)`
所有的注解处理器类都必须有一个无参构造函数。然而，有一个特殊的方法init()，它会被注解处理工具调用，以ProcessingEnvironment作为参数。
ProcessingEnvironment 提供了一些实用的工具类Elements, Types和Filer。
* `process(Set<? extends TypeElement> annoations, RoundEnvironment env)`
主要的逻辑处理都在这里，这个方法里面可以实现扫描，处理注解，生成 java 文件。使用RoundEnvironment 参数，可以查询被特定注解标注的元素。
* `getSupportedAnnotationTypes()`
在这个方法里面你必须指定哪些注解应该被注解处理器注册。注意，它的返回值是一个String集合，包含了你的注解处理器想要处理的注解类型的全称。我们看下ButterKnife的ButterKnifeProcessor如何声明的：
```
@Override public Set<String> getSupportedAnnotationTypes() {
    Set<String> types = new LinkedHashSet<>();

    types.add(BindArray.class.getCanonicalName());
    types.add(BindBitmap.class.getCanonicalName());
    types.add(BindBool.class.getCanonicalName());
    types.add(BindColor.class.getCanonicalName());
    types.add(BindDimen.class.getCanonicalName());
    types.add(BindDrawable.class.getCanonicalName());
    types.add(BindInt.class.getCanonicalName());
    types.add(BindString.class.getCanonicalName());
    types.add(BindView.class.getCanonicalName());
    types.add(BindViews.class.getCanonicalName());

    for (Class<? extends Annotation> listener : LISTENERS) {
      types.add(listener.getCanonicalName());
    }

    return types;
  }
```
* `getSupportedSourceVersion()`
用来指定使用的java版本。通常返回SourceVersion.latestSupported()。

## 注册处理器
如何注册注解处理，你的compiler会生成一个jar，在jar中`META-INF/services`目录需要新建一个特殊的文件`javax.annotation.processing.Processor`，文件里的内容就是声明你的处理器
```
com.example.MyProcess
...
```
使用google的[auto-service](https://github.com/google/auto/tree/master/service)可以自动生成`META-INF/services/javax.annotation.processing.Processor`文件
```
package foo.bar;
import javax.annotation.processing.Processor;

@AutoService(Processor.class)
final class MyProcessor extends Processor {
  // …
}
```

这样在javax.annotation.processing.Processor文件中会包含：
```
foo.bar.MyProcessor
```

## 实例
下面来介绍在Android Studio新建注解处理器工程，普通类自动生成string。
### 工程目录
* app
测试注解处理器
* annotation
注解的声明
* compiler
具体Processor解析模块

### Processor
compiler模块，是具体的Processor实现。build.gradle：
```
apply plugin: 'java'

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])

    compile project (':annotation')

    compile 'com.squareup:javapoet:1.7.0'
    compile 'com.google.auto.service:auto-service:1.0-rc2'
}

sourceCompatibility = JavaVersion.VERSION_1_7
targetCompatibility = JavaVersion.VERSION_1_7
```
* `compile project (':annotation')`: 引用注解的模块
* `javapoet`: 自动生成类的辅助库
* `auto-service`: 上文提到，可以自动生成`META-INF/services/javax.annotation.processing.Processor`文件

具体的实现：
```
@AutoService(Processor.class)
public class PojoStringProcessor extends AbstractProcessor {
    private static final String ANNOTATION = "@" + PojoString.class.getSimpleName();
    private static final String CLASS_NAME = "StringUtil";
    private Messager messager;

    @Override
    public synchronized void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        messager = processingEnv.getMessager();
    }

    @Override
    public Set<String> getSupportedAnnotationTypes() {
        return Collections.singleton(PojoString.class.getCanonicalName());
    }

    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latestSupported();
    }

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        ArrayList<AnnotatedClass> annotatedClasses = new ArrayList<>();
        for (Element element : roundEnv.getElementsAnnotatedWith(PojoString.class)) {
            TypeElement typeElement = (TypeElement) element;
            if (!isValidClass(typeElement)) {
                return true;
            }

            try {
                annotatedClasses.add(buildAnnotatedClass(typeElement));
            } catch (IOException e) {
                String message = String.format("Couldn't process class %s: %s", typeElement,
                        e.getMessage());
                messager.printMessage(Diagnostic.Kind.ERROR, message, element);
                e.printStackTrace();
            }


        }
        try {
            generate(annotatedClasses);
        } catch (IOException e) {
            messager.printMessage(Diagnostic.Kind.ERROR, "Couldn't generate class");
        }

        return true;
    }
}    
```
在process方法对注解进行处理，获取到注解属性，通过javapoet自动生成java文件，下面会介绍具体介绍如何使用。
### 引用
在app模块中引用处理器，需要通过apt plugin，在根目录build.gradle声明：
```
 classpath 'com.neenbedankt.gradle.plugins:android-apt:1.8'
```
在app模块的build.grale中：
```
apply plugin: 'com.neenbedankt.android-apt'
...
dependencies {
    compile project (':annotation')
    apt project(":compiler")
}
```
使用注解声明类:
```
@PojoString
public class SimplePojo {
    public String s1;
    public String s2;

    public SimplePojo(String s1, String s2) {
        this.s1 = s1;
        this.s2 = s2;
    }

    @Override
    public String toString() {
        return StringUtil.createString(this);
    }
}
```
在没有编译工程的时候，是找不到`StringUtil`类，它是在工程编译的时候自动生成。编译工程后可以看到
![](http://pic.yupoo.com/yeungeek/FvunkVfU/medish.jpg)

完整的实例代码: [APT Demo](https://github.com/yeungeek/Android-Gradle-Samples/tree/master/PublicTech)
## 参考
* [ANNOTATION PROCESSING 101](http://hannesdorfmann.com/annotation-processing/annotationprocessing101)
* [Annotation-Processing-Tool详解](http://qiushao.net/2015/07/07/Annotation-Processing-Tool%E8%AF%A6%E8%A7%A3/)
* [POJO string generator](http://brianattwell.com/android-annotation-processing-pojo-string-generator/)
