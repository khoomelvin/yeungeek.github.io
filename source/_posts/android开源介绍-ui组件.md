layout: photo
title: Android开源介绍-UI组件
date: 2013-05-26 11:43:08
tags: [Android,UI]
categories: [Android开源]
photos:
- http://static.oschina.net/uploads/img/201112/27095841_C0fm.png
- https://raw.github.com/JakeWharton/Android-ViewPagerIndicator/master/sample/screens.png
- http://static.oschina.net/uploads/img/201112/27000451_wNTI.png
- https://github.com/dodola/android_waterfall/raw/master/screen1.png
- http://static.oschina.net/uploads/img/201303/28222420_KY2n.png
- http://cms.csdnimg.cn/article/201305/03/51834b4112992_middle.jpg
- https://raw.github.com/dmitry-zaitsev/AndroidSideMenu/master/screenshot.jpg
- http://cms.csdnimg.cn/article/201305/21/519b5b872f454.jpg
- https://github.com/tjerkw/Android-SlideExpandableListView/raw/master/raw/example-screens.png
- https://github.com/square/android-times-square/raw/master/timesSquareScreenshot.png
- https://github.com/youxiachai/Notifications4EveryWhere/raw/master/default.png
- http://static.oschina.net/uploads/space/2013/0328/230526_Ew0f_5189.jpg
---

终端的开发，UI的重要性不言而喻，如何快速开发出优雅漂亮的UI，android的一些开源UI组件，提供了很好的参考。<br>
参考：<br>
{% blockquote %}
[oschina Android UI组件](http://www.oschina.net/project/tag/342/android-ui) <br>
[最火的Android开源项目（一）](http://www.csdn.net/article/2013-05-03/2815127-Android-open-source-projects)<br>
[最火的Android开源项目（二）](http://www.csdn.net/article/2013-05-06/2815145-Android-open-source-projects-two)<br>
[最火的Android开源项目（完结篇）](http://www.csdn.net/article/2013-05-21/2815370-Android-open-source-projects-finale)<br>
{% endblockquote %}

## 1. [ActionBarSherlock](https://github.com/JakeWharton/ActionBarSherlock) ##
<!-- more -->
{% img http://actionbarsherlock.com/static/logo.png %}<br>
在3.0之前使用ActionBar，ActionBarSherlock提供了很好的兼容。ActionBarSherlock 是Android compatibility library 的一个扩展,ActionBarSherlock 被设计成通过一个API就能够很方便使用所有版本的Android操作栏的设计模式.<br>
对于Android 4.0及更高版本，ActionBarSherlock可以自动使用本地ActionBar实现，而对于之前没有ActionBar功能的版本，基于Ice Cream Sandwich的自定义动作栏实现将自动围绕布局。能够让开发者轻松开发一款带动作栏（Action bar）的应用，并且适用于Android 2.x及其以上所有版本。<br>
这个是Android牛人开发的一个开源组件，关注[JakeWharton](https://github.com/JakeWharton)，你会有更多惊喜。<br>
{% gist 5616899 %}

## 2. [Android-ViewPagerIndicator](https://github.com/JakeWharton/Android-ViewPagerIndicator) ##
这个又是[JakeWharton](https://github.com/JakeWharton)的杰作，说过了关注他，会有惊喜。<br>
ViewPagerIndicator是扩展了support库中ViewPager的用法。<br>
Paging indicator widgets compatible with the ViewPager from the Android Support Library and ActionBarSherlock. Originally based on Patrik Åkerfeldt's ViewFlow<br>
## 3. [Android PullToRefresh](https://github.com/johannilsson/android-pulltorefresh) ##
该项目为 Android 应用提供一个向下滑动即刷新列表的功能。这个很常用，现在的列表中，都提供了向下滑动刷新的功能。

## 4. [Android瀑布流](https://github.com/dodola/android_waterfall) ##
实现了类似于迷尚android和蘑菇街android的瀑布流布局。<br>
不过作者已经声明：<br>
{% blockquote dodola https://github.com/dodola/android_waterfall%}
此项目由于最初设计问题，导致现在问题比较多，暂时停止维护。我现在在其他类似的瀑布流上进行完善开发,请关注：[PinterestLikeAdapterView](https://github.com/dodola/PinterestLikeAdapterView)
{% endblockquote %}<br>
看来作者还是很用心的，值得关注。

## 5. [android-bootstrap](https://github.com/donnfelker/android-bootstrap) ##
{% img http://static.oschina.net/uploads/img/201303/28222420_KY2n.png %}<br>
bootstrap,twitter开源的一个项目也叫这个。怎么看该项目都是一个聚合<br>
android-bootstrap 是一个模板/引导/样板文件的应用程序,包括大量的优秀的开放源码工具和框架<br>
Android Bootstrap 包含一个完整实现：Fragments, Fragment Pager, Account Manager, android-maven-plugin, Dagger, ActionBarSherlock 4, ViewPagerIndicator, http-request, GSON, Robotium for integration testing, API Consumption with an API on Parse.com and much more.<br>
好东西啊，什么都有了，同学们自己挑选吧。

## 6. [SlidingMenu](https://github.com/jfeinstein10/SlidingMenu) ##
SlidingMenu是一个开源的Android库，能够让开发者轻松开发一款应用，实现类似于Google+、Youtube和Facebook应用中非常流行的滑动式菜单。<br>
目前使用该项目的应用：<br>

- Foursquare <br>
- Rdio<br>
- Evernote Food<br>
- Plume<br>
- VLC for Android<br>
- ESPN ScoreCenter<br>
- MLS MatchDay<br>
- 9GAG<br>
- Wunderlist 2<br>
- The Verge<br>
- MTG Familiar<br>
- Mantano Reader<br>
- Falcon Pro (BETA)<br>
- MW3 Barracks<br>

## 7. [AndroidSideMenu](https://github.com/dmitry-zaitsev/AndroidSideMenu) ##
AndroidSideMenu能够让你轻而易举地创建侧滑菜单。需要注意的是，该项目自身并不提供任何创建菜单的工具，因此，开发者可以自由创建内部菜单。<br>
这个与SlidingMenu结合，那岂不是天衣无缝了。

## 8. [android-flip](https://github.com/openaphid/android-flip) ##
能够实现Flipboard翻页效果的UI组件<br>
{% img http://cms.csdnimg.cn/article/201305/03/51834f7e3c8a5.jpg%} <br>
是不是很酷啊

## 9. [drag-sort-listview](https://github.com/bauerca/drag-sort-listview) ##
DragSortListView（DSLV）是Android ListView的一个扩展，支持拖拽排序和左右滑动删除功能。重写了TouchInterceptor（TI）类来提供更加优美的拖拽动画效果。<br>
{% img http://cms.csdnimg.cn/article/201305/06/5187782519829_middle.jpg %} <br>
DSLV主要特性：<br>

-完美的拖拽支持；<br>
-在拖动时提供更平滑的滚动列表滚动；<br>
-支持每个ListItem高度的多样性<br>
-公开startDrag()和stopDrag()方法；<br>
-有公开的接口可以自定义拖动的View。<br>
DragSortListView适用于带有任何优先级的列表：收藏夹、播放列表及清单等，算得上是目前Android开源实现拖动排序操作最完美的方案。

## 10. [Android-satellite-menu](https://github.com/siyamed/android-satellite-menu) ##
模拟path的按钮效果<br>
{% img http://cms.csdnimg.cn/article/201305/21/519ada549df4d_middle.jpg %}<br>
对于Satellite Menu，其项目发起人siyamed表示，这种菜单结构就像是一个星球四周围绕着许多卫星，而这也就是他为何会以Satellite Menu命名该项目的原因。

## 11. [ArcMenu](https://github.com/daCapricorn/ArcMenu) ##
又见path的按钮效果<br>
{% img http://cms.csdnimg.cn/article/201305/21/519ae56627b36_middle.jpg %}
对于这个项目，其发起人daCapricorn表示，iOS版Path 2.0上的用户体验非常奇妙，但其Android版本却差太多。因此，他就尝试着在Android上做出像iOS版本那样的效果，而事实也的确如此。

## 12. [ImageFilterForAndroid](https://github.com/daizhenjun/ImageFilterForAndroid) ##
在开源ImageFilterForAndroid中拥有许多丰富的图片效果，是由来自国内的代震军发起的一个开源项目。除了Android平台，还有Windows Phone和iOS移动平台，三个平台源码同步。<br>
代震军也搞Android了吗，以前还看过他对Mongodb源码的分析。

## 13. [Crouton](https://github.com/keyboardsurfer/Crouton) ##
Crouton是Android上的一个可以让开发者对环境中的Toast进行替换的类，以一个应用程序窗口的方式显示，而其显示位置则由开发者自己决定。<br>
{% img http://cms.csdnimg.cn/article/201305/07/5188b6491fd81_middle.jpg %}<br>
以后自定义Toast，就很方便了。

## 14. [Android-SlideExpandableListView](https://github.com/tjerkw/Android-SlideExpandableListView) ##
如果你对Android提供的Android ExpandableListView并不满意，一心想要实现诸如Spotify应用那般的效果，那么SlideExpandableListView绝对是你最好的选择。<br>
该库允许你自定义每个列表项目中的ListView，一旦用户点击某个按钮，即可实现该列表项目区域滑动。<br>

## 15. [TimesSquare](https://github.com/square/android-times-square) ##
Android下一款漂亮的日历控件 <br>

## 16. [StandOut](https://github.com/pingpongboss/StandOut) ##
StandOut 可让你轻松创建 Android 的浮动窗口 <br>

## 17. [Notifications4EveryWhere](https://github.com/youxiachai/Notifications4EveryWhere) ##
基于android 4.1 Notification  样式实现的兼容包。<br>

改进自源com.android.support.v4.app 里面的NotificationCompat.Builder。<br>

由于原官方的兼容包中，只是对Notification 做了一层api 的切换，并没有让旧的平台实现android 4.1 Notification 的新特性。所以，我对照着android4.1的源码把，android 4.1 的部分新的Notification 的特性进行移植，让android 2.2 以上的平台都能够用一致的api 实现同样的效果。<br>

目前除了android 4.1 的bigStyle 还没实现外，其他我知道的特性都已经移植完毕。效果可以看主页的截图。<br>

如果你之前有使用NotificationCompat.Builder 的，你只需把com.android.support.v4.app.NotificationCompat.Builder 替换成com.android.support.v8.app.NotificationCompat.Builder 即可。<br>
