title: "基于Github参与开源项目指南"
date: 2015-07-01 15:15:00
tags:
- github
categories:
- github
---


现在使用github是越来越多，一个程序员说是不知道github，都不好意思出门。

很久前也通过github参与过，eoe Android客户端的开源项目。当时就有一篇文章讲述了如何基于Github参与eoe开源项目的指南  
不过现在已经找不到该文章了，本篇就来回顾下，如何基于Github参与开源项目。
<!-- more -->
#步骤
1. 每个人都可以fork一份自己的repo，所有的修改都在自己私有的repo上进行
2. 修改完成，或者完成一个功能，测试通过后，给主repo发起pull request请求合并
3. 主repo的会受到pull request请求，review代码后再进行代码合并
4. 个人的repo及时与主repo保持同步

本篇文章的主repo以[android-Ultra-Pull-To-Refresh](https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh)为例子。
#fork repo
打开主repo，![](http://pic.yupoo.com/yeungeek/ELH9M4eJ/medish.jpg)
点击 fork，就可以fork一份代码到自己的repo中，我已经fork了一份代码 [https://github.com/yeungeek/android-Ultra-Pull-To-Refresh](https://github.com/yeungeek/android-Ultra-Pull-To-Refresh)
#clone repo
在上一步已经fork了一份代码，现在clone自己fork出来的repo。一般我们都使用ssh协议的地址。
[git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git](git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git)
``` groovy
λ git clone git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git
Cloning into 'android-Ultra-Pull-To-Refresh'...
remote: Counting objects: 2265, done.
remote: Compressing objects: 100% (21/21), done.
```
#查看和添加远程分支
进入刚才clone的项目中，查看当前的分支情况：
``` groovy
λ git remote -v
origin  git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git (fetch)
origin  git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git (push)
```
默认的就是origin，为了能够和远程的主repo保持代码同步，需要添加一个远程的repo地址：
``` groovy
λ git remote add ptr git@github.com:liaohuqiu/android-Ultra-Pull-To-Refresh.git
λ git remote -v
origin  git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git (fetch)
origin  git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git (push)
ptr     git@github.com:liaohuqiu/android-Ultra-Pull-To-Refresh.git (fetch)
ptr     git@github.com:liaohuqiu/android-Ultra-Pull-To-Refresh.git (push)
```
ok,远程repo地址添加成功，为了保持当前的本地repo是最新，需要获取主仓库的最新代码。
#获取主repo代码
``` groovy
λ git fetch ptr
...
```
因为我已经是最新的代码，所以没有代码更新
#合并到自己的repo
``` groovy
λ git merge ptr/master
Already up-to-date.
```
如果代码有更新，执行该命令，可以合并代码到自己的repo中
#本地repo修改，提交到自己的repo
本地代码保持最新，现在就可以修改和添加代码了，没错，你可以开始贡献代码了。
我是提交了一个在utrla中，增加recyclerView的demo。
``` groovy
λ git status
On branch master
Your branch is up-to-date with 'origin/master'.

Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   ptr-demo/src/in/srain/cube/views/ptr/demo/ui/classic/WithRecyclerView.java

λ git commit -m "format code"
 [master 85f4233] format code
 1 file changed, 2 deletions(-)
λ git push
Counting objects: 112, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (7/7), done.
Writing objects: 100% (13/13), 798 bytes | 0 bytes/s, done.
Total 13 (delta 6), reused 0 (delta 0)
To git@github.com:yeungeek/android-Ultra-Pull-To-Refresh.git
   c6f0f2f..85f4233  master -> master
```
ok，已经把本次的代码修改，提交到自己的repo
#给主repo发送pull request
![](http://pic.yupoo.com/yeungeek/ELHkffYI/medish.jpg)
打开自己的repo，发现有个红色框里面的提醒，点击pull request，可以跳转到提交pull request的页面

pull request情况：
![](http://pic.yupoo.com/yeungeek/ELHl7mjP/medish.jpg)
#主repo收到pull request，merge代码
这步是主repo的管理进行操作的，我也是刚刚pull request过去。
等主repo的管理员review代码后，认为可以merge，那整个过程就ok了。

经过以上几步，整个过程完成了，基于Github参与开源项目的过程就是这样，希望对大家有些帮助。
这里非常感谢eoe的 [iceskysl](https://github.com/IceskYsl)，是他让我第一次能够参与开源项目

#参考
>声明：eoe文章著作权属于作者，受法律保护，转载时请务必以超链接形式附带如下信息  
原文作者： [iceskysl](https://github.com/IceskYsl)
原文地址： http://my.eoe.cn/iceskysl/archive/3195.html
