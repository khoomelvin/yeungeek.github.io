title: "Android公共技术点之七-View绘制流程"
date: 2016-09-14 17:32:53
tags:
- android
- view
categories:
- publicTech
---
## 基础知识
* ViewRoot: 具体实现类ViewRootImpl，是连接WindowManager和DecorView的纽带，View的三大流程(mearsure、layout、draw)均是通过ViewRoot来完成。
* DecorView: 作为根View，其实是一个FrameLayout,内部包含一个竖直方向的LinearLayout，这个LinearLayout分为标题栏和内容栏两个部分。
* PhoneWindow: Window对象通常由PhoneWindow来实现的，PhoneWindow将一个DecorView设置为整个应用窗口的根View。
<!-- more -->
### MearsureSpec
测量规格，包含测量要求和尺寸的信息，有三种模式:
    * UNSPECIFIED：父容器不对View进行任何限制，要多大给多大，一般用于系统内部
    * EXACTLY：父容器检测到View所需要的精确大小，这时候View的最终大小就是SpecSize所指定的值，对应LayoutParams中的'match_parent'和具体数值这两种模式
    * AT_MOST：对应View的默认大小，不同View实现不同，View的大小不能大于父容器的SpecSize，对应LayoutParams中的'wrap_content'

## View的绘制流程
整个View树的绘制流程在`ViewRoot`类的`performTraversals()`函数展开，绘制函数的调用

![](http://pic.yupoo.com/yeungeek/FX2x5hn7/medish.jpg)  
> 图片来自：https://plus.google.com/+ArpitMathur/posts/cT1EuBbxEgN

下图中可以更清楚地看出，显示一个View主要有三个过程：

![](http://pic.yupoo.com/yeungeek/FXieEGBC/z3zVG.png)
1. Measure：测量View的大小
2. Layout：对View进行布局，确定View的位置
3. Draw：对View进行绘制，显示内容

其中measure方法是final的，无法重写。layout和draw不是final的，但是不建议重写该方法。  
如果想实现自身的逻辑，而又不破坏View的工作流程，可以重写onMeasure、onLayout、onDraw方法。
### measure过程
View绘制从ViewRoot的performTraversals()方法中开始。首先调用的是performMeasure()方法，它会调用View的measure方法进行测量，
而DecorView(继承FrameLayout)的父类是ViewGroup，ViewGroup又是继承于View的， 具体的测量流程如图所示。
![](http://pic.yupoo.com/yeungeek/FXkDC7Vm/ZGh3y.png)  
View绘制主要分为两种情况，View和ViewGroup：
* View通过`measure()`方法完成测量过程
* ViewGroup会循环遍历子View，所有的子View测量完成才算结束

#### View的measure过程
我们看下View中的`measure`源码
```
public final void measure(int widthMeasureSpec, int heightMeasureSpec) {
......
if (cacheIndex < 0 || sIgnoreMeasureCache) {
    // measure ourselves, this should set the measured dimension flag back
    onMeasure(widthMeasureSpec, heightMeasureSpec);
    mPrivateFlags3 &= ~PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;
}
......    
}

protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
            getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
}
```
获取View最终的大小是在onMeasure方法中，如果要想自定义View，可以复写该方法。
#### ViewGroup的measure过程
ViewGroup中没有具体onMeasure方法，因为不同的ViewGroup子类有不同的布局特性，没有统一的onMeasure进行测量。
不过它提供了`measureChildren`和`measureChildWithMargins`方法来测量子视图的大小。
```
protected void measureChildren(int widthMeasureSpec, int heightMeasureSpec) {
    final int size = mChildrenCount;
    final View[] children = mChildren;
    for (int i = 0; i < size; ++i) {
            final View child = children[i];
            if ((child.mViewFlags & VISIBILITY_MASK) != GONE) {
                measureChild(child, widthMeasureSpec, heightMeasureSpec);
            }
        }
}
protected void measureChild(View child, int parentWidthMeasureSpec,
        int parentHeightMeasureSpec) {
    final LayoutParams lp = child.getLayoutParams();

    final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
            mPaddingLeft + mPaddingRight, lp.width);
    final int childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec,
            mPaddingTop + mPaddingBottom, lp.height);

    child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
}
......
protected void measureChildWithMargins(View child,
        int parentWidthMeasureSpec, int widthUsed,
        int parentHeightMeasureSpec, int heightUsed) {
    final MarginLayoutParams lp = (MarginLayoutParams) child.getLayoutParams();

    final int childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec,
            mPaddingLeft + mPaddingRight + lp.leftMargin + lp.rightMargin
                    + widthUsed, lp.width);
    final int childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec,
            mPaddingTop + mPaddingBottom + lp.topMargin + lp.bottomMargin
                    + heightUsed, lp.height);

    child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
}
```
DecorView继承的FrameLayout，复写了onMeasure方法，通过measureChildWithMargins方法测量所有子视图。
```
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    ......
    for (int i = 0; i < count; i++) {
        ......
            measureChildWithMargins(child, widthMeasureSpec, 0, heightMeasureSpec, 0);
        ......
    }    
    ......
}
```
从View和ViewGroup视图测量的流程看出，有几个核心方法:
1. mearsure
定义在View中，为final 类型，不可被复写，但`measure`调用链最终会回调 View/ViewGroup 对象的`onMeasure()`方法，因此自定义视图时，只需要复写`onMeasure()`方法即可。
2. onMeasure
自定义视图中需要实现的方法，该方法的参数是父视图对子视图的width和height的测量要求。根据widthMeasureSpec和heightMeasureSpec计算视图的width和height，不同的模式处理方式不同。
3. setMeasuredDimension
测量阶段终极方法，在onMeasure(int widthMeasureSpec, int heightMeasureSpec)方法中被调用，将计算得到的尺寸，传递给该方法，测量阶段即结束。

### layout过程
measure完成后,接下来就是layout过程。
layout的作用是ViewGroup用来确定子视图的位置，当ViewGroup的位置被确定后，它会在onLayout中遍历所有的子视图并调用其layout方法，在layout方法中，onLayout方法又会被调用。
流程如图所示：
![](http://pic.yupoo.com/yeungeek/FXrSmRK9/15kY25.png)
1. setFrame方法确定View的四个顶点位置，即确定了View在父容器中的位置
2. View和ViewGroup均没有真正实现onLayout方法

### draw过程
draw绘制要遵循一定的顺序：
> Draw traversal performs several drawing steps which must be executed
in the appropriate order:
> 1. Draw the background
> 2. If necessary, save the canvas' layers to prepare for fading
> 3. Draw view's content
> 4. Draw children
> 5. If necessary, draw the fading edges and restore layers
> 6. Draw decorations (scrollbars for instance)

其中第二步和第五步比较少用到。
具体流程如图所示：
![](http://pic.yupoo.com/yeungeek/FXrSmXpS/VJSxK.png)
ViewGroup的dispatchDraw方法会遍历所有子View的draw方法。
## 自定义View
自定义View主要分为三类:
1. 自绘控件，继承View，通过onDraw方法绘制。
2. 组合控件，使用系统已有的控件，把进行布局和绘制。
3. 继承控件，继承现有的控件，去实现一些新的功能。

自定义新的View时，需要对其分类，并选择合适的实现思路。

## 参考
* [Android视图绘制流程完全解析，带你一步步深入了解View(二)](http://blog.csdn.net/guolin_blog/article/details/16330267)
* [公共技术点之 View 绘制流程](http://codekk.com/blogs/detail/54cfab086c4761e5001b253f)
* [Android开发艺术探索](https://github.com/singwhatiwanna/android-art-res/blob/master/Chapter_4)
