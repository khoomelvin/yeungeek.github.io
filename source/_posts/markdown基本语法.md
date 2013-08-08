title: Markdown基本语法
date: 2013-08-07 17:32:40
tags: [Markdown,Github,Git]
---
   工欲善其事,必先利其器,在使用<a href="http://zespia.tw/hexo/zh-CN/" target="_blank">Hexo</a>写博客后，Markdown语法的了解就显得很有必要了。
本文参考<a href="http://wowubuntu.com/markdown/" target="_blank">Markdown 语法说明</a> </br>

-   <a href="#overview">概述</a>
-   <a href="#block">区块元素</a>
    1. 段落和换行
    2. 标题
    3. 区块引用
    4. 列表
    5. 代码区块
    6. 分隔线
-   <a href="#span">区段元素</a>
    1. 链接
    1. 强调
    1. 代码
    1. 图片
-   <a href="#editor">Markdown 免费编辑器</a>

## <a name="overview">概述</a>
Markdown 的目标是实现「易读易写」。<br/>
说到底就是轻量级别的，可以随时方便改动，可以生成相应的Html。最重要的一点就是现在很多博客系统直接支持Markdown语法。<br/>
接下来介绍Markdown的基本语法，对，没错，是基本。
<!-- more -->
## <a name="block">区块元素</a> 
### 段落和换行
一个 Markdown 段落是由一个或多个连续的文本行组成<br/>
换行，则使用换行符号
`
<br/>
`
### 标题
Markdown 支持两种标题的语法<br/>
类 Setext 形式是用底线的形式，利用 `=` （最高阶标题）和 `-` （第二阶标题）
例如：
{% codeblock lang:linux %}
This is an H1
=============

This is an H2
-------------
{% endcodeblock %}
任何数量的 `=` 和 `-` 都可以有效果。<br/>
类 Atx 形式则是在行首插入 1 到 6 个 `#` ，对应到标题 1 到 6 阶，例如：
{% codeblock lang:linux %}
# 这是 H1

## 这是 H2

###### 这是 H6
{% endcodeblock %}
也可以使用闭合
{% codeblock lang:linux %}
# 这是 H1 #

## 这是 H2 ##

### 这是 H3 ######
{% endcodeblock %}

### 区块引用 Blockquotes

Markdown 标记区块引用是使用类似 email 中用 `>` 的引用方式,例如：
{% codeblock lang:linux %}
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.
{% endcodeblock %}

效果：
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse <br/>
> id sem consectetuer libero luctus adipiscing.

### 列表
Markdown 支持有序列表和无序列表。<br/>
无序列表使用星号、加号或是减号作为列表标记
{% codeblock lang:linux %}
*   Red
*   Green
*   Blue
+   Red
+   Green
+   Blue
-   Red
-   Green
-   Blue
{% endcodeblock %}
有序列表则使用数字接着一个英文句点
{% codeblock lang:linux %}
1.  Bird
2.  McHale
3.  Parish
1.  Bird
1.  McHale
1.  Parish
{% endcodeblock %}
而且可以根据数字编号无关

### 代码区块

Markdown 会用 `<pre>` 和 `<code>` 标签来把代码区块包起来<br/>
或者简单地缩进 4 个空格或是 1 个制表符也是同样的效果<br/>
当然有些工具还有自己的标记<br/>
Hexo就有自己的标记标签<br/>
在代码区块里面， `&` 、 `<` 和 `>` 会自动转成 HTML 实体

### 分隔线 ###

一行中用三个以上的星号、减号、底线来建立一个分隔线，行内不能有其他东西

## <a name="span">区段元素</a>

### 链接 ###

Markdown 支持两种形式的链接语法： 行内式和参考式两种形式<br/>
链接文字都是用 `[方括号]` 来标记<br/>
行内式的链接，只要在方块括号后面紧接着圆括号并插入网址链接即可,例如：<br/>
![行内式][innerurl]

参考式的链接是在链接文字的括号后面再接上另一个方括号，而在第二个方括号里面要填入用以辨识链接的标记
{% codeblock lang:linux %}
This is [an example][id] reference-style link.
{% endcodeblock %}
在文件的任意处，你可以把这个标记的链接内容定义出来
{% codeblock lang:linux %}
[id]: http://example.com/  "Optional Title Here"
{% endcodeblock %}
链接内容定义的形式为：<br/>

- 方括号（前面可以选择性地加上至多三个空格来缩进），里面输入链接文字
- 接着一个冒号
- 接着一个以上的空格或制表符
- 接着链接的网址
- 选择性地接着 title 内容，可以用单引号、双引号或是括弧包着

最后，还有个隐式链接标记功能让你可以省略指定链接标记，后面的`[id]`用`[]`表示，例如<br/>
`[Google][]`<br/>
然后定义链接内容：<br/>
`[Google]: http://google.com/`
### **强调**
Markdown 使用星号（`*`）和底线（`_`）作为标记强调字词的符号，被 `*` 或 `_ `包围的字词会被转成用 `<em>` 标签包围，用两个 `*` 或 `_` 包起来的话，则会被转成 `<strong>`
### _代码_
如果要标记一小段行内代码，你可以用反引号把它包起来（`）<br/>
如果要在代码区段内插入反引号，你可以用多个反引号来开启和结束代码区段<br/>
当然了有些博客支持的，他会有自己的标签插件，hexo就有自己的定义，[标签插件]
### *图片*
图片的链接和url的链接有些类似，同样也允许两种样式： <ins>行内式</ins>和<ins>参考式</ins><br/>
行内式的图片语法:
![行内图片](http://pic.yupoo.com/yeungeek/D4oRcNPA/IDxME.png)
详细描述：

- 一个惊叹号 !
- 接着一个方括号，里面放上图片的替代文字
- 接着一个普通括号，里面放上图片的网址，最后还可以用引号包住并加上 选择性的 'title' 文字。

参考式的图片语法与链接的语法一样<br/>
Markdown 还没有办法指定图片的宽高，如果你需要的话，你可以使用普通的 `<img>` 标签
不过hexo提供 img的标签插件，可以支持。
### __自动链接__
Markdown 支持以比较简短的自动链接形式来处理网址和电子邮件信箱，只要是用方括号包起来.
### **反斜杠**
Markdown 可以利用反斜杠来插入一些在语法中有其它意义的符号<br/>
{% img http://pic.yupoo.com/yeungeek/D4oUJxcS/uAS63.png Place Kitten #2 %}
## <a name="editor">Markdown 免费编辑器</a>
Windows 平台

- [MarkdownPad](http://markdownpad.com/ "MarkdownPad")
- [MarkPad](http://markdownpad.com/ "MarkPad")

Linux 平台

- [ReText]

Mac 平台

- [Mou]

在线编辑器

- [Markable.in]
- [Dillinger.io]

浏览器插件

- [MaDe] (Chrome)

[ReText]: http://sourceforge.net/p/retext/home/ReText/
[Mou]: http://mouapp.com/ "Mou"
[Markable.in]: http://markable.in/ "Markable.in"
[Dillinger.io]: http://dillinger.io/
[MaDe]: https://chrome.google.com/webstore/detail/oknndfeeopgpibecfjljjfanledpbkog
[标签插件]: http://zespia.tw/hexo/zh-CN/docs/tag-plugins.html
[innerurl]: http://pic.yupoo.com/yeungeek/D4oGAt3U/medish.jpg