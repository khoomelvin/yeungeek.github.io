title: Android studio常用快捷键
date: 2014-06-06 13:50:03
tags:
- android
- tools
categories:
- Android studio

description:

---
> Android Studio 是谷歌基于IntelliJ IDEA开发的安卓开发工具，有点类似 Eclipse ADT，Android Studio 提供了集成的 Android 开发工具用于开发和调试，基于Gradle的构建支持。快捷键对于我们来说，可以让工作事半功倍。  

Eclipse中快捷键与Studio中的差别还是比较大，通过对比两者，让记忆更深刻。  
参考：[Eclipse快捷键指南](http://baike.baidu.com/view/2287016.htm),
[Android Studio 快捷键](http://www.eoeandroid.com/forum.php?mod=viewthread&tid=276107)
## 常用快捷键
显示快捷键列表：Ctrl+Shift+L (Eclipse)  

功能 | Eclipse | Android studio
----|------|----
打开资源 | Ctrl+Shift+R  | Ctrl+Shift+N
打开类型 | Ctrl+Shift+T  | Ctrl+N
导入包 | Ctrl+Shift+M  | Alt+回车
显示当前文件的结构 | Ctrl＋O  | Ctrl＋F12
格式化代码 | Ctrl+Shift+F  | Ctrl+Alt+L(与Ubuntu中锁屏键冲突)
组织导入 | Ctrl+Shift+O  | Ctrl+Alt+O
当前行的内容往上或下移动 | Alt+方向键  | Ctrl+Shift+方向键
自动生成get set方法 | Alt+Shift+s 再按 r  | Alt＋Insert
重命名 | Alt+Shift+R | Shift+F6
代码助手 | Alt+/  | Ctrl+Shift+Space 自动补全代码
||Ctrl+空格 代码提示 (会与输入法切换有冲突)
||Ctrl+Alt+Space 类名或接口名提示
||Ctrl+P 方法参数提示
行操作 | Ctrl+D 删除行 | Ctrl+X 删除行
||Ctrl+D 复制行
定位在某行 | Ctrl+L |
返回至上次浏览的位置 | Alt+ left/right   | Ctrl+Alt+ left/right(与ubuntu切换视图冲突)
注释 | Ctrl+/ 注释当前行  | Ctrl+/ 或 Ctrl+Shift+/ （// 或者/*...*/ ）

##调试
| 功能        | Eclipse          | Android studio  |
| ------------- |:-------------:| -----:|
| 运行程序     | Ctrl+F11 | Shift+F10运行当前，Alt+Shift+F10选择运行程序|
| 单步跳入     | F5      |   F7 |
| 单步执行 | F6      |    F8 |
| 单步返回     | F7      |   Shift+F8 |
| 继续 | F8      |    F9 |
| 查看变量      | Shift+Ctrl+I      |   Alt+F10 |
| 计算 |       |    Alt+F8 |

##Stuido特殊
Ctrl+Q    快速的查看的 类，函数的 文档问信息描述  
Ctrl+P 方法参数提示  
Alt+ left/right 切换代码视图  
Alt+ Up/Down 在方法间快速移动定位  
Alt+1 最大化当前的Edit或View (再按则反之)  
Ctrl+E或者Alt+Shift+C 最近更改的代码  

一些基本的快捷键，如果需要完整的快捷键，可以边学边深入。

#补充
目前正在mac使用android studio，很多快捷键不同，我使用的是Mac OS X 10.5+。  
顺便提醒下，android studio 1.0.2也发布了(12.18)。  
官网上的下载 [http://developer.android.com/sdk/index.html](http://developer.android.com/sdk/index.html)  
最新版下载：[http://tools.android.com/download/studio/canary/1-0-2
](http://tools.android.com/download/studio/canary/1-0-2
)

![image](http://pic.yupoo.com/yeungeek/Ejh26v9O/medish.jpg)

##快捷键补充(mac)
上次对比的是eclipse与studio之间的区别，下面的是studio在max和linux平台之间的差异.

功能 | Mac OSX | Linux
----|------|----
注释代码(// 单行) | Cmd + /  | Ctrl + /
注释代码(/**/ 多行) | Cmd + Option + /  | Ctrl + Shift + /
显示注释文档|F1|Ctrl + Q
显示当前文件的结构|Cmd + F12| Ctrl + F12
格式化代码|Cmd + Option + L|Ctrl + Alt + L
组织导入|Option + Control + O|Alt + Ctrl + O
上下移动代码|Option + Shift + Up/Down|Alt + Shift + Up/Down
删除行|Cmd + Delete(Cmd + X)|Ctrl + Y
快捷生成结构体|Cmd + Option + T	|Ctrl + Alt + T
快捷覆写方法|	Ctrl + O	|Ctrl + O
自动生成或覆盖父类方法|Cmd + N|Alt＋Insert
大小写转换	|Cmd + Shift + U	|Ctrl + Shift + U

**部分参考[Android Studio系列教程三--快捷键](http://stormzhang.com/devtools/2014/12/09/android-studio-tutorial3/)**
##自动导包
这个功能参考了上面的文档后，发现也很实用，不然每次都需要使用`Alt + Enter`来导入包。  
**Preferences -> Editor -> Auto Import -> Java**，如图：

![image](http://pic.yupoo.com/yeungeek/EjhcrkHo/medish.jpg)
