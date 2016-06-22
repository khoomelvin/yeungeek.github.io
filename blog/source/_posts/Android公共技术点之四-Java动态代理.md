title: "Android公共技术点之四-Java动态代理"
date: 2016-05-19 19:15:19
tags:
- android
- annotation
- proxy
categories:
- publicTech
---

## 概念
代理是一种比较常用的设计模式，目的就是为其他对象提供一个代理来控制对某个对象的访问。通俗点来说，如果不想或者不能直接访问一个对象A，必须通过一个中介对象B来访问，这种方式就叫做代理。代理根据生成的时间不同可以分为静态代理和动态代理。
<!-- more -->

## 代理的优点
* 隐藏委托类的实现，调用者只需要和代理类进行交互即可。
* 解耦，在不改变委托类代码情况下做一些额外处理，比如添加初始判断及其他公共操作

## 静态代理
静态代理就是，代理类的字节码文件，代理类和委托类的关系在运行前就已经确定了。下面通过例子来说明：  
代理接口定义
```
public interface Subject {
    void m1();
    void m2();
}
```
代理委托者，实现了代理接口
```
public class RealSubject implements Subject{
    @Override
    public void m1() {
        SystemClock.sleep(1000);
        Log.d("DEBUG","##### call method 1");
    }

    @Override
    public void m2() {
        SystemClock.sleep(2000);
        Log.d("DEBUG","##### call method 2");
    }
}
```
代理类
```
public class ProxySubject implements Subject {
    //引用真正的实现类
    private RealSubject subject;

    @Override
    public void m1() {
        log();
        if (null == subject) {
            subject = new RealSubject();
        }

        subject.m1();
    }

    @Override
    public void m2() {
        if (null == subject) {
            subject = new RealSubject();
        }

        subject.m2();
        log();
    }

    private void log() {
        Log.d("DEBUG", "### log it");
    }
}
```
代理类通过引用，去调用真实对象的方法，在代理类方法中可以加入一些其他操作，比如日志操作等。
## 动态代理
因为代理对象的一个接口，只服务一个类型的对象。如果要代理的方法很多的话，就要为每一种都进行代理，在程序规模大的时候，就无法胜任了。  
如果接口中增加一个方法，除了委托类要实现这个方法，所有的代理类也要实现这个方法，增加了程序的复杂度。  
如何解决上诉的问题，最好的方法就是通过一个代理类完成全部的代理功能，或者动态的生成这个代理类，这个方法就是动态代理。
### 实现步骤
1. 创建一个实现InvocationHandler的类，实现invoke方法
2. 通过Proxy的newProxyInstance创建一个代理
3. 创建代理类和接口
4. 通过代理调用方法

### 实现InvocationHandler,创建代理
实现InvocationHandler，InvocationHandler的核心方法：
```
Object invoke(Object proxy, Method method, Object[] args)
 proxy 该参数为代理类的实例
 method 被调用的方法对象
 args 调用method对象的方法参数
```
Proxy的newProxyInstance创建代理
```
static Object newProxyInstance(ClassLoader loader, Class[] interfaces,InvocationHandler h)
 loader 指定代理类的ClassLoader加载器
 interfaces 指定代理类要实现的接口
 h: 动态代理对象在调用方法的时候，会关联到哪一个InvocationHandler对象
```
该方法用于为指定类装载器、一组接口及调用处理器生成动态代理类实例   
具体的Proxy声明:
```
public class TimeProxy implements InvocationHandler {
    private Object delegate;

    public Object bind(Object delegate){
        this.delegate = delegate;
        return Proxy.newProxyInstance(delegate.getClass().getClassLoader(),delegate.getClass().getInterfaces(),this);
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        long start = System.currentTimeMillis();
        Object obj = method.invoke(delegate, args);
        Log.d("DEBUG", "#### cost time: " + (System.currentTimeMillis() - start));
        return obj;
    }
}
```
invoke方法加入了一些其他操作，这里增加了方法的时间统计。
### 创建代理类和接口
就是刚才在静态代理中声明的`Subject`接口和`RealSubject`实现类。
### 通过代理调用方法
通过动态生成的代理来调用方法
```
RealSubject delegate = new RealSubject();
Subject subject = (Subject) new TimeProxy().bind(delegate);
subject.m1();
subject.m2();
```
## 代理的应用场景
* 数据库连接以及事务
* 单元测试的动态Mock对象
* 类似AOP的方法拦截器
* 自定义工厂与依赖注入容器之间的适配器
* 延迟加载上的应用

Android端的网络请求框架`Refrofit`也是基于动态代理的，具体的原理实现，请参照[Retrofit 源码解析](https://github.com/android-cn/android-open-project-analysis/tree/master/tool-lib/network/retrofit)

## 参考
* [公共技术点之 Java 动态代理](http://codekk.com/blogs/detail/54cfab086c4761e5001b253d)
* [Java反射学习总结四（动态代理使用实例和内部原理解析)](http://blog.csdn.net/a396901990/article/details/26015977)
* [The power of proxies in Java](https://blog.frankel.ch/the-power-of-proxies-in-java/)
* [Java Reflection - Dynamic Proxies](http://tutorials.jenkov.com/java-reflection/dynamic-proxies.html)
