title: Android工程师角度分析App使用的开源框架-2.手淘
date: 2017-06-28 19:20:09
tags:
- open source
- android
categories:
- source analysis
---
距离上一篇的分析文章，已经过去一段时间了。  
这次我们分析的是手淘app使用了哪些开源框架，在手淘app的关于中，和支付宝一样，也有开源列表声明：https://h5.m.taobao.com/other/android_legal.html，  其中罗列一些手淘app使用的开源框架。这篇文章从源码角度去分析，手淘具体使用了哪些框架。
<!-- more -->
## 反编译源码
这次使用的反编译工具是[jadx](https://github.com/skylot/jadx)，使用非常方便,命令行或者gui直接打开对应的apk就可以查看源码和清单文件。 
代码结构：
![](http://pic.yupoo.com/yeungeek/GyAjHinB/medish.jpg)
## 源码分析
名称 | 包名 |描述
----|------|------
[atlas](https://github.com/alibaba/atlas)|android.taobao.atlas|动态组件化框架
[windvane](http://www.infoq.com/cn/presentations/mobile-taobao-h5-container-architecture-evolution)|android.taobao.windvane|手淘h5框架
anetwork|anetwork.network|网络相关,没有找到对应资源
[lottie](https://github.com/airbnb/lottie-android)|com.airbnb.lottie|酷炫的Lottie动画库,手淘中有精简
[appmonitor](https://doc.alidayu.com/doc2/detail.htm?treeId=195&articleId=105220&docType=1)|com.alibaba.appmonitor|阿里百川的一些lib
[fastjson](https://github.com/alibaba/fastjson)|com.alibaba.fastjson|alibaba的Json解析库
[NineOldAndroids](https://github.com/JakeWharton/NineOldAndroids)|com.nineoldandroids.view|动画兼容库
[weex](https://github.com/apache/incubator-weex)|com.taobao.weex|跨平台开发框架

其中淘宝封装的库没有找到对应的资源，还有其他第三方分析和push库，这里也没有列出来，有兴趣的同学，可以自行研究。
淘宝使用weex后，一些UI库，很多已经被weex替代。

### 惊喜库
* [淘宝动态组件库 atlas](https://github.com/alibaba/atlas)
* [Lottie动画库](https://github.com/airbnb/lottie-android)
* [跨平台开发框架 weex](https://github.com/apache/incubator-weex)

我们从源码中可以看出，淘宝对跨平台和组件化的框架运用的非常多，手淘的一些功能模块就变得非常动态，可以根据不同的节日、时间，动态更新地更新对应组件，达到预期的效果。
后面要分析的话，准备看下电商同类型的，京东app、美团等



