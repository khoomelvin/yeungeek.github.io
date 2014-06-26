title: Git多帐号配置
date: 2014-06-26 14:28:33
tags:
- git
- github
categories:
- git
description:
  
---
> 在使用git，gitlab的时候，会在.ssh目录下生成对应rsa文件，那如果是有多个配置，该怎么处理？

如何生成ssh密钥，可以参考 [generating-ssh-keys](https://help.github.com/articles/generating-ssh-keys)  
##1. 多帐号配置
需要在.ssh目录下，增加config配置，config可以配置多个git的帐号  
{% code %}
 #Host myhost（这里是自定义的host简称，以后连接远程服务器就可以用命令ssh myhost）[注意下面有缩进]
     #User 登录用户名(如：git)
     #HostName 主机名可用ip也可以是域名(如:github.com或者bitbucket.org)
     #Port 服务器open-ssh端口（默认：22,默认时一般不写此行
     #IdentityFile 证书文件路径（如~/.ssh/id_rsa_*)
{% endcode %}  

具体的实例配置
{% code %}
 #github yeungeek@gmail.com
host github
    hostname github.com
    User yeungeek
    IdentityFile /home/yeungeek/.ssh/github_id_rsa

  #gitlab yeungeek@gmail.com
host gitlab
    hostname gitlab.widget-inc.com
    User yeungeek
    Port 65422
    IdentityFile /home/yeungeek/.ssh/id_rsa
host oschina
    hostname git.oschina.net
    User yeungeek
    IdentityFile /home/yeungeek/.ssh/oschina_id_rsa
{% endcode %}  

注意点：
- 在配置文件中的，IdentityFile文件位置是rsa密钥，不是pub文件
- 提交代码的时候，需要修改`git config`
可以之设置一个全局的user.email和user.name，然后需要不同的配置的仓库，单独设置  
{% code %}
//设置global
git config --global user.name "yeungeek"
git config --global user.email "yeungeek@gmail.com"

//设置仓库的user.email和user.name
git config  user.email "yeungeek@gmail.com"
git config  user.name "yeungeek"
{% endcode %}  
这样配置就ok了  

##2. ssh-add说明
上面的配置完成完成，使用命令`ssh-add -l`可以看到所有的密钥列表
{% code %}
yeungeek@yeungeek:~/.ssh$ ssh-add -l
2048 db:6a:da:46:6e:03:da:94:f0:2c:43:1d:91:8a:bd:67 yeungeek@gmail.com (RSA)
2048 07:59:9f:93:d2:e3:80:e1:df:77:ed:c9:5d:2e:3d:04 yeungeek@gmail.com (RSA)
2048 4f:ba:6c:00:12:41:0e:a8:50:be:f5:6e:2e:7a:10:91 yeungeek@gmail.com (RSA)
{% endcode %}
ssh-add的作用主要将密钥添加到 ssh-agent 的高速缓存中，这样在*当前会话*中就不需要再次输入密码了
具体的可以参考 [SSH Keys](http://t.cn/zWlX7vR)  


