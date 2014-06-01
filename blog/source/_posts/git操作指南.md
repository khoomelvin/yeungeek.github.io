title: Git操作指南
date: 2014-05-27 16:21:36
tags:
- git
- github
categories:
- Git
---
该文章参考了 廖学峰的[Git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)  
![](http://git-scm.com/images/logo@2x.png)  <br>
[Pro Git](http://git-scm.com/book/zh)  
![](http://git-scm.com/images/books/pro-git@2x.jpg)
##Git是什么
Git是什么？  
Git是目前世界上最先进的分布式版本控制系统（没有之一）。  
Git有什么特点？简单来说就是：高端大气上档次！
##基本概念
###版本库
什么是版本库呢？版本库又名仓库，英文名repository，你可以简单理解成一个目录，这个目录里面的所有文件都可以被Git管理起来，每个文件的修改、删除，Git都能跟踪，以便任何时刻都可以追踪历史，或者在将来某个时刻可以“还原”。  
可以通过`git stauts`查看工作区的状态，该命令可以让我们时刻掌握仓库当前的状态
```
$ git status
位于分支 master
您的分支与上游分支 'origin/master' 一致。

尚未暂存以备提交的变更：
  （使用 "git add/rm <file>..." 更新要提交的内容）
  （使用 "git checkout -- <file>..." 丢弃工作区的改动）

	删除:         "source/_posts/emacs\345\255\246\344\271\240\347\254\224\350\256\260-1-emacs\345\255\246\344\271\240\350\267\257\345\276\204.md"
	修改:         "source/_posts/git\346\223\215\344\275\234\346\214\207\345\215\227.md"

修改尚未加入提交（使用 "git add" 和/或 "git commit -a"）

```
从中可以看到当前版本库中文件的状态情况。如果要看文件具体修改了那些，使用`git diff`命令  
```
$ git diff
diff --git "a/blog/source/_posts/git\346\223\215\344\275\234\346\214\207\345\215\227.md" "b/blog/source/_posts/git\346\223\215
index f318519..c9a97bf 100644
--- "a/blog/source/_posts/git\346\223\215\344\275\234\346\214\207\345\215\227.md"
+++ "b/blog/source/_posts/git\346\223\215\344\275\234\346\214\207\345\215\227.md"
@@ -7,12 +7,31 @@ categories:
 - Git
 ---
 该文章参考了 廖学峰的[Git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)  
-![git](http://www.liaoxuefeng.com/files/attachments/0013848605496402772ffdb6ab448deb7eef7baa124171b000/0)  <br>
-[Pro Git](http://git-scm.com/book/zh)
+![](http://git-scm.com/images/logo@2x.png)  <br>
+[Pro Git](http://git-scm.com/book/zh)  
 ![](http://git-scm.com/images/books/pro-git@2x.jpg)
-###Git是什么
+##Git是什么
package
...
```
结合`git status`和`git diff`两个命令，就可以放心提交修改。
###提交日志
使用`git log`查看提交的历史记录
```
$ git log
commit c00666d9c6c078297f319a4b90674ea79beb292b
Author: yeungeek <yangjian0410@gmail.com>
Date:   Tue May 27 17:16:22 2014 +0800

    git操作指南

commit 7fec945d91b7f26f5b8beb2396527b4e4ceb77ee
Author: yeungeek <yangjian0410@gmail.com>
Date:   Tue May 27 16:20:39 2014 +0800

    del duoshuo
```
或者
```
$ git log --pretty=oneline
c00666d9c6c078297f319a4b90674ea79beb292b git操作指南
7fec945d91b7f26f5b8beb2396527b4e4ceb77ee del duoshuo
```
更有甚者,使用别名，来定义日志的格式
```
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
```
然后使用 `git lg`
```
git lg
* c00666d - (HEAD, origin/master, origin/HEAD, master) git操作指南 (5 天之前) <yeungeek>
* 7fec945 - del duoshuo (5 天之前) <yeungeek>
```
看到日志中，前面的类似md5的标记了吗，该标记就是版本。用HEAD表示当前版本，上一个版本就是HEAD^，上上一个版本就是HEAD^^，当然往上100个版本写100个^比较容易数不过来，所以写成HEAD~100。  
```
$ git reset --hard HEAD^
HEAD is now at 7fec945 git操作指南
```
这样，就回退到了上一个版本。
###工作区与暂存区
这两个概念非常重要。  
* __工作区（Working Directory）__:能够看到的目录<br/>
* __版本库（Repository）__：工作区有一个隐藏目录“.git”，这个不算工作区，而是Git的版本库。
git库中有很多重要的标记，其中最重要的就是称为stage（或者叫index）的暂存区，还有Git为我们自动创建的第一个分支master，以及指向master的一个指针叫HEAD。
![](http://www.liaoxuefeng.com/files/attachments/001384907702917346729e9afbf4127b6dfbae9207af016000/0)
###提交修改
在上面有提到,使用`git status`查看当前仓库的信息。
![](http://pic.yupoo.com/yeungeek/DNF9fOeQ/medish.jpg)
红色的文件，没有提交到暂存区中，使用`git add file` 或者使用`git add -all 路径`，让文件提交到暂存区
![](http://pic.yupoo.com/yeungeek/DNF9gN2p/medish.jpg)
变为绿色，说明文件已经在暂存区。然后，执行`git commit -m message`就可以一次性把暂存区的所有修改提交到分支。一次完整的提交完成。
###命令小结
`git status` 查看仓库的状态
`git log` 查看commit的记录
`git reset` 回退版本
`git add` 添加文件到暂存区
`git commit -m message` 提交修改到分支 

