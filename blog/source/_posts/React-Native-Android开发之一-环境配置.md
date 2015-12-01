title: "React Native Android开发之一: 环境配置"
date: 2015-12-01 18:24:01
tags:
- android
- js
- react native
- nodejs
categories:
- android

---
>React Native使你能够在Javascript和React的基础上获得完全一致的开发体验，构建世界一流的原生APP。  
>React Native着力于提高多平台开发的开发效率 —— 仅需学习一次，编写任何平台。(Learn once, write anywhere)  
>Facebook已经在多项产品中使用了React Native，并且将持续地投入建设React Native。  
>                                                         ---- from [React Native 中文网](http://react-native.cn/)


<!-- more -->
上诉就是React Native的特色。  
Facebook 于2015年9月15日推出 React Native for Android 版本。相比较于iOS，在Android上，尤其是在Windows上跑Demo。
真的很多情况都遇到了，接下来就介绍在Windows上搭建React Native Android的环境。

## 环境需求
按照官方的引导，基本是在OS X上进行的，OS X上没有去实验过，有兴趣查看参考: [OS X环境需求](http://react-native.cn/docs/getting-started.html#%E7%8E%AF%E5%A2%83%E9%9C%80%E6%B1%82)  
不管开发Android或者iOS,弄台Mac还是很有必要的，事半功倍啊。  
下面主要介绍下Windows上安装环境的过程。

### Android SDK
这个默认大家都已经设置完成，注意点，一定要注意版本:
* Android SDK Build-tools version 23.0.1
* Android Support Repository
* Android 4.1上

### 安装Node.js
从官网下载[https://nodejs.org/](https://nodejs.org)下载，需要4.0或以上。
安装完成后，检查命令行是否可用
``` shell
λ node -v
v4.2.2
λ npm -version
2.14.7
```
### 安装react-native-cli
命令行输入：
``` shell
$ npm install -g react-native-cli
```
### 运行环境
运行环境，一个是使用模拟器，一个是使用真机。
#### 模拟器
现在 [Genymotion](https://www.genymotion.com/)可以说是最方便的模拟器，可以下载各种android版本，来创建虚拟设备。
## 初始化项目
初始化RN项目
``` java
$ react-native init AwesomeProject
```
耐心等几分钟。如果出现很久还没有初始化成功，可以试试国内的镜像。
> npm config set registry https://registry.npm.taobao.org
> npm config set disturl https://npm.taobao.org/dist

### 项目结构
``` shell
total 11
drwxr-xr-x    1 yeungeek Administ     4096 Dec  1 16:44 ./
drwxr-xr-x    4 yeungeek Administ        0 Nov 30 11:30 ../
-rw-r--r--    1 yeungeek Administ     1501 Nov 30 11:33 .flowconfig
-rw-r--r--    1 yeungeek Administ      341 Nov 30 11:33 .gitignore
drwxr-xr-x    1 yeungeek Administ     4096 Dec  1 19:02 .idea/
-rw-r--r--    1 yeungeek Administ        2 Nov 30 11:33 .watchmanconfig
drwxr-xr-x    1 yeungeek Administ     4096 Dec  1 17:22 android/
-rw-r--r--    1 yeungeek Administ     1084 Dec  1 16:44 index.android.js
-rw-r--r--    1 yeungeek Administ     1065 Nov 30 11:33 index.ios.js
drwxr-xr-x    1 yeungeek Administ        0 Nov 30 11:33 ios/
drwxr-xr-x    1 yeungeek Administ        0 Nov 30 11:33 node_modules/
-rw-r--r--    1 yeungeek Administ      181 Nov 30 11:33 package.json
```
看到有个平台目录，android和ios，以及对应的index.android.js和index.ios.js文件。
## 运行项目
接下来就是我的填坑之旅了，看到其他人介绍到这步后，然后直接运行
```  java
react-native run-android
```
然后就app就直接可以启动了。不过我遇到了下面的这个问题。
### 坑-红色的unload
![](http://pic.yupoo.com/yeungeek/F8ZvRRpy/medish.jpg)
根据提示，去设置菜单Dev Settings，设置为本机的ip。依然是红色，那就先拦截下包吧，看看请求返回了那些信息
![](http://pic.yupoo.com/yeungeek/F8ZCfDoQ/medish.jpg)
404错误，模拟器上不能访问该ip地址  

React Native使用的nodejs的服务，看看它是如何启动server的。
看了下刚才工程node_modules，看了下跟server有关的就是runServer.js和server.js
![](http://pic.yupoo.com/yeungeek/F8ZEc3o7/medish.jpg)
在runServer.js中有声明如何启动http服务：
``` nodejs
const serverInstance = http.createServer(app).listen(
    args.port,
    '::',
    function() {
      wsProxy = webSocketProxy.attachToServer(serverInstance, '/debugger-proxy');
      webSocketProxy.attachToServer(serverInstance, '/devtools');
      readyCallback();
    }
  );
```
其中listen接口，参考[server.listen(port[, hostname][, backlog][, callback])](https://nodejs.org/api/http.html#http_server_listen_port_hostname_backlog_callback)
>the server will accept connections on any IPv6 address (::) when IPv6 is available, or any IPv4 address (0.0.0.0) otherwise. A port value of zero will assign a random port.

这里说明使用`::`表明监听IPv6地址，当前我的环境IPv6网络无法连接。
所以考虑使用IPv4来试试。修改`::`为`0.0.0.0`，重新启动`react-native start`
but
``` java
 ERROR  Packager can't listen on port 8081
```
查看端口占用情况
``` shell
λ netstat -ano|findstr "8081"
  TCP    0.0.0.0:8081           0.0.0.0:0              LISTENING       3556
```
而且在系统管理器中，根本找不到PID为3556的应用，那能更改端口吗?
在server.js中有声明:
``` java
const args = parseCommandLine([{
    command: 'port',
    default: 8081,
    type: 'string',
  }, {
```
修改`8081`为`8080`，重新启动`react-native start`
然后重新设置Dev Settings。
结果：
![](http://pic.yupoo.com/yeungeek/F90hBpl0/medish.jpg)
成功了!

>这里想说明下，这个过程只是整理了React Native Android连接的http服务，和查找问题的过程。
以做参考

## 参考
* [React Native 中文网](http://react-native.cn/)
* [使用 JS 构建跨平台的原生应用（一）：React Native for Android 初探](http://taobaofed.org/blog/2015/11/18/react-native-for-android-hello-world/)
* [使用 JS 构建跨平台的原生应用（二）：React Native for Android 调试技术剖析](http://taobaofed.org/blog/2015/11/25/react-native-android-debug/)
* [ReactNative Android 10个最常见问题](https://github.com/yipengmu/ReactNative_Android_QA)
