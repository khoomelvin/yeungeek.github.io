---
title: 菜鸟裹裹App分析系列-UI框架设计分析
date: 2018-07-31 10:16:39
tags:
- cainiao
- android
categories:
- app
---

前两天分析了菜鸟裹裹的具体业务,菜鸟裹裹能够成功快递行业的王牌产品,业务当然是非常重要的一环,不过App的操作体验,以及能够让用户使用上更加方便快捷,也是成功的重要因素,所以这次就来分析菜鸟裹裹的UI框架设计。
<!-- more -->
这次对主要功能页面进行分析,分析工具:
* UIAutomatorViewer-用来扫描和分析Android应用程序的UI组件的GUI工具
* jadx-反编译工具

## 首页
![](http://pic.yupoo.com/yeungeek/HwYAhuRo/medish.jpg)
图中看出UI设计主要分为了:底部的`menu_and_navigation_bar_container`和内容区域`navigation_bar_content`
布局文件
``` xml libs_activity_navigation_bar.xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout android:id="@id/navigation_bar_root" android:clipChildren="false" android:layout_width="fill_parent" android:layout_height="fill_parent"
  xmlns:android="http://schemas.android.com/apk/res/android">
    <FrameLayout android:layout_gravity="top" android:id="@id/navigation_bar_content" 
    android:layout_width="fill_parent" android:layout_height="fill_parent" android:layout_marginBottom="@dimen/navigation_bar_height" />
    <ViewStub android:id="@id/navigation_bar_loading_view" 
    android:layout="@layout/cainiao_progress_dialog" android:inflatedId="@id/rn_loading_view" android:layout_width="fill_parent" android:layout_height="fill_parent" />
    <FrameLayout android:layout_gravity="bottom" android:id="@id/menu_and_navigation_bar_container" 
    android:clipChildren="false" android:layout_width="fill_parent" android:layout_height="@dimen/navigation_bar_height">
        <com.cainiao.commonlibrary.navigation.NavigationBarView android:gravity="bottom" 
        android:layout_gravity="center_vertical" android:id="@id/navigation_bar_view" 
        android:clipChildren="false" android:layout_width="fill_parent" android:layout_height="fill_parent" />
    </FrameLayout>
    <ViewStub android:id="@id/full_screen_splash_view" android:layout="@layout/libs_full_screen_splash_view" 
    android:inflatedId="@id/splash_layout" android:layout_width="fill_parent" android:layout_height="fill_parent" />
</FrameLayout>
```
内容区域布局:
``` xml homepage_fragment
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout android:layout_width="fill_parent" android:layout_height="fill_parent"
  xmlns:android="http://schemas.android.com/apk/res/android">
    <com.cainiao.wireless.uikit.view.feature.PtrBirdFrameLayout android:id="@id/store_house_ptr_frame" 
    android:background="@color/full_transparent" android:layout_width="fill_parent" android:layout_height="fill_parent" android:layout_below="@id/header_title_view">
        <ListView android:id="@id/package_listview" android:background="@color/homepage_fragment_listview_background" 
        android:scrollbars="none" android:layout_width="fill_parent" android:layout_height="fill_parent" 
        android:layout_marginBottom="10.0dip" android:listSelector="#00000000" android:divider="@null" 
        android:choiceMode="singleChoice" android:overScrollMode="never" />
    </com.cainiao.wireless.uikit.view.feature.PtrBirdFrameLayout>
    <LinearLayout android:orientation="vertical" android:id="@id/homepage_fragment_scrollable_layout" 
    android:layout_width="fill_parent" android:layout_height="wrap_content" 
    android:layout_below="@id/header_title_view">
        <com.cainiao.wireless.homepage.presentation.view.widget.newfeatureview.HomepageNewFeatureLayout android:id="@id/home_page_fragment_new_grid_feature_enter_layout" 
        android:layout_width="fill_parent" 
        android:layout_height="wrap_content" />
    </LinearLayout>
    <com.cainiao.wireless.homepage.presentation.view.widget.HomepageTitleView android:id="@id/header_title_view" 
    android:layout_width="fill_parent" android:layout_height="45.0dip" />
</RelativeLayout>
```
布局文件的具体结构图:
![](http://pic.yupoo.com/yeungeek/HwYCP5A8/medish.jpg)
* `menu_and_navigation_bar_container`主要包含了`NavigationBarView`,底部导航内容:首页,取件,寄件,驿站,我。
* `navigation_bar_content`：内容区域。通过底部导航的切换,内容显示不同的页面。
* `main_activity_content`：首页的内容区域显示。分为三部分：
    * `header_title_view`：通过自定义View`HomepageTitleView`实现
    * `homepage_fragment_scrollable_layout`：通过`HomepageNewFeatureLayout`实现
    * `store_house_ptr_frame`：展现列表和下拉刷新,分别通过`ListView`和`PtrBirdFrameLayout`实现

## 物流详情
![](http://pic.yupoo.com/yeungeek/HwZJVJoT/medish.jpg)
物流详情的页面比较有特色,地图展示订单的轨迹,列表展示从发货到收货各个节点信息。
UI结构图：
![](http://pic.yupoo.com/yeungeek/HwZY07QQ/medish.jpg)
* 最底层是全屏mapview
* 菜单操作层覆盖在mapview上
* 最上面一层是物流从发货到收货的节点列表

不过从反编译中无法找到对应的布局xml,通过关键字`logistic`在AndroidManifest.xml文件搜索到相关的Activity。发现`com.cainiao.wireless.logisticsdetail.presentation.view.activity.ShowGoodInfoActivity`有相关性,`ShowGoodInfoActivity`中使用`ShowGoodInfoFragment`渲染,
`ShowGoodInfoFragment`中有个方法会真正进入到详情的逻辑。
``` java ShowGoodInfoFragment.java
public void showGoodInfo(List<LogisticsDetailGoodsDO> packageItems) {
    if (packageItems != null) {
        if (packageItems.size() == 0) {
            Bundle bundle = new Bundle();
            bundle.putString("orderCode", this.mOrderCode);
            bundle.putString("mailNo", this.mMailNo);
            bundle.putString("cpCode", this.mCpCode);
            //进入详情的Router声明
            Router.from(getActivity()).withExtras(bundle)
            .toUri("guoguo://go/logistic");
            getActivity().overridePendingTransition(0, 0);
            finish();
        }
        if (packageItems.size() == 1) {
            Router.from(getActivity()).toUri(((LogisticsDetailGoodsDO) packageItems.get(0)).taobaoGoodUrl);
            getActivity().overridePendingTransition(0, 0);
            finish();
            return;
        }
        this.mSlideShowView.setDatas(packageItems);
    }
}
```
该方法通过Router进行跳转到`guoguo://go/logistic`,在AndroidManifest.xml有对应的声明:
``` xml AndroidManifest.xml
<activity android:configChanges="keyboardHidden|orientation" android:exported="false" 
android:name="com.taobao.cainiao.newlogistic.LogisticDetailActivity" 
android:screenOrientation="portrait" android:theme="@style/Theme.NoBackgroundAndTitle.TabPage" 
android:windowSoftInputMode="adjustResize">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:host="go" 
        android:path="/logistic" 
        android:scheme="guoguo"/>
    </intent-filter>
    <meta-data android:name="bundleLocation" android:value="com.taobao.cainiao"/>
</activity>
```
没错就是它, `LogisticDetailActivity`就是我们要找的显示物流详情的页面。
反编译的代码中没有对应的`LogisticDetailActivity`的源码,这些部分应该是通过Atlas动态部署的。
`LogisticDetailActivity`在Atlas框架中的声明
``` java FrameworkProperties.java
package android.taobao.atlas.framework;

public class FrameworkProperties {
    public static String autoStartBundles = "com.android.update,com.cainiao.wireless.pr";
    public static String bundleInfo = " 
    ...
    {\"activities\":[\"com.taobao.cainiao.newlogistic.LogisticDetailActivity\"],\"contentProviders\":[],\"dependency\":[],\"isInternal\":true,\"pkgName\":\"com.taobao.cainiao\",\"receivers\":[],\"services\":[],\"unique_tag\":\"67520454e3fdb8fd2307b1c08c602abf\",\"version\":\"4.7.1@1.1.1.12\"}
    ....";

    public static String group = "cainiao4android";
    public static String outApp = "false";
    private String version = "4.7.1";

    public String getVersion() {
        return this.version;
    }
}
```
## 寄件记录
![](http://pic.yupoo.com/yeungeek/Hx08pyWZ/medish.jpg)
为什么分析这个页面,因为这个`cn_wx_page_container`,看id的名字判断出这是weex页面。
UI布局：
``` xml
<LinearLayout android:orientation="vertical" android:background="#fff2f2f2" android:layout_width="fill_parent" android:layout_height="fill_parent"
  xmlns:android="http://schemas.android.com/apk/res/android">
    <com.cainiao.android.cnweexsdk.weex.view.CNWXTopBar android:id="@id/cn_wx_page_topbar" android:layout_width="fill_parent" android:layout_height="?cnWXTopBarHeightStyle" />
    <FrameLayout android:layout_width="fill_parent" android:layout_height="fill_parent">
        <FrameLayout android:id="@id/cn_wx_page_container" android:background="#ffffffff" android:layout_width="fill_parent" android:layout_height="fill_parent" />
        <FrameLayout android:layout_gravity="bottom" android:id="@id/cn_wx_page_cover" android:background="@color/cn_wx_transparent" android:layout_width="fill_parent" android:layout_height="wrap_content" />
        <TextView android:textSize="16.0sp" android:textColor="@color/cn_wx_exception_msg_color" android:layout_gravity="center" android:id="@id/cn_wx_container_page_exception" android:visibility="gone" android:layout_width="140.0dip" 
        android:layout_height="80.0dip" android:text="@string/cn_wx_reload_weex_txt" />
    </FrameLayout>
</LinearLayout>
```
这个页面,通过抓包分析,该页面的请求url：
https://cn.alicdn.com/cainiao-weex/order_center/0.3.0/main/order-center-homepage.js?navtype=weex&__fc__=true&__bs__=black&orderType=send&referrer=guoguo%3A%2F%2Fgo%2Fsendpackage
里面主要是Vue编写的页面代码和逻辑。

## 总结
分析了App三个主要的功能,大致对菜鸟裹裹的UI框架有所了解。
在[Android工程师角度分析App使用的开源框架-3.菜鸟裹裹](http://yeungeek.com/2018/07/15/Android%E5%B7%A5%E7%A8%8B%E5%B8%88%E8%A7%92%E5%BA%A6%E5%88%86%E6%9E%90App%E4%BD%BF%E7%94%A8%E7%9A%84%E5%BC%80%E6%BA%90%E6%A1%86%E6%9E%B6-3-%E8%8F%9C%E9%B8%9F%E8%A3%B9%E8%A3%B9/)一文中,罗列了App使用的一些框架。 
通过分析,物流详情中使用了Atlas,寄件记录使用了Weex,其他的页面,有兴趣的同学可以自行分析。
虽然物流App,不像电商App(淘宝,天猫,京东等)那样要求很高的动态化,不过菜鸟裹裹App使用了很多动态化框架,在不影响操作体验的前提下,又增加了运营可以操作性,还是非常值得学习的。 
以后有关菜鸟裹裹的分享,会集中在从零开始高仿菜鸟裹裹App(计划中),希望同学们多多支持。

