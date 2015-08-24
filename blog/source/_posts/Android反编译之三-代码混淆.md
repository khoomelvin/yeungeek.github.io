title: "Android反编译之三--代码混淆"
date: 2015-08-24 19:05:01
tags:
- android
- decompile
- tools
categories:
- tools
---
前面两篇文章，分别介绍了反编译的工具和方法，Smail的语法。前面都是如何去反编译，破解他人的应用，那如何才能防止反编译。
真是有点矛与盾的概念。
<!-- more -->
本篇介绍几种方式来防止反编译。
### ProGuard
ProGuard是免费的，在Android SDK中已经集成了，要看原始的请参考：http://proguard.sourceforge.net/。  
使用ProGuard混淆的应用，通过apktool还是可以看到Manifest和res资源，使用dex2jar也可以看到混淆后的源码，虽然大部分代码已经混淆了。还是可以看个大概，而且通过smail的修改，重新进行逆向apk。
对于一般的应用足够，而对于应用中用了很多开源项目的，在业务层进行混淆也应该足够了。

### DexGuard
DexGuard是收费的，是在Proguard基础上，加入了更多的保护措施。使用DexGuard混淆后，生成的apk文件，就无法正常使用apktool反编译了。
DexGuard：https://www.guardsquare.com/dexguard

### Native方式
代码使用Native方式实现，很多都是使用c来实现，Android上使用NDK编译生成so方式来引用。  
像QQ，微信底层的通讯都是使用了so方式实现。

### 第三方加密工具
第三方加密工具，使用第三方加密工具，隐藏classes.dex，通过动态加载的方法进一步提高应用的安全性。
国内的有，[爱加密](http://www.ijiami.cn/)
