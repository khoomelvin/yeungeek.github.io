title: Hexo介绍
date: 2013-05-14 14:47:04
tags: [Hexo,github,git]
---
## 选择 ##
  选择[Hexo](https://github.com/tommy351/hexo "Hexo")也是个巧合，最近在看怎么使用github pages来生成网站，官方推荐[Jekyll](http://jekyllrb.com/)（github 默认pages 引擎），还有兼容Jekyll的[Octopress](http://octopress.org/)。<br>
以下为部分静态网站生成器简要列表:<br>
**1. Ruby**<br>
Jekyll （github 默认pages 引擎）<br>
Octopress （兼容jekyll）<br>
**2.Python**<br>
Hyde Jekyll的Python语言实现版本<br>
Cyrax 使用Jinja2模板引擎的生成器<br>
**3.PHP**<br>
Phrozn PHP语言实现的静态网站<br>
**4.JS**<br>
`Hexo`<br>
<!-- more -->
刚开始我也有用Octopress，生成非常的方便，但一直有个问题，中文分类搞得我头疼，虽然后面2.1版本已经解决了，后来不经意之间发现了Hexo。
## Hexo ##
Hexo这是一位台湾的同学 [@tommy351](https://github.com/tommy351)基于Node的静态博客网站生成器，目前已经发布到[1.1.3](https://github.com/tommy351/hexo/tree/1.1.3)。<br>
本博客使用了默认的主题：[hexo-theme-light](https://github.com/tommy351/hexo-theme-light)。<br>
有很多的特性：<br>
**1.Gallery Post**
![](http://pic.yupoo.com/yeungeek/CRn2TVmO/vU2OV.jpg)
```
---
layout: photo
title: Gallery Post
photos:
- http://i.minus.com/ibobbTlfxZgITW.jpg
- http://i.minus.com/iedpg90Y0exFS.jpg
---
```
<br>
**2.Link Post**<br>
![](http://pic.yupoo.com/yeungeek/CRnafeHN/medish.jpg)

```
---
layout: link
title: Link Post
link: http://www.google.com/
---
```
<br>
**3.Tweet Widget**<br>
![](http://pic.yupoo.com/yeungeek/CRn9rnuU/LJqxm.png)<br>
**4.Fancybox**
![](http://pic.yupoo.com/yeungeek/CRnafpmT/tORbY.png)

** 安装** <br>
官方文档上也写的很清楚，参考[安装](http://zespia.tw/hexo/zh-CN/docs/install.html)。<br/>

**改造(持续)** <br>
**1. 分享** <br>
将`themes/light/layout/_partial/article.ejs中的<%-partial('post/share')%一行删掉，`替换为[百度分享](http://share.baidu.com/code)的代码。<br>
**2. 评论** <br>
添加评论：
`将themes/light/layout/_patrial/comment.ejs中的config.disqus_shortname &&删掉,` <section>内替换为[多说](http://duoshuo.com/)提供的代码。<br/>

**写作** <br/>
1.创建
{% codeblock lang:linux %}
hexo new "New Post" -> source/_posts/new-post.md 
hexo new page "New Page" -> source/new-page/index.md
hexo new draft "New Draft" -> source/_drafts/new-draft.md
hexo new photo "New Gallery"
{% endcodeblock %}

2.生成静态文件
{% codeblock lang:linux %}
hexo generate
{% endcodeblock %}

3.启动服务器
{% codeblock lang:linux %}
hexo server
{% endcodeblock %}
输入[http://localhost:4000](http://localhost:4000) 预览<br>

4.部署
{% codeblock lang:linux %}hexo deploy
{% endcodeblock %}

这些是基本的使用，详细操作，直达链接：[Hexo docs](http://zespia.tw/hexo/zh-CN/docs/)
