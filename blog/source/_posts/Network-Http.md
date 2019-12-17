---
title: Android网络编程-HTTP/HTTPS
date: 2019-07-12 10:09:56
tags:
   - Network
   - Android
   - Http
   - Https
categories:
   - Android应用层
---
HTTP协议是Hyper Text Transfer Protocol（超文本传输协议）的缩写,在TCP/IP体系中属于最高层(应用层)是用于从万维网服务器传输超文本到本地浏览器的传送协议。   
HTTP协议工作于客户端-服务端架构为上。浏览器作为HTTP客户端通过URL向HTTP服务端即WEB服务器发送所有请求。Web服务器根据接收到的请求后，向客户端发送响应信息。<!--more--> 
这是最基本的HTTP工作原理，如图所示:
![C/S架构](https://s2.ax1x.com/2019/07/12/ZfgnTU.jpg)

# HTTP报文
HTTP属于应用层，应用层传输的数据单位是报文。   
HTTP报文分为请求报文和响应报文。  
## 请求报文
![请求报文](https://s2.ax1x.com/2019/07/13/Zhv4AO.jpg)
HTTP请求报文由以下4个部分组成:
* 请求行：请求类型,要访问的资源以及所使用的HTTP版本。
* 请求头部：服务器要使用的附加信息。
* 空行：请求头部后面的空行是必须的
* 请求包体：可以添加任意的其他数据

### 请求行
请求行组成：请求方法，请求URL，协议版本。
#### 请求方法
| 方法 | 作用 | 说明|
| :--- | :---- | :---- | 
|GET|获取资源|用来请求访问已被URI标识的|
|POST|传输实体主体|POST主要用来传输数据，而GET主要用来获取资源|
|HEAD|获取报文首部|和GET方法类似，但是不返回报文实体主体部分|
|PUT|上传文件|用来传输文件，由于自身不带验证机制，任何人都可以上传文件|
|DELETE|删除文件|与PUT功能相反，并且同样不带验证机制|
|OPTIONS|查询支持的方法|用来查询针对请求URI请求的资源支持的方法|
|TRACE|追踪路径|服务器会将通信路径返回给客户端|
|CONNECT|要求用隧道协议连接代理|使用 SSL（Secure Sockets Layer，安全套接层）和TLS（Transport Layer Security，传输层安全）协议把通信内容加密后经网络隧道传输|

#### 请求URL
URL(Uniform Resource Locator)统一资源定位符，表示资源的地点(互联网上的地址)。    
URI(Uniform Resource Identifier)统一资源标识符，用字符串标识某一互联网资源，URL是URI的子集。  

#### 协议版本
* HTTP/1.0：HTTP协议的第二个版本，第一个在通讯中指定版本号的HTTP协议版本，至今仍被广泛采用
* HTTP/1.1：HTTP协议的第三个版本是HTTP 1.1，是目前使用最广泛的协议版本
* HTTP/2.0：HTTP 2.0是下一代HTTP协议，目前应用还非常少

### 请求头部
请求头部由关键字/值对组成，每行一对，关键字和值用英文冒号“:”分隔。   
有4种类型的首部字段：通用首部字段、请求首部字段、响应首部字段和实体首部字段，[所有完整首部](https://cyc2018.github.io/CS-Notes/#/notes/HTTP?id=%e5%9b%9b%e3%80%81http-%e9%a6%96%e9%83%a8)   
这里我们先了解下常用的请求首部。   

| 字段 | 说明 | 
| :--- | :---- |
|Accept|用户代理可处理的媒体类型|
|Accept-Encoding|优先的内容编码<br/>Accept-Encoding: gzip, deflate, br|
|Authorization|Web 认证信息|
|Cache-Control|控制缓存的行为|
|Connection|控制不再转发给代理的首部字段、管理持久连接|
|Content-Encoding|实体主体适用的编码方式|
|Content-Type|实体主体的媒体类型|
|Content-Length|实体主体的大小|
|Host|请求资源所在服务器|
|If-Modified-Since|服务器上次返回的`Last-Modified`日期，如果在这个日期之后，<br/>请求的资源都没有更新过，则返回304 Not Modified响应|
|If-None-Match|比较实体标记，值为上一次返回的ETag，<br/>一般会和`If-Modified-Since`一起返回|
|Referer|对请求中URI的原始获取方|
|User-Agent|HTTP 客户端程序的信息|
|Cookie|保存状态信息|
|Transfer-Encoding|指定报文主体的传输编码方式|

### 请求包体
请求包体不在 GET 方法中使用，而是在POST 方法中使用。  
HTTP请求的请求体有三种不同的形式：
* 任意类型：服务器不会解析请求体，请求体的处理需要自己解析，比如JSON
* 键值对(application/x-www-form-urlencoded)：最常见的 POST 提交数据的方式，表单模式
* 文件分割：请求体被分成为多个部分，文件上传时会被使用

### 示例
使用抓包工具或者Chrome来查看
``` java
POST /getconfig HTTP/1.1
Content-Type: application/x-www-form-urlencoded
User-Agent: Dalvik/2.1.0 (Linux; U; Android 9; Redmi Note 7 MIUI/V10.3.2.0.PFGCNXM)
Host: data.mistat.xiaomi.com
Accept-Encoding: gzip
Content-Length: 205
Connection: close

app_id=1000274&app_version=10.8.3
```
* 请求行：显示Post请求，协议版本为HTTP/1.1
* 请求头部：`Content-Type`,`User-Agent`,`Host`,`Accept-Encoding`,`Content-Length`,`Connection`
* 请求体：Content-Type声明为键值对

## 响应报文
![响应报文](https://s2.ax1x.com/2019/07/13/Zhv5ND.jpg)
HTTP 响应报文由状态行、响应头部、空行和响应包体4个部分组成。
### 状态行
状态行由HTTP协议版本字段、状态码和状态码的描述文本 3 个部分组成，他们之间使用空格隔开;
协议版本和请求中的对应，状态码和描述会一一对应。
#### 状态码、描述
状态码由三位数字组成，第一位数字表示响应的类型，常用的状态码有五大类：
* 1xx：Informational（信息性状态码），接收的请求正在处理;
* 2xx：Success（成功状态码），请求正常处理完毕;
* 3xx：Redirection（重定向状态码），需要进行附加操作以完成请求;
* 4xx：Client Error（客户端错误状态码），服务器无法处理请求;
* 5xx：Server Error（服务器错误状态码），服务器处理请求出错;

常用的一些状态码和描述
##### 1xx
| 状态码、描述 | 说明 | 
| :--- | :---- |
|100 Continue|表明到目前为止都很正常，客户端可以继续发送请求或者忽略这个响应|

##### 2xx
| 状态码、描述 | 说明 | 
| :--- | :---- |
|200 OK|请求成功|
|204 No Content|请求已经成功处理，但是返回的响应报文不包含实体的主体部分|
|206 Partial Content|表示客户端进行了范围请求，<br>响应报文包含由Content-Range指定范围的实体内容|

##### 3xx
| 状态码、描述 | 说明 | 
| :--- | :---- |
|301 Moved Permanently|永久性重定向|
|302 Found|临时性重定向|
|304 Not Modified|如果请求报文首部包含一些条件，If-Match，If-Range, <br/>If-Modified-Since，If-None-Match，，If-Unmodified-Since。<br/>如果不满足条件，则服务器会返回 304 状态码|
|307 Temporary Redirect|临时重定向，与 302 的含义类似，<br/>但是307要求浏览器不会把重定向请求的POST方法改成GET方法|

##### 4xx
| 状态码、描述 | 说明 | 
| :--- | :---- |
|400 Bad Request|请求报文中存在语法错误|
|401 Unauthorized|请求需要验证用户|
|403 Forbidden|访问权限问题|
|404 Not Found||

##### 5xx
| 状态码、描述 | 说明 | 
| :--- | :---- |
|500 Internal Server Error|服务器正在执行请求时发生错误|
|503 Service Unavailable|服务器正在执行请求时发生错误|

### 响应头部
和请求头部一样，由关键字/值对组成，每行一对，关键字和值用英文冒号“:”分隔。  
常用的请求首部  

| 字段 | 说明 | 
| :--- | :---- |
|Cache-Control|控制缓存的行为|
|Connection|控制不再转发给代理的首部字段、管理持久连接|
|Transfer-Encoding|指定报文主体的传输编码方式|
|Content-Encoding|实体主体适用的编码方式|
|Content-Type|实体主体的媒体类型|
|Content-Length|实体主体的大小|
|Expires|实体主体过期的日期时间|
|ETag|资源的匹配信息，和`If-Nome-Match`对应|
|Date|服务端|创建报文的日期时间|
|Location|令客户端重定向至指定 URI|
|Server|HTTP 服务器的安装信息|
|Last-Modified|资源的最后修改日期时间|
|Set-Cookie|设置Cookie，客户端得到响应报文后把 Cookie 内容保存到浏览器中|

其他更详细的首部信息，可以参考[这里](https://cyc2018.github.io/CS-Notes/#/notes/HTTP?id=%e5%9b%9b%e3%80%81http-%e9%a6%96%e9%83%a8)   
### 响应包体
服务器返回给客户端的文本信息。
和请求包体的分类一样。

### 示例
``` java
HTTP/1.1 200 OK
Date: Sat, 13 Jul 2019 08:40:52 GMT
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Content-Encoding: gzip
Connection: close

{"errorCode":-2,"reason":"no changing","result":null}
```
* 响应行：返回响应码200 Ok，表示服务端返回数据成功
* 响应头部：Content-Type设置返回的类型为JSON格式
* 响应包体：返回具体JSON数据

# HTTPS
HTTP 有以下安全性问题：
* 使用明文进行通信，内容可能会被窃听；
* 不验证通信方的身份，通信方的身份有可能遭遇伪装；
* 无法证明报文的完整性，报文有可能遭篡改。

HTTPS 并不是新协议，而是让 HTTP 先和 SSL（Secure Sockets Layer）通信，再由 SSL 和 TCP 通信，也就是说 HTTPS 使用了隧道进行通信。   
通过使用 SSL，HTTPS 具有了加密（防窃听）、认证（防伪装）和完整性保护（防篡改）
![HTTPS](https://s2.ax1x.com/2019/07/13/Z42xPO.jpg)
## 与HTTP区别
| 协议 | 原理 | 数据格式 | 传输速度 | 端口| 
| :--- | :---- | :---- | :---- |:---- |
| HTTP| 应用层| 明文传输| 三次握手，传输三个包|80|
| HTTPS| 传输层 | SSL加密 |三次握手基础上增加ssl握手(9个包)，<br>传输12个包|443|

## 缺点
* 因为需要进行加密解密等过程，因此速度会更慢；
* 需要支付证书授权的高额费用。

# HTTP框架
## [Volley](https://github.com/google/volley)
Volley是Google 官方出的一套小而巧的异步请求库，该框架封装的扩展性很强，支持 HttpClient、HttpUrlConnection，甚至支持OKHttp。
## [OKHttp](https://github.com/square/okhttp/)
OKHttp是Square 公司开源的针对 Java 和 Android 程序，封装的一个高性能 http 请求库，所以它的职责跟 HttpUrlConnection 是一样的，支持 spdy、http 2.0、websocket ，支持同步、异步。
已被谷歌加入到Android的源码中。

## [Retrofit](https://github.com/square/retrofit)
Retrofit是Square公司出品的默认基于OKHttp 封装的一套 RESTful 网络请求框架

后续文章会从OKHttp、Retrofit角度来分析Http。

# 参考
* [Http](https://cyc2018.github.io/CS-Notes/#/notes/HTTP)
* [这是一份全面& 详细 HTTP协议 学习攻略](https://juejin.im/post/5c98306bf265da60ed6eedbc)
* [精读《图解HTTP》](https://juejin.im/post/5b32f82a518825749e4a218b)
* [HTTP 协议入门](http://www.ruanyifeng.com/blog/2016/08/http.html)