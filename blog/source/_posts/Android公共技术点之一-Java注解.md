title: "Android公共技术点之一-Java注解"
date: 2016-04-25 17:45:56
tags:
- android
- annotation
- ButterKnife
categories:
- android
---

基础是学习任何技术的必须，接下来会介绍一些Android上用到的一些公共技术点。
<!-- more -->
看了Trinea在codekk上的一些公共技术点，这些点不管在Java还是Android上，都是重要的基础点,所以准备学习之。  
## Annotation概念
注解是 Java5的一个新特性。注解是插入代码中的一种注释或者是一种元数据(meta data)。  
官方的解释:
>Annotations, a form of metadata, provide data about a program that is not part of the program itself. Annotations have no direct effect on the operation of the code they annotate.

作用：
* 编写文档:通过代码里的元数据生成文档
* 代码分析:通过代码里标识的元数据对代码进行分析
* 编译检查:通过代码里标识的元数据让编译器实现基本的编译检查

## 元注解
元注解的作用就是注解其他注解。Java中定义了4个标准的meta-annotation类型，用以对其他的annotation类型做说明，分别是：
1. @Target
2. @Retention
3. @Documented
4. @Inherited

### @Target
说明了Annotation所修饰的对象的作用：用户描述注解的使用范围
取值(ElementType):
- CONSTRUCTOR: 描述构造器
- FIELD：描述域
- LOCAL_VARIABLE:描述局部变量
- METHOD:描述方法
- PACKAGE:描述包
- PARAMETER:描述参数
- TYPE:描述类、接口(包括注解类型) 或enum声明

如果没有声明，可以修饰所有
### @Retention
表示需要在什么级别保存该注释信息，用于描述注解的生命周期
取值(RetentionPolicy):
* SOURCE(源码时)
* CLASS(编译时)
* RUNTIME(运行时)

默认为CLASS
### @Documented
标记注解，没有成员
用于描述其它类型的annotation应该被作为标注的程序成员的公共api，可以文档化

### @Inherited
标记注解
用该注解修饰的注解，会被子类继承

## Annotation自定义
自定义注解使用@interface声明一个注解，每一个方法就是声明一个配置参数，方法的名称就是参数的名称
返回的类型就是参数的类型(返回值类型只能是基本类型、Class、String、enum)。可以通过default来声明参数的默认值。  
下面举个例子:
```
@Documented
@Retention(CLASS)
@Target(FIELD)
@Inherited
public @interface MyAnnotation {
    String name();
    int id() default 1;
    int[] value();
}
```
定义了MyAnnotation注解是编译时注解，用于修饰属性，可以被继承和文档化，有3个配置参数。
## Annotation解析
主要是根据@Retention分类，下面主要介绍`CLASS`和`RUNTIME`
### 运行时Annotation解析
运行时Annotation是指@Retention为`RUNTIME`的Annotation,解析Annotation的API：
```
T getAnnotation(Class annotationClass) //返回改程序上存在、指定类型的注解
Annotation[] getAnnotations()   //返回改程序元素上存在的所有注解
boolean is AnnotationPresent(Annotation)    //判断该程序元素上是否包含指定类型的注解
Annotation[] getDeclaredAnnotations()       //返回直接存在在改元素上的所有注解,不包含继承的注解
```
获取注解的信息：
```
private void processAnnotation(Class<?> clazz) {
    Field[] fields = clazz.getDeclaredFields();
    for (Field field : fields) {
        if (field.isAnnotationPresent(MyAnnotation.class)) {
            MyAnnotation myAnnotation = field.getAnnotation(MyAnnotation.class);
            Log.d("DEBUG", "### id:" + myAnnotation.id() + ", name:" + myAnnotation.name()
                    + ", value: " + myAnnotation.value());
        }
    }
}
```
### 编译时Annotation解析
编译时Annotation指@Retention为`CLASS`的Annotation，由编译器自动解析，基于APT注解处理工具。
apt：Annotation Processing Tool，官方说明
> The command-line utility apt, annotation processing tool, finds and executes annotation processors based on the annotations present in the set of specified source files being examined. The annotation processors use a set of reflective APIs and supporting infrastructure to perform their processing of program annotations (JSR 175)

如何使用apt：
1. 自定义类集成自 AbstractProcessor
2. 重写其中的 process 函数

上文定义的MyAnnotation，使用apt，该如何进行解析：(在android studio中直接使用AbstractProcessor，会找不到这个类，具体的解决方法，请看知识点-apt使用)
```
@SupportedAnnotationTypes({ "MyAnnotation" })
public class MyAnnotationProcessor extends AbstractProcessor {
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment env) {
        for (TypeElement te : annotations) {
            for (Element element : env.getElementsAnnotatedWith(te)) {
                MyAnnotation myAnnotation = element.getAnnotation(MyAnnotation.class);
                ... //具体的处理逻辑
            }
        }
        return false;
    }
}
```
SupportedAnnotationTypes 表示这个 Processor 要处理的 Annotation 名字。
process 函数中参数 annotations 表示待处理的 Annotations，参数 env 表示当前或是之前的运行环境
优点：
* 提高开发效率
* 减少代码量
* apt并不会影响性能

缺点：
* 可读性较差
* 生成一些辅助类，内存消耗变大
* android的65535方法数问题

## 开源库实例讲解
现在很多第三方库运用注解来实现具体功能，看看它们之间的区别
### Retrofit
[Retrofit](https://github.com/square/retrofit)是Restful的httpClient，目前版本2.0.2。  
看官网的例子
```
public interface GitHubService {
  @GET("users/{user}/repos")
  Call<List<Repo>> listRepos(@Path("user") String user);
}
....
Retrofit retrofit = new Retrofit.Builder()
    .baseUrl("https://api.github.com/")
    .build();

GitHubService service = retrofit.create(GitHubService.class);
```
@GET定义：
```
@Documented
@Target(METHOD)
@Retention(RUNTIME)
public @interface GET {
  String value() default "";
}
```
GET的Annotation定义是运行时的注解，只能修饰方法，有一个String属性。
在Retrofit初始化中可以看到原理，具体的实现在[ServiceMethod](https://github.com/square/retrofit/blob/master/retrofit%2Fsrc%2Fmain%2Fjava%2Fretrofit2%2FServiceMethod.java)
```
public Builder(Retrofit retrofit, Method method) {
  this.retrofit = retrofit;
  this.method = method;
  this.methodAnnotations = method.getAnnotations();
  this.parameterTypes = method.getGenericParameterTypes();
  this.parameterAnnotationsArray = method.getParameterAnnotations();
}
...
for (Annotation annotation : methodAnnotations) {
    parseMethodAnnotation(annotation);
}
...
private void parseMethodAnnotation(Annotation annotation) {
  if (annotation instanceof DELETE) {
    parseHttpMethodAndPath("DELETE", ((DELETE) annotation).value(), false);
  } else if (annotation instanceof GET) {
    parseHttpMethodAndPath("GET", ((GET) annotation).value(), false);
...    
}}}
```
上述代码会检查每个Annotation，看是否被rest method注解修饰，然后得到Annotation信息，在对接口进行动态代理时调用这些信息，完成具体的调用。
在Refrofit初始化create的时候，有动态代理行为。
```
public <T> T create(final Class<T> service) {
Utils.validateServiceInterface(service);
if (validateEagerly) {
  eagerlyValidateMethods(service);
}
return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
    new InvocationHandler() {
      private final Platform platform = Platform.get();

      @Override public Object invoke(Object proxy, Method method, Object... args)
          throws Throwable {
        // If the method is a method from Object then defer to normal invocation.
        if (method.getDeclaringClass() == Object.class) {
          return method.invoke(this, args);
        }
        if (platform.isDefaultMethod(method)) {
          return platform.invokeDefaultMethod(method, service, proxy, args);
        }
        ServiceMethod serviceMethod = loadServiceMethod(method);
        OkHttpCall okHttpCall = new OkHttpCall<>(serviceMethod, args);
        return serviceMethod.callAdapter.adapt(okHttpCall);
      }
    });
}
```
### Butterknife
[Butterknife](https://github.com/JakeWharton/butterknife),使用的是apt技术。  
目前稳定版本8.0.0，与7.0相比，主要runtime和compiler分离成了两个，支持更多的配置属性。下面的例子基于7.0.1
```
@Bind(R.id.toolbar)
Toolbar toolbar;
```
@Bind定义：
```
@Retention(CLASS) @Target(FIELD)
public @interface Bind {
  /** View ID to which the field will be bound. */
  int[] value();
}
```
可以看出Bind注解是编译时注解，只能修饰属性，有个int数组属性。
具体的原理实现在[ButterKnifeProcessor](https://github.com/JakeWharton/butterknife/blob/butterknife-parent-7.0.1/butterknife%2Fsrc%2Fmain%2Fjava%2Fbutterknife%2Finternal%2FButterKnifeProcessor.java)
```
@Override
public boolean process(Set<? extends TypeElement> elements, RoundEnvironment env) {
    Map<TypeElement, BindingClass> targetClassMap = findAndParseTargets(env);

    for (Map.Entry<TypeElement, BindingClass> entry : targetClassMap.entrySet()) {
      TypeElement typeElement = entry.getKey();
      BindingClass bindingClass = entry.getValue();

      try {
        JavaFileObject jfo = filer.createSourceFile(bindingClass.getFqcn(), typeElement);
        Writer writer = jfo.openWriter();
        writer.write(bindingClass.brewJava());
        writer.flush();
        writer.close();
      } catch (IOException e) {
        error(typeElement, "Unable to write view binder for type %s: %s", typeElement,
            e.getMessage());
      }
    }

    return true;
}
```
process方法，编译时，过滤Binding注解到targetClassMap，会根据 targetClassMap 中元素生成不同的 class 文件到最终的 APK 中，
运行时调用 ButterKnife.bind方法会到之前编译生成的类中去找。

本来还要分析下[Dagger](https://github.com/google/dagger)的注解，不过Dagger这块目前还不是很熟悉，它主要也是依赖注入框架，后面会和依赖注入知识一起介绍。
## 参考
* [公共技术点之 Java 注解 Annotation](http://b.codekk.com/blogs/detail/54cfab086c4761e5001b253b/)
* [深入理解Java：注解（Annotation）自定义注解入门](http://www.cnblogs.com/peida/archive/2013/04/24/3036689.html/)
* [最新ButterKnife框架原理](https://bxbxbai.github.io/2016/03/12/how-butterknife-works/)
