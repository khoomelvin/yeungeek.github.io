title: "Android公共技术点之三-Reflection"
date: 2016-05-12 17:23:40
tags:
- android
- annotation
- reflection
categories:
- publicTech
---
Java反射机制在很多框架中被使用，它可以让我们在编译期之外的运行期检查类，接口，变量以及方法的信息。反射可以让我们在运行期实例化对象，调用方法，通过调用get/set方法获取变量的值。
<!-- more -->
官网上对Java反射机制使用的描述: [Reflection](https://docs.oracle.com/javase/tutorial/reflect/)
>Reflection is commonly used by programs which require the ability to examine or modify the runtime behavior of applications running in the Java virtual machine. This is a relatively advanced feature and should be used only by developers who have a strong grasp of the fundamentals of the language. With that caveat in mind, reflection is a powerful technique and can enable applications to perform operations which would otherwise be impossible.

## 简介
### 反射的用途
* 在运行时判断任意一个对象所属的类
* 在运行时构造任意一个的对象
* 在运行时判断任意一个类所具有的成员变量和方法
* 在运行时调用任意一个对象的方法

### Reflection API
* Class: 类
* Field: 类的属性
* Method: 类的方法
* Constructor: 类的构造方法
* Array: 动态创建数组,以及访问数组元素的静态方法

## Reflection: 类和构造函数
### 类
使用Java反射可以在运行时期检查Java类的信息
* Class对象
* 类名
* 修饰符
* 包信息
* 父类
* 实现的接口
* 构造函数
* 方法
* 变量
* 注解

获取类接口说明：
```
public static Class<?> forName(String className)
public static Class<?> forName(String className, boolean shouldInitialize,ClassLoader classLoader)
//className:加载的类的完整路径
//shouldInitialize:是否初始化Class对象
//classLoader:指定类的加载器
```
实例：
```
Class<?> clazz = Class.forName(PERSON_CLASS_NAME);
Person person = (Person) clazz.newInstance();
person.setName("hello");
person.setAge(18);
```
### 构造函数
反射可以检查一个类的构造方法，并且可以在运行期创建一个对象。
接口说明：
```
//获取类的所有的公有构造函数
public Constructor<?>[] getConstructors()

//根据参数，获取相对应的公有构造函数
public Constructor<T> getConstructor(Class<?>... parameterTypes)
```
实例：
```
Class<?> clazz = Class.forName(PERSON_CLASS_NAME);
Constructor<?>[] constructors = clazz.getConstructors();

Person person = (Person) constructors[0].newInstance();
//获取到所有的公有构造函数，对第一进行实例化操作。
Log.d(TAG, "### 2.constructor[0]: " + person.toString());

Constructor<?> constructor = clazz.getConstructor(String.class, int.class);
person = (Person) constructor.newInstance("test", 102);
//根据指定的参数获取构造函数，并进行实例化
Log.d(TAG, "### 3.constructor[1]: " + person.toString());
```
## Reflection: 方法
在运行期检查一个方法的信息以及在运行期调用这个方法，可以通过以下接口操作：
```
//获取Class对象中的所有方法，不包含继承中的方法
public Method[] getDeclaredMethods()

//获取指定名称的所有方法
public Method getDeclaredMethod(String name, Class<?>... parameterTypes)

//获取Class对象中的所有公有方法，包含继承和接口类中的方法
public Method[] getMethods()

//获取指定名称的所有公有方法
public Method getMethod(String name, Class<?>... parameterTypes)

//1. name:方法名称
//2. parameterTypes:参数类型
```
实例：
```
//获取所有的方法
private void inspectGetDeclaredMethods() throws Exception {
    Father father = new Father();
    Method[] methods = father.getClass().getDeclaredMethods();//get public default protected private method
    //显示所有的方法,不包含父类中继承的方法
    for (int i = 0; i < methods.length; i++) {
        Method method = methods[i];
        Log.d(TAG, "### method[" + i + "]: " + method.getName());
    }

    //获取指定名称的方法
    Method nameMethod = father.getClass().getDeclaredMethod("setMan", boolean.class);
    //get parameter
    Class<?>[] paramClasses = nameMethod.getParameterTypes();
    for (Class<?> paramClass : paramClasses) {
        Log.d(TAG, "### paramClass: " + paramClass.getName());
    }

    //判断方法的修饰符
    Log.d(TAG, "### " + nameMethod.getName() + " is private: " +
            Modifier.isPrivate(nameMethod.getModifiers()));
    //直接调用方法
    nameMethod.invoke(father, true);
    Log.d(TAG, "### 4. invoke: " + father.toString());
}
```
`getParameterTypes`获取到方法的参数类型   
`public native Object invoke(Object receiver, Object... args)` 调用对应的方法  
`public void setAccessible(boolean flag)`
 accessible标志设置为true，以此来提升反射速度。值为true则指示反射的对象在使用时应该取消Java语言访问检查。  
 上面代码中`Father`是继承自`Person`的子类，为了更好的说明方法和属性，下面是这两个类的声明：  
 **Person:**
 ```
 public class Person {
    private String name;
    public int age;

    public Person() {
    }

    public Person(final String name, final int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public Person setName(String name) {
        this.name = name;
        return this;
    }

    public int getAge() {
        return age;
    }

    public Person setAge(int age) {
        this.age = age;
        return this;
    }

    private void say() {
        Log.d("test", "### say()");
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
 ```
 **Father**
 ```
@Brand(name = "Good Father")
public class Father extends Person implements Smoke {
    @Brand(name = "Field Annotation")
    private boolean isMan;

    private List<String> stringList = new ArrayList<>();


    public Father() {
    }

    public Father(String name, int age) {
        super(name, age);
    }

    @Brand(name = "Method Annotation")
    public boolean isMan() {
        return isMan;
    }

    public Father setMan(boolean man) {
        isMan = man;
        return this;
    }

    public List<String> getStringList() {
        return stringList;
    }

    public Father setStringList(List<String> stringList) {
        this.stringList = stringList;
        return this;
    }


    @Override
    public void smoke() {
        Log.d("test", "### smoke");
    }

    @Override
    public String toString() {
        return "Father{" +
                "isMan=" + isMan +
                "} " + super.toString();
    }
}
 ```
 一个`Smoke`接口，一个`@Brand`注解
 ```
public interface Smoke {
    void smoke();
}

//注解
@Target({ElementType.FIELD, ElementType.METHOD, ElementType.TYPE, ElementType.CONSTRUCTOR})
@Retention(RetentionPolicy.RUNTIME)
public @interface Brand {
    String name() default "";
}
 ```
## Reflection: 属性
获取属性和获取方法是类似的，只是使用Field类型。接口声明：
```
//获取所有的属性，不包含父类继承的
public native Field[] getDeclaredFields()
//获取指定名称的属性
public native Field getDeclaredField(String name)
//获取所有的公有属性，包含父类和接口继承的
public Field[] getFields()
//获取指定名称的属性
public Field getField(String name)
```
具体的实例可以github上的代码[inspectGetMethods() ](https://github.com/yeungeek/AndroidSample/blob/master/PublicTech/app/src/main/java/com/yeungeek/publictech/reflection/ReflectionActivity.java#L194)
## Reflection: 父类和接口
获取父类和接口，接口声明：
```
//获取对象的父类
public Class<? super T> getSuperclass()
//获取对象实现的接口
public Class<?>[] getInterfaces()
```
实例：
```
Father father = new Father();
Class<?> fs = father.getClass().getSuperclass();
Log.d(TAG, "### superClass: " + fs.getName());

//super or not
Class<?>[] interfaces = father.getClass().getInterfaces();
for (Class<?> clazz : interfaces) {
    Log.d(TAG, "### interfaces: " + clazz);
}
```
## Reflection: 注解
获取注解的信息，在上一篇文章有提到[Java注解](/2016/04/25/Android公共技术点之一-Java注解/)。
这边定义的注解`@Brand`，Target类型是`FIELD`, `METHOD`, `TYPE`, `CONSTRUCTOR`，而且是运行时期的注解。  
接口声明：
```
//获取对象的所有注解
public Annotation[] getAnnotations()
//获取指定类型的注解
public <A extends Annotation> A getAnnotation(Class<A> annotationType)
```
实例：
```
Father father = new Father();
Annotation[] annotations = father.getClass().getAnnotations();
for (Annotation annotation : annotations) {
    Log.d(TAG, "### annotation: " + annotation);
}

//获取指定类型的注解
Brand brand = father.getClass().getAnnotation(Brand.class);
Log.d(TAG, "### annotation brand: " + brand.name());

//获取方法上的注解
Field manField = father.getClass().getDeclaredField("isMan");
brand = manField.getAnnotation(Brand.class);
Log.d(TAG, "### annotation field: " + brand.name());
```
## Reflection: 泛型
获取泛型的信息，介绍的比较少。很多文章说Java泛型信息在编译期被擦除（erased）所以你无法在运行期获得有关泛型的信息。  
在看了[Java Reflection教程](http://ifeve.com/java-reflection/)后，是可以获取到泛型的信息。  
文中提到使用泛型的两个场景:
1. 声明一个需要被参数化（parameterizable）的类/接口
2. 使用一个参数化类

接口声明：
```
//获取泛型的类型
public Type getGenericType()
//获取方法上所有的泛型类型
public Type[] getGenericParameterTypes()
//获取方法的返回泛型类型
public Type getGenericReturnType()
//获取具体的参数类型
Type[] getActualTypeArguments()
```
实例：
```
//泛型方法返回类型
Method method = Father.class.getMethod("getStringList", null);
Type type = method.getGenericReturnType();

if (type instanceof ParameterizedType) {
    ParameterizedType paramType = (ParameterizedType) type;
    Type[] types = paramType.getActualTypeArguments();
    for (Type typeArg : types) {
        Class typeArgClass = (Class) typeArg;
        Log.d(TAG, "### typeArgClass: " + typeArgClass);
    }
}

//泛型方法参数类型
Log.e(TAG, "### method parameter");
method = Father.class.getMethod("setStringList", List.class);

Type[] types = method.getGenericParameterTypes();
for (Type genericType : types) {
    if (genericType instanceof ParameterizedType) {
        ParameterizedType parameterizedType = (ParameterizedType) genericType;
        Type[] args = parameterizedType.getActualTypeArguments();
        for (Type arg : args) {
            Class argClass = (Class) arg;
            Log.d(TAG, "### typeArgClass: " + argClass);
        }
    }
}

Log.e(TAG, "### inspect field parameter");
//泛型变量类型
Field field = Father.class.getDeclaredField("stringList");
type = field.getGenericType();
if (type instanceof ParameterizedType) {
    ParameterizedType parameterizedType = (ParameterizedType) type;
    Type[] args = parameterizedType.getActualTypeArguments();
    for (Type arg : args) {
        Class argClass = (Class) arg;
        Log.d(TAG, "### typeArgClass: " + argClass);
    }
}
```

## Reflection: 数组
利用反射机制处理数组比较麻烦一点，通过java.lang.reflect.Array来处理数组。
接口声明：
```
//初始化数组
public static Object newInstance(Class<?> componentType, int size)
//T具体类型，为数组赋值
public static void setT(Object array, int index, T value)
//获取数组的成员类型
public Class<?> getComponentType()
```

实例：

```
//初始化一个int数组
int[] intArray = (int[]) Array.newInstance(int.class, 3);

//赋值
Array.setInt(intArray, 0, 10);
Array.setInt(intArray, 1, 20);
Array.setInt(intArray, 2, 30);

Log.d(TAG, "### get Array: " + Array.get(intArray, 0));

//获取数组的Class对象的不同方法
Class stringClass = String[].class;
//在JVM中字母I代表int类型，左边的‘[’代表声明的是一个int类型的数组
Class intArray1 = Class.forName("[I");
//‘[L’的右边是类名，类名的右边是一个‘;’符号。这个的含义是一个指定类型的数组
Class stringArray = Class.forName("[Ljava.lang.String;");

//获取数组的成员类型
Class stringArray1 = Array.newInstance(String[].class, 3).getClass();
Log.d(TAG, "### stringarray?: " + stringArray.isArray());
Class componentType = stringArray1.getComponentType();
Log.d(TAG, "### componentType: " + componentType);
```

## 性能测试
都说反射的速度很慢，到底有多慢，我们来测试下，具体的代码参考:[benchmarks](https://github.com/yeungeek/AndroidSample/blob/master/PublicTech/app/src/main/java/com/yeungeek/publictech/reflection/ReflectionActivity.java#L46)  
测试结果(ms,测试次数10000):  

方法 | HTC A9(6.0.1) |Samsung Note4(5.0.1)| HTC D816h(4.4.2)
----|------|------|----
getFields | 992  | 975|10158
getDeclaredFields | 313  | 534|5591
getGenericInterfaces | 17  | 13|33
setObject | 25  | 75 |95
newInstance(new) | 36 | 18 |96
newInstance(reflect) | 121  | 278 |233

全部使用真机测试，虽然机器的性能稍微有些不同，但是量级可以说明问题。  
实例化对象，使用反射耗时比较长。4.4系统上获取属性的耗时，比5.0,6.0上更长，不过反射都还是比较慢。
## 在Android中应用
既然反射这么慢，什么时候去使用反射?   
如果需要访问一些不开放的系统api，反射就可以派上大用场了。   
我们知道`Toast`是没有直接提供hide()，但是通过cancel方法可以取消toast。我们这边只是演示下反射的应用。
```
//反射获取mTN属性,它有show和hide的方法操作
Toast toast = Toast.makeText(this, "Toast Reflection", Toast.LENGTH_LONG);
try {
    Field field = toast.getClass().getDeclaredField("mTN");
    field.setAccessible(true);
    mObj = field.get(toast);
} catch (Exception e) {
    e.printStackTrace();
}

//show
//4.0需要处理布局
if (Build.VERSION.SDK_INT > Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
    Field field = mObj.getClass().getDeclaredField("mNextView");
    field.setAccessible(true);
    LayoutInflater inflate = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    View v = inflate.inflate(R.layout.layout_toast, null);

    field.set(mObj, v);
}

Method method = mObj.getClass().getDeclaredMethod("show");
method.invoke(mObj);
//hide
Method method = mObj.getClass().getDeclaredMethod("hide");
method.invoke(mObj);
```
是不是还是很用处的，很多框架都是用的反射。  
不过实际的开发中需要慎用反射，尤其在android开发，不过现在已经有很多android框架使用了apt技术来实现，在性能上，不会损失太多。  
code: [Reflection](https://github.com/yeungeek/AndroidSample/tree/master/PublicTech/app/src/main/java/com/yeungeek/publictech/reflection) 
## 参考
* [Java Reflection教程](http://ifeve.com/java-reflection/)
* [公共技术点之 Java 反射 Reflection](http://codekk.com/blogs/detail/5596953ed6459ae7934997c5)
* [【Android】 认识反射机制（Reflection）](http://blog.qiji.tech/archives/4374)
* [Learn Java for Android Development: Reflection Basics](http://code.tutsplus.com/tutorials/learn-java-for-android-development-reflection-basics--mobile-3203)
