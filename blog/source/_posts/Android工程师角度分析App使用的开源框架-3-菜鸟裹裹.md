---
title: Android工程师角度分析App使用的开源框架-3.菜鸟裹裹
date: 2018-07-15 21:42:24
tags:
- open source
- android
categories:
- source analysis
---
自从分析完手淘后,感觉已经过去了一个世纪了，尴尬。本来上次说要分析京东和美团的，也没有开始着手，最近对智能物流比较感兴趣，所以这次分析的是菜鸟裹裹App。京东和美团的只能等后面了，抱歉。
<!-- more -->
## App信息
文件: cainiao4android_10004264.apk  
大小: 27.5M  
版本: 4.7.1
## 反编译源码
这次反编译工具依然是[jadx](https://github.com/skylot/jadx)(如果有更好的工具，可以在留言推荐下哦)。
这次分析从`AndroidManifest.xml`文件开始, 菜鸟App的包名：`com.cainiao.wireless`。
### com.cainiao.wireless
#### 源码分析:
 `AndroidManifest.xml`中定义的Application：
``` xml
<application android:theme="@style/Theme.AppCompat.Light.NoActionBar" android:label="菜鸟裹裹" android:icon="@drawable/ic_launcher" 
android:name="android.taobao.atlas.startup.AtlasBridgeApplication"
android:screenOrientation="portrait" android:allowBackup="false" 
android:largeHeap="true" android:supportsRtl="false">
</application>
```
`AtlasBridgeApplication`是atlas框架下apk的真正Application，容器框架结构图：
![](https://alibaba.github.io/atlas/principle-intro/Project_architectured_img/runtime_struct.png)
具体原理参考：[Atlas](https://alibaba.github.io/atlas/principle-intro/Runtime_principle.html)

#### 真正的入口:
那真正的入口在哪里?
在`AtlasBridgeApplication`的`attachBaseContext`方法中有一段代码:
``` java
try {
Class loadClass = getBaseContext().getClassLoader().loadClass("android.taobao.atlas.versionInfo.BaselineInfoManager");
Object invoke = loadClass.getDeclaredMethod("instance", new Class[0]).invoke(loadClass, new Object[0]);
Field declaredField = loadClass.getDeclaredField("mVersionManager");
declaredField.setAccessible(true);
declaredField.set(invoke, KernalVersionManager.instance());
loadClass = getBaseContext().getClassLoader().
loadClass("android.taobao.atlas.bridge.BridgeApplicationDelegate");
this.mBridgeApplicationDelegate = loadClass.getConstructor(new Class[]{Application.class, String.class, String.class, Long.TYPE, Long.TYPE, String.class, Boolean.TYPE, Object.class}).newInstance(new Object[]{this, KernalConstants.PROCESS, KernalConstants.INSTALLED_VERSIONNAME, Long.valueOf(KernalConstants.INSTALLED_VERSIONCODE), Long.valueOf(KernalConstants.LASTUPDATETIME), KernalConstants.APK_PATH, Boolean.valueOf(isUpdated), KernalConstants.dexBooster});
loadClass.getDeclaredMethod("attachBaseContext", new Class[0]).invoke(this.mBridgeApplicationDelegate, new Object[0]);
} catch (Throwable th) {
RuntimeException runtimeException = new RuntimeException(th);
}
```
可以看出实际加载的是`BridgeApplicationDelegate`这个类的`attachBaseContext`方法,该方法也有一段主要逻辑：
``` java
ApplicationInfo applicationInfo = this.mRawApplication.getPackageManager().getApplicationInfo(this.mRawApplication.getPackageName(), 128);
this.mRealApplicationName = applicationInfo.metaData.getString("REAL_APPLICATION");
if (applicationInfo.metaData.getBoolean("multidex_enable")) {
    MultiDex.install(this.mRawApplication);
}
```
所以最后其实加载的真正入口就是在`AndroidManifest.xml`中的名称为`REAL_APPLICATION`的meta-data标签:
``` xml
<meta-data android:name="REAL_APPLICATION" 
android:value="com.cainiao.wireless.CainiaoApplication" />
<meta-data android:name="multidex_enable" android:value="true" />
```
简单分析下 `CainiaoApplication`
``` java
public class CainiaoApplication extends CommonLibraryApplication 
    implements ReactApplication {
    ...
    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        protected boolean getUseDeveloperSupport() {
            return false;
        }

        protected List<ReactPackage> getPackages() {
            return Arrays.asList(new ReactPackage[]{new MainReactPackage(), 
            new CNReactPackage()});
        }
    };

    public void onCreate() {
        super.onCreate();
        if (AppUtils.isDebugMode) {
            if (!LeakCanary.isInAnalyzerProcess(this)) {
                if ("true".equals(SharedPreUtils.getInstance().getLeakCanaryFlag())) {
                    LeakCanary.install(this);
                }
                initStetho();
            } else {
                return;
            }
        }
        Atlas.getInstance().setBundleSecurityChecker(new BundleVerifier() {
            public boolean verifyBundle(String bundlePath) {
                try {
                    if (SecurityGuardManager.getInstance(CommonLibraryApplication.application.getApplicationContext()) != null) {
                        IPkgValidityCheckComponent packageValidityCheckComp = com.taobao.wireless.security.sdk.SecurityGuardManager.getInstance(CommonLibraryApplication.application.getApplicationContext()).getPackageValidityCheckComp();
                        if (packageValidityCheckComp != null) {
                            return packageValidityCheckComp.isPackageValid(bundlePath);
                        }
                    }
                    return true;
                } catch (Throwable e) {
                    throw new RuntimeException("SecException ErrorCode=" + e.getErrorCode(), e);
                }
            }
        });
        ...

        registerActivityLifecycleCallbacks();
    }
}
```
实现了`ReactApplication`，加载`CNReactPackage`模块。
在调试状态下，可以开启`LeakCanary`,`Stetho`。
注册了`ActivityLifecycleCallbacks`回调,具体作用等后期模块分析，在具体介绍。
本次的目的主要分析使用的开源框架。
#### wireless包结构:
![](http://pic.yupoo.com/yeungeek/Huy3VNXi/medish.jpg)


包名 | 描述 | 框架
----|------|------
adapter|各种adapter | 
cdss|数据模型的定义。(db,orm,protocol请求和响应,数据日志记录和同步等)| 
components|组件库。(dao,windvane、weex、rn的hybrid实现,api服务等) | windvane,weex,rn
data|po,jo定义|
im|使用RN模块实现|
jsbridge|定义同步和异步的jsEvent|
location|定位功能,定义了一些模型|高德地图实现
locus|定位功能,主要功能实现|
mtop|淘宝开放平台api(request和response)|
mvp|mvp模型实现|
pegasus|飞马日志统计(阿里都喜欢以动物命名)|
phenix|cache模块|
postman.data.api|测试mtop数据接口吗?|
uikit|自定义view定义|
utils|工具类定义|
wangxin.rn|旺信rn模块|
widget|自定义widget|
wxapi|微信接入|

#### 其他包结构
![](http://pic.yupoo.com/yeungeek/HuyAuwvW/medish.jpg) 
![](http://pic.yupoo.com/yeungeek/HuyAuEjm/medish.jpg)

名称 | 包名 |描述
----|------|------
[atlas](https://github.com/alibaba/atlas)|android.taobao.atlas|动态组件化框架
[windvane](http://www.infoq.com/cn/presentations/mobile-taobao-h5-container-architecture-evolution)|android.taobao.windvane|手淘h5框架
[com.android.dingtalk.share.ddsharemodule](https://open-doc.dingtalk.com/docs/doc.htm?treeId=178&articleId=104986&docType=1)|com.android.dingtalk.share.ddsharemodule|钉钉分享模块
[fresco](https://github.com/facebook/fresco)|com.facebook.fresco|facebook fresco图片加载
[React Native](https://github.com/facebook/react-native)|com.facebook.react|react native,闲鱼已经开始使用Flutter了,阿里还真的是走在技术前沿啊
[zxing](https://github.com/zxing/zxing)|com.google.zxing|二维码
[leakcanary](https://github.com/square/leakcanary)|com.squareup.leakcanary|内存泄露检测工具
[EventBus2.x](https://github.com/greenrobot/EventBus/tree/V2.4.0)|de.greenrobot.event|事件总线框架
[greenDAO2.x](https://github.com/greenrobot/greenDAO/tree/V2.2.1)|de.greenrobot.dao|数据库框架
[mtopsdk](http://open.yunos.com/)||阿里云开放平台
[zbar](http://zbar.sourceforge.net/)|net.sourceforge.zbar| 二维码 c语言实现
[okhttp](https://github.com/square/okhttp)|okhttp3|http网络库,Android必备库

一些比较细节的或者改造过的库，没有去穷举。
通过上面库的使用分析，菜鸟app在hrbird上运用比较多，这个与实际的业务有关(具体哪些业务上使用了,接下来会有一些列文章来分析)。
其他一些库,和以前阿里系的还是比较类似,使用了很多的主流库。
接下来会对菜鸟app进行更深一步的分析,具体分析哪些内容,正在整理中。


