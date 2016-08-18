title: "Android公共技术点之六-View事件传递"
date: 2016-06-28 18:14:10
tags:
- android
- view
categories:
- publicTech
---
## 基础知识

* 所有的Touch事件都会被封装成一个MotionEvent对象，包括 Touch 的位置、时间、历史记录以及第几个手指(多指触摸)等。
* 事件类型分为 ACTION_DOWN, ACTION_UP, ACTION_MOVE, ACTION_POINTER_DOWN, ACTION_POINTER_UP, ACTION_CANCEL，每个事件都是以 ACTION_DOWN 开始 ACTION_UP 结束。本篇文章中涉及到事件:ACTION_DOWN, ACTION_UP, ACTION_MOVE, ACTION_CANCEL。
* 事件处理一般经过三种容器,分别为Activity、ViewGroup、View。与事件处理相关的方法：事件分发—dispatchTouchEvent,事件拦截-onInterceptTouchEvent,事件消费-onTouchEvent。
<!--more-->

## 传递流程
下面的例子中，我们定义了几个自定义View，一个继承ViewGroup(MotionLayout)，一个继承View(MotionView)，一个是自定义的Button(MotionButton)。
布局声明:
```
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">
    <com.yeungeek.publictech.motionevent.MotionLayout
        android:id="@+id/id_motion_layout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="10dp"
        android:background="@color/gray"
        android:orientation="vertical">

        <com.yeungeek.publictech.motionevent.MotionButton
            android:id="@+id/id_event_btn2"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Btn3"/>

        <com.yeungeek.publictech.motionevent.MotionView
            android:id="@+id/id_inner_motion_view"
            android:layout_width="60dp"
            android:layout_height="60dp"
            android:background="@color/black"/>
    </com.yeungeek.publictech.motionevent.MotionLayout>
</LinearLayout>
```
### View不消费事件
设置Button不可点击，然后点击`id_inner_motion_view`自定义View操作。   
输出日志:
```
#### Activity dispatchTouchEvent ACTION_DOWN
#### ViewGroup dispatchTouchEvent ACTION_DOWN
#### ViewGroup onInterceptTouchEvent ACTION_DOWN
#### ViewGroup onInterceptTouchEvent Result: false
#### View dispatchTouchEvent ACTION_DOWN
#### View onTouchEvent ACTION_DOWN
#### View onTouchEvent Result: false
#### View dispatchTouchEvent Result: false
#### ViewGroup onTouchEvent ACTION_DOWN
#### ViewGroup onTouchEvent Result: false
#### ViewGroup dispatchTouchEvent Result: false
#### Activity onTouchEvent ACTION_DOWN
#### Activity onTouchEvent Result: false
#### Activity dispatchTouchEvent Result: false
#### Activity dispatchTouchEvent ACTION_MOVE
#### Activity onTouchEvent ACTION_MOVE
#### Activity onTouchEvent Result: false
#### Activity dispatchTouchEvent Result: false
#### Activity dispatchTouchEvent ACTION_UP
#### Activity onTouchEvent ACTION_UP
#### Activity onTouchEvent Result: false
#### Activity dispatchTouchEvent Result: false
```
![](http://pic.yupoo.com/yeungeek/FMF1gDR8/medish.jpg)   
传递流程:  
* ACTION_DOWN事件从Activity#dispatchTouchEvent方法开始
* ACTION_DOWN事件传递至ViewGroup#dispatchTouchEvent方法，ViewGroup#onInterceptTouchEvent返回false，不拦截DOWN事件
* 继续传递到View#dispatchTouchEvent方法,因为View不可点击，View#onTouchEvent返回false，不消费DOWN事件
* 往上传递ViewGroup#onTouchEvent，ViewGroup#dispatchTouchEvent，都返回false，只能继续往上传递
* Activity的onTouchEvent方法还是返回false，最后ACTION_DOWN事件返回false
* 因为ACTION_DOWN事件返回false，接下来的ACTION_MOVE和ACTION_UP，继续由Activity来处理，结果都是返回false。Activity中没有View或者ViewGroup消费这些事件

### View消费事件
设置Button可点击。点击`id_event_btn2`操作。  
输出日志:
```
#### Activity dispatchTouchEvent ACTION_DOWN
#### ViewGroup dispatchTouchEvent ACTION_DOWN
#### ViewGroup onInterceptTouchEvent ACTION_DOWN
#### ViewGroup onInterceptTouchEvent Result: false
#### Button dispatchTouchEvent ACTION_DOWN
#### Button onTouchEvent ACTION_DOWN
#### Button onTouchEvent Result: true
#### Button dispatchTouchEvent Result: true
#### ViewGroup dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent ACTION_MOVE
#### ViewGroup dispatchTouchEvent ACTION_MOVE
#### ViewGroup onInterceptTouchEvent ACTION_MOVE
#### ViewGroup onInterceptTouchEvent Result: false
#### Button dispatchTouchEvent ACTION_MOVE
#### Button onTouchEvent ACTION_MOVE
#### Button onTouchEvent Result: true
#### Button dispatchTouchEvent Result: true
#### ViewGroup dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent ACTION_UP
#### ViewGroup dispatchTouchEvent ACTION_UP
#### ViewGroup onInterceptTouchEvent ACTION_UP
#### ViewGroup onInterceptTouchEvent Result: false
#### Button dispatchTouchEvent ACTION_UP
#### Button onTouchEvent ACTION_UP
#### Button onTouchEvent Result: true
#### Button dispatchTouchEvent Result: true
#### ViewGroup dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent Result: true
```
![](http://pic.yupoo.com/yeungeek/FMF1geiu/medish.jpg)   
和不消费事件的传递，在Button之前那些是一样的。不同在于Button是可点击，对事件进行了消费.
传递流程：
* ACTION_DOWN向下传递的过程是一样，在Button的时候返回值不同，因为Buttton是可点击的，返回true，消费了ACTION_DOWN事件
* 返回的结果true，向上传递到View#dispatchTouchEvent，然后继续上传到ACTION_DOWN事件的起点，Activity#dispatchTouchEvent方法。
* ACTION_MOVE和ACTION_UP的传递，因为没有父元素进行拦截，所以会继续传递到Button进行处理，传递流程和ACTION_DOWN是相同的。

### ViewGroup拦截事件
在自定义的Layout的onInterceptTouchEvent方法中进行Move事件进行拦截。    
输出日志:
```
#### Activity dispatchTouchEvent ACTION_DOWN
#### ViewGroup dispatchTouchEvent ACTION_DOWN
#### ViewGroup onInterceptTouchEvent ACTION_DOWN
#### ViewGroup onInterceptTouchEvent Result: false
#### Button dispatchTouchEvent ACTION_DOWN
#### Button onTouchEvent ACTION_DOWN
#### Button onTouchEvent Result: true
#### Button dispatchTouchEvent Result: true
#### ViewGroup dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent Result: true

#### Activity dispatchTouchEvent ACTION_MOVE
#### ViewGroup dispatchTouchEvent ACTION_MOVE
#### ViewGroup onInterceptTouchEvent ACTION_MOVE
#### ViewGroup onInterceptTouchEvent Result: true
#### Button dispatchTouchEvent ACTION_CANCEL
#### Button onTouchEvent ACTION_CANCEL
#### Button onTouchEvent Result: true
#### Button dispatchTouchEvent Result: true
#### ViewGroup dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent Result: true
#### Activity dispatchTouchEvent ACTION_MOVE
#### ViewGroup dispatchTouchEvent ACTION_MOVE
#### ViewGroup onTouchEvent ACTION_MOVE
#### ViewGroup onTouchEvent Result: false
#### ViewGroup dispatchTouchEvent Result: false

#### Activity dispatchTouchEvent ACTION_UP
#### ViewGroup dispatchTouchEvent ACTION_UP
#### ViewGroup onTouchEvent ACTION_UP
#### ViewGroup onTouchEvent Result: false
#### ViewGroup dispatchTouchEvent Result: false
#### Activity onTouchEvent ACTION_UP
#### Activity onTouchEvent Result: false
#### Activity dispatchTouchEvent Result: false
```
![](http://pic.yupoo.com/yeungeek/FMF0OuA5/medish.jpg)   
在ViewGroup中对`ACTION_MOVE`进行拦截，可以看到`onInterceptTouchEvent`返回true,这样会传递给View一个`ACTION_CANCEL`事件。
因为被父元素进行了拦截，之后的`ACTION_MOVE`,`ACTION_UP`就不会传给View了。

## 总结
通过上诉的一系列测试，我们已经非常清楚地知道了View的事件传递流程：
1. 事件从Activity#dispatchTouchEvent开始传递,如果事件没有被拦截，事件会从外向内，从父元素(View或者ViewGroup)传递给子元素,子元素通过`onTouchEvent`方法对事件进行处理。
2. 如果由外向内，事件没有被停止或者拦截，而且最底层的子元素没有消费事件，那么事件会由内向外反向传递，父元素可以进行消费，如果一直都没有被消费，最后会传递到Activity的`onTouchEvent`方法
3. 事件从父元素传递到子元素的时候，ViewGroup可以通过`onInterceptTouchEvent`方法进行拦截
4. 如果View没有对`ACTION_DOWN`事件进行消费，那么其他的事件也不会传递过来。

通过实例测试，已经清楚地了解了事件传递的流程。如果想从源码上了解整个事件的传递过程，参考：
* 鸿洋老师的[Android View 事件分发机制 源码解析 （上）](http://blog.csdn.net/lmj623565791/article/details/38960443)
* 以及guolin老师的[Android事件分发机制完全解析，带你从源码的角度彻底理解(上,下)](http://blog.csdn.net/guolin_blog/article/details/9097463)

文章源码例子:[MotionEvent](https://github.com/yeungeek/AndroidSample/blob/master/PublicTech/app/src/main/java/com/yeungeek/publictech/motionevent)

## 参考
* [Android事件分发机制完全解析，带你从源码的角度彻底理解(上,下)](http://blog.csdn.net/guolin_blog/article/details/9097463)
* [公共技术点之 View 事件传递](http://codekk.com/blogs/detail/54cfab086c4761e5001b253e)
* [Understanding Android Input Touch Events System Framework](http://codetheory.in/understanding-android-input-touch-events/)
* [Android Touch事件分发详解](https://github.com/CharonChui/AndroidNote/blob/master/Android%E5%8A%A0%E5%BC%BA/Android%20Touch%E4%BA%8B%E4%BB%B6%E5%88%86%E5%8F%91%E8%AF%A6%E8%A7%A3.md)
* [更简单的学习Android事件分发](https://github.com/Idtk/Blog/blob/master/Blog/11%E3%80%81TouchEvent.md)
