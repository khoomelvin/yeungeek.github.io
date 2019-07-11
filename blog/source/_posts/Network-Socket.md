---
title: Android网络编程-Socket
date: 2019-06-26 20:18:07
tags:
   - Network
   - Android
   - Socket
categories:
   - Android应用层
---
Socket在Android网络编程中，有着非常重要的作用。
# Socket基本概念
即套接字，是应用层 与 TCP/IP 协议族通信的中间软件抽象层，表现为一个封装了 TCP / IP协议族 的编程接口（API）。   
从设计模式的角度看来，Socket其实就是一个门面模式，它把复杂的TCP/IP协议族隐藏在Socket接口后面，对用户来说，一组简单的接口就是全部，让Socket去组织数据，以符合指定的协议。
<!--more-->
借用下网上结构图:
![Socket](https://s2.ax1x.com/2019/07/10/Z6bGHx.png)
IP地址和端口号组成了Socket，都是成对出现。
``` java
Socket ={(IP地址1:PORT端口号)，(IP地址2:PORT端口号)}
```
单独的Socke是没用任何作用的,基于一定的协议（TCP或者UDP）下的Socket编程才能进行数据传输。
# Socket工作流程
![Socket工作流程](https://s2.ax1x.com/2019/07/11/ZR3W2n.jpg)
服务端先初始化Socket，然后与端口绑定(bind)，对端口进行监听(listen)，调用accept阻塞，等待客户端连接。  
客户端初始化一个socket，然后连接服务器(connect)，如果连接成功，这时客户端与服务端的连接就建立了。  
客户端发送数据请求，服务端接收请求并处理请求，然后把回应数据发给客户端，客户端读取数据，最后关闭数据，一次交互结束。

## 分类
Socket使用类型有两种：
* 基于TCP协议，流套接字，采用流的方式提供可靠的字节流服务
* 基于UDP协议，数据报套接字，采用数据报文提供数据打包发送的服务

# 基于TCP的Socket编程
## 主要API
### Socket
#### 构造方法
``` java
public Socket(String host, int port)
        throws UnknownHostException, IOException
```
创建流套接字并将其连接到指定主机上的指定端口号。
* `host`: 主机地址
* `port`: 端口号

#### getInputStream
返回Socket的输入流，用户接受数据。
#### getOutputStream
返回Socket的输出流，用于发送数据。

### ServerSocket
Socket的服务端实现
#### 构造函数
```java
public ServerSocket(int port) throws IOException
```
创建服务端Socket，绑定到指定端口。
* `port`: 端口号

#### accept
``` java
public Socket accept() throws IOException
```
监听并接受到此套接字的连接。该方法将阻塞，直到建立连接。

## 示例
### 服务端
``` java
public class Server {
    public static void main(String[] args) throws IOException {
        //1. 创建ServerSocket
        ServerSocket serverSocket = new ServerSocket(8888);
        //2. 监听
        Socket socket = serverSocket.accept();
        System.out.println("server start listen");
        //3. 输入流
        InputStream is = socket.getInputStream();
        InputStreamReader reader = new InputStreamReader(is);
        BufferedReader br = new BufferedReader(reader);
        String content = null;
        StringBuffer sb = new StringBuffer();
        while ((content = br.readLine()) != null) {
            sb.append(content);
        }

        System.out.println("server receiver: " + sb.toString());

        socket.shutdownInput();

        br.close();
        reader.close();
        is.close();

        socket.close();
        serverSocket.close();
    }
}
```
非常简单的Socket服务端，接收到客户端的数据，就会关闭当前的连接。这个示例只是展示了一个完整的流程。  
如果需要复杂的服务端实现，可以使用Netty、Mina或者其他Socket框架。

### 客户端
``` java
//1. 创建客户端
Socket socket = new Socket("your ip", 8888);
//2. 输出流
OutputStream os = socket.getOutputStream();
//3. 发送数据
os.write("Hello world".getBytes());
System.out.println("send message");
os.flush();

socket.shutdownOutput();

os.close();
socket.close();
```
客户端就是连接后，发送了一份数据，就关闭连接了。
这样就实现了客户端和服务端的通信。

# 基于UDP的Socket编程
## 主要API
### DatagramPacket
用来包装接收和发送的数据。
* 构造接收数据包

``` java
public DatagramPacket(byte[] buf,int length)
```
用来接收长度为 length 的数据包。
* 构造发送数据包

``` java
DatagramPacket(byte[] buf, int length,SocketAddress address)
DatagramPacket(byte[] buf, int length, InetAddress address, int port)
```
用来将长度为 length 的包发送到指定主机上的指定端口号。
### DatagramSocket
用来发送和接收数据报包的套接字。
#### 构造方法
``` java
//创建数据报套接字并将其绑定到本地主机上的指定端口
DatagramSocket(int port)  

//创建数据报套接字，将其绑定到指定的本地地址
DatagramSocket(int port, InetAddress laddr)     
```
#### 发送数据
``` java
void send(DatagramPacket p)
```
DatagramPacket 包含的信息指示：将要发送的数据、其长度、远程主机的 IP 地址和远程主机的端口号

#### 接收数据
``` java
void receive(DatagramPacket p) 
```
当此方法返回时，DatagramPacket的缓冲区填充了接收的数据。
## 示例
### 服务端
``` java
public class UDPServer {
    public static void main(String[] args) throws IOException {
        byte[] buf = new byte[1024];
        // receive
        // 1.create
        DatagramPacket packet = new DatagramPacket(buf, buf.length);
        // 2.create udp socket
        DatagramSocket socket = new DatagramSocket(8888);
        // 3. receive start
        socket.receive(packet);
        // 4. receive data
        System.out.println("sever: " + new String(buf, 0, buf.length));

        // send
        DatagramPacket p = new DatagramPacket(buf, buf.length, 
                        packet.getAddress(), packet.getPort());
        socket.send(p);
        socket.close();
    }
}
```

### 客户端
``` java
// send
InetAddress address = InetAddress.getByName("your ip");
//1.create packet
DatagramPacket packet = new DatagramPacket(bytes, bytes.length, address, 8888);
//2.create socket
DatagramSocket socket = new DatagramSocket();
//3.send data
socket.send(packet);
// receive
//1.create packet
final byte[] bytes = new byte[1024];
DatagramPacket receiverPacket = new DatagramPacket(bytes, bytes.length);
socket.receive(receiverPacket);
System.out.println("client: " + new String(bytes, 0, bytes.length));

socket.close();
```
客户端和服务端的实现，都比较简单。

关于Socket编程，就介绍好了，这篇只是开了头，最主要的还是得去项目中实践。
# 参考
* [Android：这是一份很详细的Socket使用攻略](https://www.jianshu.com/p/089fb79e308b)
* [Scoket编程](https://hit-alibaba.github.io/interview/basic/network/Socket-Programming-Basic.html)
