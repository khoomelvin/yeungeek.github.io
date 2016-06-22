title: "Android公共技术点之五-依赖注入"
date: 2016-06-22 10:04:20
tags:
- android
- annotation
- IoC
- DI
categories:
- publicTech
---
依赖注入(Dependency Injection，简称DI)是控制反转最常见的方式。控制反转(Inversion of Control，缩写为IoC)，是面向对象编程中的一种设计原则，可以用来减低计算机代码之间的耦合度。  
简单来说，依赖注入和控制反转的关系：
* 控制反转是一种思想
* 依赖注入是一种设计模式

<!--more-->
## 什么是依赖
如果在 Class A 中，有 Class B 的实例，则称 Class A 对 Class B 有一个依赖。例如下面类 Human 中用到一个 Father 对象，我们就说类 Human 对类 Father 有一个依赖。
```
public class Human {
    ...
    Father father;
    ...
    public Human() {
        father = new Father();
    }
}
```
仔细看这段代码我们会发现存在一些问题：
(1). 如果现在要改变`father`生成方式，如需要用new Father(String name)初始化`father`，需要修改`Human`代码；
(2). 如果想测试不同`Father`对象对`Human`的影响很困难，因为`father`的初始化被写死在了`Human`的构造函数中；
(3). 如果new Father()过程非常缓慢，单测时我们希望用已经初始化好的`father`对象`Mock`掉这个过程也很困难。
## 依赖注入
上面将依赖在构造函数中直接初始化是一种 Hard init 方式，弊端在于两个类不够独立，不方便测试。我们还有另外一种 Init 方式，如下：
```
public class Human {
    ...
    Father father;
    ...
    public Human(Father father) {
        this.father = father;
    }
}
```
上面代码中，我们将 father 对象作为构造函数的一个参数传入。在调用 Human 的构造方法之前外部就已经初始化好了 Father 对象。**像这种非自己主动初始化依赖，而通过外部来传入依赖的方式，我们就称为依赖注入。**
现在我们发现上面 1 中存在的两个问题都很好解决了，简单的说依赖注入主要有两个好处：
(1). 解耦，将依赖之间解耦。
(2). 因为已经解耦，所以方便做单元测试，尤其是 Mock 测试。
## Java中的依赖注入
使用注解进行依赖注入，是Java中最常见的方式。
```
public class Human {
    ...
    @Inject Father father;
    ...
    public Human() {
    }
}
```
上面代码中使用`@Inject`注解进行标记，实现`Father`对象的依赖注入。  
注解有编译时和运行时注解，在Android上比较流行的[RoboGuice](https://github.com/roboguice/roboguice)是运行时注解，[Dagger2](http://google.github.io/dagger/)则是基于编译时注解。
如果对Dagger的源码感兴趣，可以参考[Dagger 实现原理解析](http://a.codekk.com/detail/Android/%E6%89%94%E7%89%A9%E7%BA%BF/Dagger%20%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90)
<!--more-->
## 参考
* [公共技术点之依赖注入](http://codekk.com/blogs/detail/54cfab086c4761e5001b253c)
* [Dependency Injection, Annotations, and why Java is Better Than you Think it is](http://www.objc.io/issue-11/dependency-injection-in-java.html)
* [控制反转](https://zh.wikipedia.org/wiki/%E6%8E%A7%E5%88%B6%E5%8F%8D%E8%BD%AC)
