title: Android工程师角度分析App使用的开源框架-1.支付宝
date: 2017-02-05 15:48:27
tags:
- open source
- android
categories:
- source analysis
---
年前在掘金上看到一篇文章[支付宝 Android 版使用的开源组件](http://www.jianshu.com/p/844e338319af),看到很多人在评论，怎么支付宝也用这么多的开源框架，是不是会很low啊?  
接下来，我们看看支付宝用到的开源框架列表：https://ds.alipay.com/fd-opensource/index.html 。  这篇文章已经分析了支付宝用到的开源组件以及一些说明。不过我这次要从源码角度(反编译)再去看看，支付宝到底用了哪些开源框架。
<!-- more -->
## 反编译源码
关于反编译的工具，可以看我以前的一篇文章[Android反编译之一-反编译的工具和方法](http://yeungeek.com/2015/08/22/Android%E5%8F%8D%E7%BC%96%E8%AF%91%E4%B9%8B%E4%B8%80-%E5%8F%8D%E7%BC%96%E8%AF%91%E7%9A%84%E5%B7%A5%E5%85%B7%E5%92%8C%E6%96%B9%E6%B3%95/)。
这次使用到的工具
* 工具：[enjarify](https://github.com/google/enjarify)和JD GUI(http://jd.benow.ca/) ，  因为我这次只关注源码
* 支付宝版本：com.eg.android.AlipayGphone_10.0.1.123166_105.apk

反编译完成后，使用JD查看源码，源码结构：

![](http://pic.yupoo.com/yeungeek/GcGC0yqB/medish.jpg)![](http://pic.yupoo.com/yeungeek/GcGDhyKa/hXc3A.png)

## 源码分析
下面就源码来分析下，支付宝使用的开源框架，是否和他们列出来的一致。

名称 | 包名 |描述
----|------|------
[android-supprt-library](https://developer.android.google.cn/index.html) | v4,v7,v13,multidex  | google支持库
[OpenSSL](https://github.com/openssl/openssl)||NDK使用，看下lib是否有对应的so文件
[Gson](https://github.com/google/gson)|com.google.gson|Google官方的Json解析库
[fastjson](https://github.com/alibaba/fastjson)|com.alibaba.fastjson|alibaba的Json解析库
[sqlcrypto](https://github.com/sqlcipher/android-database-sqlcipher)|net.sqlcipher|sqlite加密库，支付宝直接整合到com.alibaba.sqlcrypto，对源码有修改
[duktape-android](https://github.com/square/duktape-android)|com.squareup.duktape|一个新的小巧的超精简可嵌入式JavaScript引擎，支付宝已经整合到com.alipay.jsbridge.duktape
[achartengine](https://github.com/ddanny/achartengine)|org.achartengine|老牌的图表库
[android-stackblur](https://github.com/kikoso/android-stackblur)|com.enrique.stackblur|图像高斯模糊，支付宝已经整合到com.alipay.android.phone.o2o.o2ocommon.util.blur
[android-gif-drawable](https://github.com/koral--/android-gif-drawable)|pl.droidsonroids.gif|Android显示Gif动图
[libyuv](https://github.com/lemenkov/libyuv)||在Android上使用Google开源的图像处理库libyuv进行高效的图像处理
[css-layout](https://github.com/facebook/yoga)||Facebook开源跨平台前端布局引擎Yoga,在源码中没有找到对应的类
[libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo)||libjpeg-turbo 是一个专门为 x86 和 x86-64 处理器优化的高速 libjpeg 的改进版本
[ViewPagerIndicator](https://github.com/JakeWharton/ViewPagerIndicator)|com.viewpagerindicator|老牌的ViewPagerIndicator,支付宝已经整合到com.alipay.mobile.commonui.widget.hgridview
[CircleImageView](https://github.com/hdodenhof/CircleImageView)|de.hdodenhof.circleimageview|圆角图片库,支付宝已经整合到com.alipay.android.phone.wallet.sharetoken.view
[ProgressWheel](https://github.com/Todd-Davies/ProgressWheel)||环形进度的UI库
[NineOldAndroids](https://github.com/JakeWharton/NineOldAndroids)|com.nineoldandroids.view|动画兼容库
[DiskLruCache](https://github.com/JakeWharton/DiskLruCache)||Android"硬盘"缓存
[ijkplayer](https://github.com/Bilibili/ijkplayer)|tv.danmaku.ijk.media.player|Bilibili开源的视频播放库
[DanmakuFlameMaster](https://github.com/Bilibili/DanmakuFlameMaster)||Bilibili开源的中二病开源弹幕引擎--烈焰弹幕
[androidquery](https://github.com/androidquery/androidquery)||轻量级的Android开源框架
[TheMVP](https://github.com/kymjs/TheMVP)|com.kymjs.themvp|一个MVP框架，支付宝已经整合到com.alipay.mobile.android.mvp
[tagsoup](https://github.com/ndmitchell/tagsoup)||html解析框架
[wire](https://github.com/square/wire)|com.squareup.wire|Clean, lightweight protocol buffers for Android and Java
[okio](https://github.com/square/okio)|okio|java IO框架
[okhttp](https://github.com/square/okhttp)|okhttp3|著名网络框架，支付宝已经整合到com.alipay.mobile.common.transportext.biz.spdy
[androidquery](https://github.com/androidquery/androidquery)|com.androidquery|Android-query框架能够快速的，比传统开发android所要编写的代码要少得很多，容易阅读
[XRecyclerView](https://github.com/jianghejie/XRecyclerView)||源码中未找到
[dagger](https://github.com/square/dagger)||依赖注入框架，源码中未找到
[androidannotations](https://github.com/androidannotations/androidannotations)|org.androidannotations|另一个注入框架
[EventBus](https://github.com/greenrobot/EventBus)||Android事件总线
[zlib](https://github.com/madler/zlib)||数据压缩用的库
[aspectj](https://github.com/eclipse/org.aspectj)|org.aspectj|面向切面的框架
[thrift](https://thrift.apache.org/)|org.apache.thrift|一个软件框架，用来进行可扩展且跨语言的服务的开发
[flexbox-layout](https://github.com/google/flexbox-layout)|com.google.android.flexbox|Google 开源的Android 排版库
[ormlite](https://github.com/j256/ormlite-android)|com.j256.ormlite|orm数据库框架
[Android-Zip4j](https://github.com/imasm/Android-Zip4j)|net.lingala.zip4j|Android带密码解压库
[AndFix](https://github.com/alibaba/AndFix)|com.alipay.euler.andfix|Android Hotfix框架

关于其他使用到第三方push库，这里就没有列出来，有兴趣的同学，可以自行研究。
## 总结
通过反编译，支付宝使用了列表中的开源框架，由于支付宝版本的不一致，和他们列出来的[支付宝 Android 版使用的开源组件](http://www.jianshu.com/p/844e338319af)，有些出入。   
从中看出，支付宝对一些大公司成熟的开源框架，比较青睐，比如google,square的一系列框架。那哪些是可以借鉴的。
### 常用库
* [JSON 解析函数库 GSON](https://github.com/google/gson)
* [JSON 解析库 fastjson](https://github.com/alibaba/fastjson)
* [SD卡缓存库 DiskLruCache](https://github.com/JakeWharton/DiskLruCache)
* [I/O 操作函数库 okio](https://github.com/square/okio)
* [Http函数库 okhttp](https://github.com/square/okhttp)
* [依赖注入库 dagger](https://github.com/square/dagger)
* [另一个依赖注入库 androidquery](https://github.com/androidquery/androidquery)
* [Android事件总线库 EventBus](https://github.com/greenrobot/EventBus)
* [orm数据库操作框架 ormlite](https://github.com/j256/ormlite-android)
* [RecyclerView操作库 XRecyclerView](https://github.com/jianghejie/XRecyclerView)
* [Android Hotfix框架 AndFix](https://github.com/alibaba/AndFix)

### 惊喜库(新学的)
* [嵌入式JavaScript引擎库 duktape-android](https://github.com/square/duktape-android)
* [MVP框架 TheMVP](https://github.com/kymjs/TheMVP)
* [面向切面库 aspectj](https://github.com/eclipse/org.aspectj)
* [Android 排版库 flexbox-layout](https://github.com/google/flexbox-layout)
* [视频播放库 ijkplayer](https://github.com/Bilibili/ijkplayer)
* [烈焰弹幕库 DanmakuFlameMaster](https://github.com/Bilibili/DanmakuFlameMaster)

关于支付宝使用的框架就分析到这里，发现支付宝使用的有些库还是非常值得参考的。下次准备分析下淘宝，看看阿里系的app有何不同之处。
