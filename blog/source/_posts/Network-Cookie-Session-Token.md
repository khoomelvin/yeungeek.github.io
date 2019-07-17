---
title: Android网络编程-Cookie，Session，Token
date: 2019-07-15 23:04:35
tags:
   - Network
   - Session
   - Cookie
   - Token
categories:
   - Android应用层
---
HTTP协议是无状态的，每次HTTP请求响应后，就会断开这次连接。如果客户端再次发送请求，服务端也不能识别出这个客户端是不是上次请求过的客户端，HTTP协议不能进行会话跟踪。而Cookie，Session，Token正是为了解决HTTP协议无状态问题。
<!-- more -->
# Cookie
Cookie机制是在客户端实现，采用客户端保持状态的方案。   
Cookie由服务端生成，发送给客户端(Set-Cookie)，客户端请求的时候会带上这个Cookie。  
请求流程： 
![请求流程](https://s2.ax1x.com/2019/07/16/ZH7XAf.png)
Cookie字段：名字、值、过期时间、路径和域。路径与域一起构成Cookie的作用范围。  
通过Chrome的开发者工具中看到，在github.com上保存在客户端的Cookie信息。  
![ZqcVOS.png](https://s2.ax1x.com/2019/07/17/ZqcVOS.png)
* Name：名字
* Value：值
* Domain：域
* Path：路径
* Expaires/Max-Age：过期时间

上图中`logged_in`和`user_session`两个Cookie值表示登录github.com后保存下来的登录状态和Session。
# Session 
Session是在服务端实现，当客户端请求服务端时，服务端会检查请求中是否包含Session标识(Session id)，
* 如果没有,那么服务端就生成一个随机的Session以及和它匹配的Session id,并将Session id返回给客户端。
* 如果有,那么服务器就在存储中根据Session id 查找到对应的Session。

# Token
Token也称作令牌，由uid+time+sign[+固定参数]组成:
* uid：用户唯一身份标识
* time：当前时间的时间戳
* sign：签名, 使用 hash/encrypt 压缩成定长的十六进制字符串，可以防止恶意第三方拼接Token请求服务器

以下几点特性会让你在程序中使用基于Token的身份验证：
* 无状态、可扩展
* 支持移动设备
* 跨程序调用
* 安全

Token是有客户端来保存，用户的状态在服务端的内存中是不存储的，所以这是一种无状态的认证机制。而认证的具体流程如下：
> 客户端使用用户名跟密码请求登录
服务端收到请求，去验证用户名与密码
验证成功后，服务端会签发一个 Token，再把这个 Token 发送给客户端
客户端收到 Token 以后可以把它存储起来，比如放在 Cookie 里或者 Local Storage 里
客户端每次向服务端请求资源的时候需要带着服务端签发的 Token
服务端收到请求，然后去验证客户端请求里面带着的 Token，如果验证成功，就向客户端返回请求的数据  

## 第三方授权登录
这是Token的一种应用场景，使用OAuth实现。 
OAuth（开放授权）是一个开放标准，允许用户让第三方应用访问该用户在某一网站上存储的私密的资源（如照片，视频，联系人列表），而无需将用户名和密码提供给第三方应用。   
OAuth允许用户提供一个令牌，而不是用户名和密码来访问他们存放在特定服务提供者的数据。   
我们看下github的授权流程：
![Zq5gJg.png](https://s2.ax1x.com/2019/07/17/Zq5gJg.png)
> 图片来源：[github 授权登录教程与如何设计第三方授权登录的用户表](https://juejin.im/post/5c7bd93751882545194f88cb)

# 区别
## Cookie和Session
| 维度 | Cookie | Sesson|
| :--- | :---- | :---- | 
|存放位置|客户端|服务端|
|存取方式|只能保管ASCII字符串|任何类型的数据|
|安全性|对客户端是可见的，<br>客户端的一些程序可能会窥探、<br>复制以至修正Cookie中的内容|对客户端是透明的，<br>不存在敏感信息泄露的风险|
|有效期|可以保持很长时间不过期|依赖于JSESSIONID的Cookie，<br>默许过期时间为–1，<br>只需关闭了浏览器，该Session就会失效|
|跨域支持|支持跨域名访问|仅在它所在的域名内有效|

## Token和Session
作为身份认证Token安全性比Session好。  
Session是一种HTTP存储机制，目的是为无状态的HTTP提供的持久机制。  
Token,如果指的是OAuth Token 或类似的机制的话，提供的是`认证`和`授权` ，认证是针对用户，授权是针对App。 

# 参考
* [Cookie、Session、Token那点事儿](https://www.jianshu.com/p/bd1be47a16c1)
* [彻底理解cookie，session，token](https://www.cnblogs.com/moyand/p/9047978.html)
* [精读《图解HTTP》](https://juejin.im/post/5b32f82a518825749e4a218b)

