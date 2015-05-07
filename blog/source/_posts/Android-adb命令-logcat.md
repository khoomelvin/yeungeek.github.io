title: Android adb命令--logcat
date: 2014-12-18 16:44:15
tags:
- android
- adb
categories:
- adb

---
  Android日志系统提供了记录和查看系统调试信息的功能。缓冲区可以通过 `adb logcat` 命令来查看和使用。  

#使用logcat命令
  通过logcat命令来查看日志内容，命令行输入:
  ``` android
  adb logcat
  ```
  通过`-help`查看`logcat`的用法
  ``` android
  Usage: logcat [options] [filterspecs]
  ```
  <!-- more -->
##options
  ``` android
  -s              Set default filter to silent.
                  Like specifying filterspec '*:s'
  -f <filename>   Log to file. Default to stdout
  -r [<kbytes>]   Rotate log every kbytes. (16 if unspecified). Requires -f
  -n <count>      Sets max number of rotated logs to <count>, default 4
  -v <format>     Sets the log print format, where <format> is one of:

                  brief process tag thread raw time threadtime long

  -c              clear (flush) the entire log and exit
  -d              dump the log and then exit (don't block)
  -t <count>      print only the most recent <count> lines (implies -d)
  -g              get the size of the log's ring buffer and exit
  -b <buffer>     Request alternate ring buffer, 'main', 'system', 'radio'
                  or 'events'. Multiple -b parameters are allowed and the
                  results are interleaved. The default is -b main -b system.
  -B              output the log in binary
  ```
  * -s 过滤器的模式，与后面介绍的过滤模式`*:s`等同
  * -f 输出到文件
  * -v 输出的日志格式
  * -c 清除缓冲区
  * -b 选择缓冲区
  * -B 二进制输出

###控制日志格式
  日志消息在标记和优先级之外还有很多元数据字段，这些字段可以通过修改输出格式来控制输出结果， -v 选项加上下面列出的内容可以控制输出字段：
  ``` shell
  brief — 显示优先级/标记和原始进程的PID (默认格式)
  process — 仅显示进程PID
  tag — 仅显示优先级/标记
  thread — 仅显示进程：线程和优先级/标记
  raw — 显示原始的日志信息，没有其他的元数据字段
  time — 显示日期，调用时间，优先级/标记，PID
  long —显示所有的元数据字段并且用空行分隔消息内容
  ```
  例如使用`process`输出格式：
  ``` android
  adb logcat -v process
  ```
###查看其他日志缓冲区
Android日志系统为日志消息保持了多个循环缓冲区，而且不是所有的消息都被发送到默认缓冲区，要想查看这些附加的缓冲区，可以使用-b 选项，以下是可以指定的缓冲区：
    ``` android
radio — 查看包含在无线/电话相关的缓冲区消息
events — 查看事件相关的消息
main — 查看主缓冲区 (默认缓冲区)
    ```
例如查看`radio`缓冲区：
	``` android
	adb logcat -b radio
	```
##filterspecs(过滤日志输出)
过滤日志的格式 `<tag>[:priority]`.
###priority(优先级别)
``` shell
V — 明细 (最低优先级)
D — 调试
I — 信息
W — 警告
E — 错误
F — 严重错误
S — 无记载 (最高优先级, 在这个级别上不会打印任何信息)
```
###按标签名过滤
``` shell
adb logcat -s TAG_NAME
adb logcat -s TAG_NAME_1 TAG_NAME_2

#example
adb logcat -s TEST
adb logcat -s TEST MYAPP
```
`-s` 用于设置所有标记的日志优先级为S,与 `*:S`类似。  
使输出符合指定的过滤器设置的一种推荐的方式，这样过滤器就成为了日志输出的“白名单”
###按优先级过滤
指定优先级输出:
``` shell
adb logcat "*:PRIORITY"

# example
adb logcat "*:W"
```

###标签和优先级组合过滤
``` shell
adb logcat -s TAG_NAME:PRIORITY  
adb logcat -s TAG_NAME_1:PRIORITY TAG_NAME_2:PRIORITY`
# example  
adb logcat -s TEST: W
```
###grep关键字过滤
使用grep进行关键字的过滤，这个非常实用，指定关键字。
``` shell
adb logcat | grep "SEARCH_TERM"
adb logcat | grep "SEARCH_TERM_1\|SEARCH_TERM_2"

# example
adb logcat | grep "Exception"
adb logcat | grep "Exception\|Error"
```
#第三方工具
##IDE
通常的一些开发工具都是集成了logcat的输出。  
eclipse和android studio都有集成了。而且过滤的方法都是比较简单，下面主要看下android studio下的工具  .
通过ddms中看到，设备和对应的app名称
![adb输出](http://pic.yupoo.com/yeungeek/Ei2ZNbaS/medish.jpg)
*filter配置：*
![filter配置](http://pic.yupoo.com/yeungeek/Ei31D1xs/medish.jpg)
##命令行封装
###pidcat
[pidcat](https://github.com/JakeWharton/pidcat)
用法：
``` shell
pidcat com.github.glomadrian.mvpcleanarchitecture
```
![pidcat](http://pic.yupoo.com/yeungeek/Ei33QObV/gzTdO.jpg)
###logcat-color
[logcat-color](https://github.com/marshall/logcat-color)
logcat-color的用法相对比较复杂，感兴趣的同学可以自行研究.
#参考
* [adb logcat 查看日志](http://blog.csdn.net/xyz_lmn/article/details/7004710)
* [Android ADB常用命令](http://segmentfault.com/a/1190000000426049)


了解了adb logcat的使用方法，通过查看日志，及时发现隐藏的问题.希望上面的一些能够帮助到你.
