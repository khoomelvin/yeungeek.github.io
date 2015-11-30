title: "Android反编译之一--反编译的工具和方法"
date: 2015-08-22 21:59:24
tags:
- android
- decompile
- tools
categories:
- tools
---

如果看到一个好的应用，作为一个开发者，是不是很有兴趣去分析它是怎么实现的。尤其是Android应用，通常都是通过反编译来分析其中的结构。
<!-- more -->
分析一个Android应用，一是Android的资源，另一个就是源码。

## 资源工具
### Apktool
Apktool是目前强大的反编译工具，可以反编译出apk，解析出`resources.arsc, classes.dex, 9.png. and XMLs`资源，Smali文件，并且可以重新进行打包

工具地址：http://ibotpeaches.github.io/Apktool/

使用方式：  
``` shell
apktool d test.apk
```
反编译出apk

```
apktool b test
```
对反编译出的进行逆向apk

### 源码工具
#### dex2jar
从Apk中解压出class.dex，使用dex2jar进行源码解析。
``` java
dex2jar class.dex
```
在当前目录生成classes.dex.dex2jar.jar，可以在jd-gui中查看源码。  

dex2jar：https://github.com/pxb1988/dex2jar  
jd-gui下载:http://jd.benow.ca/http://jd.benow.ca/  
jd-gui源码：https://github.com/java-decompiler/jd-gui

#### enjarify
这是是谷歌出品的一款反编译工具,它可以将dalvik字节码转化成 java 字节码。  
使用方式：
``` java
enjarify yourapp.apk
enjarify classes2.dex
enjarify yourapp.apk -o yourapp.jar
```
跟dex2jar相比，成功率更高，具体的查看：[why-not-dex2jar](https://github.com/google/enjarify#why-not-dex2jar)

#### android-classyshark
最近谷歌出的一款查看和分享android文件(APK/Zip/Class/Jar)的工具
![](https://github.com/google/android-classyshark/raw/master/Resources/ClassySharkAnimated.gif)

### 整合工具
#### onekey-decompile-apk
一步到位反编译apk工具
![](https://camo.githubusercontent.com/94e56266cf1b311471e05fb77d9bac7d74b8f2a7/68747470733a2f2f7261776769742e636f6d2f75666f6c6f676973742f6f6e656b65792d6465636f6d70696c652d61706b2f6d61737465722f676f6f676c652d636f64652e706e67)

## 参考
* [android反编译-smali语法](http://blog.isming.me/2015/01/11/android-decompile-tools/)
