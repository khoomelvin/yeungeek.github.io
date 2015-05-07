title: Markdown--入门指南
date: 2014-05-16 10:28:15
tags:
- Markdown
- github
- git
categories:
- Markdown
description:

  Markdown是一种轻量级的「标记语言」，目标是实现「易读易写」。这篇文章主要介绍Markdown语法的简要规则
---
> [Markdown](http://zh.wikipedia.org/wiki/Markdown)是一种轻量级的「标记语言」，目标是实现「易读易写」。我使用改语言，主要的目的还是因为github的缘故。所以了解一些Markdown的一些基本语法，就是非常有必要了。
<!-- more -->

# 一. Markdown语法的简要规则
## 标题
标题是非常重要的一个标记，一段文字标记为标题，只需要在文字前加 `#`。具体可以支持到1到6个`#`
```
  # 一级标题
  ## 二级标题
  ### 三级标题
  #### 四级标题
```
建议在`#`后，最好加入一个空格，这是Mardown的标准写法
## 列表
列表主要两种类型，无序和有序。无序的只要在文字前加`-`或者`*`，有序的是使用`1.`,`2.`,`3.`标记。
无序效果：
- 效果1
- 效果2
- 效果3

有序效果：
1. 效果1
2. 效果2
3. 效果3

## 引用
要引用一段文字，在文字前使用标记`>`
![引用](http://pic.yupoo.com/yeungeek/DL9g4bQW/medish.jpg)
## 图片与链接
图片和链接是非常必要，两者之间很相近，就相差一个`!`  
图片：`![]()`  
链接: `[]()`
## 粗体与斜体
粗体与斜体也比较简单，两个`*`或`_`包含一段文本就是粗体，一个`*`或`_`包含一段文本就是斜体  
**粗体**   _斜体_
## 表格
表格看起来是特别麻烦，所以就直接copy模块，然后进行修改。
```
dog | bird | cat
----|------|----
foo | foo  | foo
bar | bar  | bar
baz | baz  | baz
```
dog | bird | cat
----|------|----
foo | foo  | foo
bar | bar  | bar
baz | baz  | baz
```
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
```
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
看到效果了吧，如果让标题居中，加`:-------------:`，右对齐`-----:`
## 代码框
这个我们程序猿必须要的，[hexo](http://hexo.io/docs/writing.html#Code_Highlighting) 中定义了两种:  
**Backtick Code Block**  
{% code %}
code snippet
{% endcode %}  
**Swig Code Block**
## 分割线
分割线的语法只需要三个 `*` 号
***
分割线
***

![马克飞象](http://pic.yupoo.com/yeungeek/DL9wYPS8/medish.jpg)
ok,基本的介绍到这里
## 视频
youtube:
```
<iframe width="420" height="315" src="http://www.youtube.com/embed/QH2-TGUlwu4" frameborder="0" allowfullscreen></iframe>
```

# 二. 相关推荐
- [Markdown——入门指南| 简书](http://jianshu.io/p/1e402922ee32)
- [又拍网-图床](http://www.yupoo.com)

在线好用的Markdown工具，为印象笔记而生
- [马克飞象](http://maxiang.info)

参考资源：
- [Markdown——入门指南| 简书](http://jianshu.io/p/1e402922ee32)
