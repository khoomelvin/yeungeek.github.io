title: "Android反编译之二--Smali语法简介"
date: 2015-08-23 17:57:03
tags:
- android
- decompile
- tools
categories:
- tools
---
上一篇文章中提到了Android的反编译工具，通过Apktool反编译出来的代码，Smail文件。所以本篇文章来介绍下Smail语法。
<!-- more -->
## Smail介绍
Smali，Baksmali分别是指安卓系统里的Java虚拟机（Dalvik）所使用的一种.dex格式文件的汇编器，反汇编器。其语法是一种宽松式的Jasmin/dedexer语法，而且它实现了.dex格式所有功能

## Smail语法
### 类型
Dalvik字节码有两种类型：原始类型；引用类型（包括对象和数组）
#### 原始类型
类型 | 描述
----|------
V | void - can only be used for return types
Z | boolean  
B | byte  
S | short  
C | char  
I | int  
J | long (64 bits)  
F | float  
D | double (64 bits)  
#### 对象类型
``` shell
Lpackage/name/ObjectName; 相当于java中的package.name.ObjectName;
```
L 表示这是一个对象类型  
package/name 该对象所在的包  
ObjectName 对象名称  
; 标识对象名称的结束

#### 数据类型
[I 表示一个int型的一维数组，相当于int[]  
增加一个维度增加一个[,如[[I表示int[][]  
注：每一维最多255个  
对象数组表示也是类似，如String数组的表示是[Ljava/lang/String

### 方法表示
``` java
Lpackage/name/ObjectName;->MethodName(III)Z
```
Lpackage/name/ObjectName 表示类型  
methodName 表示方法名  
III 表示参数（这里表示为3个整型参数）  
说明：方法的参数是一个接一个的，中间没有隔开

### 字段表示
``` java
Lpackage/name/ObjectName;->FieldName:Ljava/lang/String;
```
即表示： 包名，字段名和各字段类型

### 寄存器与变量
有两种方式指定一个方法中有多少寄存器是可用的:
``` shell
.registers 指令指定了方法中寄存器的总数
.locals 指令表明了方法中非参寄存器的总数，出现在方法中的第一行
```
寄存器采用v和p来命名  
v表示本地寄存器，p表示参数寄存器，关系如下:  
Long和Double类型是64位的，需要2个寄存器  
如果一个方法有两个本地变量，有三个参数
``` java
v0 第一个本地寄存器
v1 第二个本地寄存器
v2 p0 (this)
v3 p1 第一个参数
v4 p2 第二个参数
v5 p3 第三个参数
```
代码示例：也是从反编译代码中得到的
``` java
package com.ss.android.article.base.imagechooser;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;

public class ViewPagerFixed
  extends ViewPager
{
  public ViewPagerFixed(Context paramContext)
  {
    super(paramContext);
  }

  public ViewPagerFixed(Context paramContext, AttributeSet paramAttributeSet)
  {
    super(paramContext, paramAttributeSet);
  }

  public boolean onInterceptTouchEvent(MotionEvent paramMotionEvent)
  {
    try
    {
      bool = super.onInterceptTouchEvent(paramMotionEvent);
    }
    catch (IllegalArgumentException localIllegalArgumentException)
    {
      for (;;)
      {
        localIllegalArgumentException.printStackTrace();
        boolean bool = false;
      }
    }
    return bool;
  }

  public boolean onTouchEvent(MotionEvent paramMotionEvent)
  {
    try
    {
      bool = super.onTouchEvent(paramMotionEvent);
    }
    catch (IllegalArgumentException localIllegalArgumentException)
    {
      for (;;)
      {
        localIllegalArgumentException.printStackTrace();
        boolean bool = false;
      }
    }
    return bool;
  }
}
```
对应的Smail：
``` java
.class public Lcom/ss/android/article/base/imagechooser/ViewPagerFixed;
.super Landroid/support/v4/view/ViewPager;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    invoke-direct {p0, p1}, Landroid/support/v4/view/ViewPager;-><init>(Landroid/content/Context;)V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Landroid/support/v4/view/ViewPager;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    return-void
.end method


# virtual methods
.method public onInterceptTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 1

    :try_start_0
    invoke-super {p0, p1}, Landroid/support/v4/view/ViewPager;->onInterceptTouchEvent(Landroid/view/MotionEvent;)Z
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v0

    :goto_0
    return v0

    :catch_0
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/IllegalArgumentException;->printStackTrace()V

    const/4 v0, 0x0

    goto :goto_0
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 1

    :try_start_0
    invoke-super {p0, p1}, Landroid/support/v4/view/ViewPager;->onTouchEvent(Landroid/view/MotionEvent;)Z
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v0

    :goto_0
    return v0

    :catch_0
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/IllegalArgumentException;->printStackTrace()V

    const/4 v0, 0x0

    goto :goto_0
.end method
```

## 参考
* [TypesMethodsAndFields](https://code.google.com/p/smali/wiki/TypesMethodsAndFields)
* [Smali语法介绍](http://blog.csdn.net/singwhatiwanna/article/details/19019547)
* [android反编译-smali语法](http://blog.isming.me/2015/01/14/android-decompile-smali/)
