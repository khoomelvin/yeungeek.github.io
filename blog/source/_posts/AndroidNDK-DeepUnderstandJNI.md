---
title: Android NDK-深入理解JNI
date: 2019-08-21 11:21:43
tags:
   - JNI
   - NDK
categories:
   - Android框架层
---
Java调用C/C++在Java语言里面本来就有的，并非Android独有的，即JNI。JNI就是Java调用C++的规范。
<!--more-->
# JNI 概述
JNI，全称为Java Native Interface，即Java本地接口，JNI是Java调用Native语言的一种特性，通过JNI可以使JAVA和 C/C++进行交互。  
Java语言是跨平台的语言，而这跨平台的背后都是依靠Java虚拟机，虚拟机采用C/C++编写，适配各个系统，通过JNI为上层Java提供各种服务，保证跨平台性。  
在Java语言出现前，就有很多程序和库都是由Native语言写的，如果想重复利用这些库，就可以所使用JNI来实现。在Android平台上，JNI就是一座将Java世界和Native世界联通的一座桥梁。  
![jni.png](https://s2.ax1x.com/2019/08/30/mOgNGD.png)
通过JNI，Java世界和Native世界的代码就可以相互访问了。

# JNI实例：Camera
最新有在看系统的Camera相关，所以从系统Camera角度来分析下JNI的应用，下面讲的实例基于Camera2
> Android5.0(21)之后android.hardware.Camera就被废弃了，取而代之的是全新的android.hardware.Camera2

相关代码：
``` java
frameworks/base/core/jni/AndroidRuntime.cpp

frameworks/base/core/java/android/hardware/camera2/impl/CameraMetadataNative.java
frameworks/base/core/jni/android_hardware_camera2_CameraMetadata.cpp
```
Camera2 Java层对应的是CameraMetadataNative.java，Native层对应的是android_hardware_camera2_CameraMetadata.cpp
## Java层CameraMetadataNative
相关代码在CameraMetadataNative.java  
Camera2使用CameraManager(摄像头管理器)进行控制，CameraManager具体的操作会通过CameraMetadataNative来执行。   
CameraMetadataNative的初始化
``` java
public class CameraMetadataNative implements Parcelable
   static {
      /*
      * We use a class initializer to allow the native code to cache some field offsets
      */
      nativeClassInit();
      registerAllMarshalers();
   }
   private static native void nativeClassInit();
}
```
静态方法初始化调用了Native层的方法`nativeClassInit`，这个方法对应的Native层具体实现，是在android_hardware_camera2_CameraMetadata.cpp

## Native层CameraMetadata
Native层相关代码在android_hardware_camera2_CameraMetadata.cpp   
Native方法初始化
``` C++
static const JNINativeMethod gCameraMetadataMethods[] = {
// static methods
  { "nativeClassInit",
    "()V",
    (void *)CameraMetadata_classInit },   //和Java层nativeClassInit()对应
  { "nativeGetAllVendorKeys",
    "(Ljava/lang/Class;)Ljava/util/ArrayList;",
    (void *)CameraMetadata_getAllVendorKeys},
  { "nativeGetTagFromKey",
    "(Ljava/lang/String;)I",
    (void *)CameraMetadata_getTagFromKey },
  { "nativeGetTypeFromTag",
    "(I)I",
    (void *)CameraMetadata_getTypeFromTag },
  { "nativeSetupGlobalVendorTagDescriptor",
    "()I",
    (void*)CameraMetadata_setupGlobalVendorTagDescriptor },
// instance methods
  { "nativeAllocate",
    "()J",
    (void*)CameraMetadata_allocate },
  { "nativeAllocateCopy",
    "(L" CAMERA_METADATA_CLASS_NAME ";)J",
    (void *)CameraMetadata_allocateCopy },
  { "nativeIsEmpty",
    "()Z",
    (void*)CameraMetadata_isEmpty },
  { "nativeGetEntryCount",
    "()I",
    (void*)CameraMetadata_getEntryCount },
  { "nativeClose",
    "()V",
    (void*)CameraMetadata_close },
  { "nativeSwap",
    "(L" CAMERA_METADATA_CLASS_NAME ";)V",
    (void *)CameraMetadata_swap },
  { "nativeReadValues",
    "(I)[B",
    (void *)CameraMetadata_readValues },
  { "nativeWriteValues",
    "(I[B)V",
    (void *)CameraMetadata_writeValues },
  { "nativeDump",
    "()V",
    (void *)CameraMetadata_dump },
// Parcelable interface
  { "nativeReadFromParcel",
    "(Landroid/os/Parcel;)V",
    (void *)CameraMetadata_readFromParcel },
  { "nativeWriteToParcel",
    "(Landroid/os/Parcel;)V",
    (void *)CameraMetadata_writeToParcel },
};
```
gCameraMetadataMethods什么时候会被加载？
``` C++
int register_android_hardware_camera2_CameraMetadata(JNIEnv *env)
{
   ......
   // Register native functions
   return RegisterMethodsOrDie(env,
         CAMERA_METADATA_CLASS_NAME,
         gCameraMetadataMethods,
         NELEM(gCameraMetadataMethods));
}
......
static inline int RegisterMethodsOrDie(JNIEnv* env, const char* className,
                                       const JNINativeMethod* gMethods, int numMethods) {
    int res = AndroidRuntime::registerNativeMethods(env, className, gMethods, numMethods);
    LOG_ALWAYS_FATAL_IF(res < 0, "Unable to register native methods.");
    return res;
}
```
`register_android_hardware_camera2_CameraMetadata`何时会被调用到，这个就需要了解下JNI的查找方式。
## JNI查找方式
> Android系统在启动启动过程中，先启动Kernel创建init进程，紧接着由init进程fork第一个横穿Java和C/C++的进程，即Zygote进程。Zygote启动过程中会AndroidRuntime.cpp中的startVm创建虚拟机，VM创建完成后，紧接着调用startReg完成虚拟机中的JNI方法注册。  

刚才CameraMetadata中`register_android_hardware_camera2_CameraMetadata`方法，在AndroidRuntime.cpp的声明：
``` C++
extern int register_android_hardware_camera2_CameraMetadata(JNIEnv *env);
```
然后在gRegJNI中的静态声明
``` C++
static const RegJNIRec gRegJNI[] = {
    ......
    REG_JNI(register_android_hardware_camera2_CameraMetadata),
    ......
}
```
gRegJNI方法在startReg中被调用
``` C++
/*static*/ int AndroidRuntime::startReg(JNIEnv* env)
{
    ATRACE_NAME("RegisterAndroidNatives");
    androidSetCreateThreadFunc((android_create_thread_fn) javaCreateThreadEtc);
    ALOGV("--- registering native functions ---\n");
  
    env->PushLocalFrame(200);

    if (register_jni_procs(gRegJNI, NELEM(gRegJNI), env) < 0) {
        env->PopLocalFrame(NULL);
        return -1;
    }
    env->PopLocalFrame(NULL);

    //createJavaThread("fubar", quickTest, (void*) "hello");
    return 0;
}
```
register_jni_procs(gRegJNI, NELEM(gRegJNI), env)会循环调用gRegJNI数组成员所对应的方法
``` C++
static int register_jni_procs(const RegJNIRec array[], size_t count, JNIEnv* env)
{
    for (size_t i = 0; i < count; i++) {
        if (array[i].mProc(env) < 0) {
#ifndef NDEBUG
            ALOGD("----------!!! %s failed to load\n", array[i].mName);
#endif
            return -1;
        }
    }
    return 0;
}
```
这样android_hardware_camera2_CameraMetadata.cpp中的`int register_android_hardware_camera2_CameraMetadata(JNIEnv *env)`就会被调用到。   
除了这种Android系统启动时，就注册JNI所对应的方法。还有一种就是程序自定义的JNI方法，以 MediePlay 为例：
相关代码路径
``` java
frameworks/base/media/java/android/media/MediaPlayer.java
frameworks/base/media/jni/android_media_MediaPlayer.cpp
```
MediaPlayer声明：
``` java
public class MediaPlayer extends PlayerBase
                         implements SubtitleController.Listener
{
   ......
   private static native final void native_init();
   ......
   static {
      System.loadLibrary("media_jni");
      native_init();
   }
}
```
静态代码块中使用System.loadLibrary加载动态库，media_jni在Android平台对应的是libmedia_jni.so库。   
在jni目录`/frameworks/base/media/jni/Android.mk`中有相应的声明：
``` c++
LOCAL_SRC_FILES:= \
android_media_MediaPlayer.cpp \
...
LOCAL_MODULE:= libmedia_jni
```
在`android_media_MediaPlayer.cpp`找到对应的Native(natvie_init)方法：
``` C++
static void
android_media_MediaPlayer_native_init(JNIEnv *env)
{
    jclass clazz;

    clazz = env->FindClass("android/media/MediaPlayer");
    if (clazz == NULL) {
        return;
    }
    ......
}
```
JNI注册的方法就是上面描述的两种方法：
* 在Android系统启动时注册，在AndroidRuntime.cpp中的gRegJNI方法中声明
* 使用System.loadLibrary()方式注册

# JNI基础
上面一节主要描述了系统中Java层和Native层交互和实现，并没有对JNI的基础理论，流程进行分析
## JNI命名规则
JNI方法名规范 :
```
返回值 + Java前缀 + 全路径类名 + 方法名 + 参数① JNIEnv + 参数② jobject + 其它参数
```
简单的一个例子，返回一个字符串
``` C++
extern "C" JNIEXPORT jstring JNICALL
Java_com_yeungeek_jnisample_NativeHelper_stringFromJNI(JNIEnv *env, jclass jclass1) {
    LOGD("##### from c");

    return env->NewStringUTF("Hello JNI");
}
```
* 返回值：jstring
* 全路径类名：com_yeungeek_jnisample_NativeHelper
* 方法名：stringFromJNI

## JNI开发流程
* 在Java中先声明一个native方法
* 编译Java源文件javac得到.class文件
* 通过javah -jni命令导出JNI的.h头文件
* 使用Java需要交互的本地代码，实现在Java中声明的Native方法（如果Java需要与C++交互，那么就用C++实现Java的Native方法。）
* 将本地代码编译成动态库(Windows系统下是.dll文件，如果是Linux系统下是.so文件，如果是Mac系统下是.jnilib)
* 通过Java命令执行Java程序，最终实现Java调用本地代码。

## 数据类型
### 基本数据类型
| Signature | Java | Native|
| :--- | :---- | :---- | 
|B|byte|jbyte|
|C|char|jchar|
|D|double|jdouble|
|F|float|jfloat|
|I|int|jint|
|S|short|jshort|
|J|long|jlong|
|Z|boolean|jboolean|
|V|void|jvoid|

### 引用数据类型
| Signature | Java | Native|
| :--- | :---- | :---- | 
|L+classname +;|Object|jobject|
|Ljava/lang/String;|String|jstring|
|[L+classname +;|Object[]|jobjectArray|
|Ljava.lang.Class;|Class|jclass|
|Ljava.lang.Throwable;|Throwable|jthrowable|
|[B|byte[]|jbyteArray|
|[C|char[]|jcharArray|
|[D|double[]|jdoubleArray|
|[F|float[]|jfloatArray|
|[I|int[]|jintArray|
|[S|short[]|jshortArray|
|[J|long[]|jlongArray|
|[Z|boolean[]|jbooleanArray|

## 方法签名
JNI的方法签名的格式：
```
(参数签名格式...)返回值签名格式
```
demo的native 方法：
```java
public static native java.lang.String stringFromJNI();
```
可以通过javap命令生成方法签名``：
``` java
()Ljava/lang/String;
```
# JNI原理
Java语言的执行环境是Java虚拟机(JVM)，JVM其实是主机环境中的一个进程，每个JVM虚拟机都在本地环境中有一个JavaVM结构体，该结构体在创建Java虚拟机时被返回，在JNI环境中创建JVM的函数为JNI_CreateJavaVM。   
JNI 定义了两个关键数据结构，即“JavaVM”和“JNIEnv”，两者本质上都是指向函数表的二级指针。
## JavaVM
JavaVM是Java虚拟机在JNI层的代表，JavaVM 提供了“调用接口”函数，您可以利用此类函数创建和销毁 JavaVM。理论上，每个进程可以包含多个JavaVM，但AnAndroid只允许每个进程包含一个JavaVM。
## JNIEnv
JNIEnv是一个线程相关的结构体，该结构体代表了Java在本线程的执行环境。JNIEnv 提供了大多数 JNI 函数。您的原生函数均会接收 JNIEnv 作为第一个参数。   
JNIEnv作用：
* 调用Java函数
* 操作Java代码

JNIEnv定义(jni.h)：
`libnativehelper/include/nativehelper/jni.h`
``` c++
#if defined(__cplusplus)
typedef _JNIEnv JNIEnv;
typedef _JavaVM JavaVM; 
#else
typedef const struct JNINativeInterface* JNIEnv;
typedef const struct JNIInvokeInterface* JavaVM;
#endif
```
定义中可以看到JavaVM，Android中一个进程只会有一个JavaVM，一个JVM对应一个JavaVM结构，而一个JVM中可能创建多个Java线程，每个线程对应一个JNIEnv结构
![javavm.png](https://s2.ax1x.com/2019/09/01/n9wYL9.png)


## 注册JNI函数
Java世界和Native世界的方法是如何关联的，就是通过JNI函数注册来实现。JNI函数注册有两种方式：
### 静态注册
这种方法就是通过函数名来找对应的JNI函数，可以通过`javah`命令行来生成JNI头文件
``` basic
javah com.yeungeek.jnisample.NativeHelper
```
生成对应的`com_yeungeek_jnisample_NativeHelper.h`文件，生成对应的JNI函数，然后在实现这个函数就可以了
``` C++
/*
 * Class:     com_yeungeek_jnisample_NativeHelper
 * Method:    stringFromJNI
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_yeungeek_jnisample_NativeHelper_stringFromJNI
  (JNIEnv *, jclass);
```
静态注册方法中，Native是如何找到对应的JNI函数，在[JNI查找方式](#JNI查找方式)中介绍系统的流程，并没有详细说明静态注册的查找。这里简单说明下这个过程(以上面的声明为例子s)：  
当Java调用native stringFromJNI函数时，会从对应JNI库中查找`Java_com_yeungeek_jnisample_NativeHelper_stringFromJNI`函数，如果没有找到，就会报错。  
静态注册方法，就是根据函数名来关联Java函数和JNI函数，JNI函数需要遵循特定的格式，这其中就有一些缺点：
* 声明了native方法的Java类，需要通过`javah`来生成头文件
* JNI函数名称非常长
* 第一次调用native函数，需要通过函数名来搜索关联对应的JNI函数，效率比较低

如何解决这些问题，让native函数，提前知道JNI函数，就可以解决这个问题，这个过程就是动态注册。
### 动态注册
动态注册在前面的Camera例子中，已经有涉及到，JNI函数`classInit`的声明。
``` C++
static const JNINativeMethod gCameraMetadataMethods[] = {
// static methods
  { "nativeClassInit",
    "()V",
    (void *)CameraMetadata_classInit },   //和Java层nativeClassInit()对应
   ......
}
```
JNI中有一种结构用来记录Java的Native方法和JNI方法的关联关系，它就是JNINativeMethod，它在jni.h中被定义：
``` C++
typedef struct {
    const char* name;  //Java层native函数名
    const char* signature; //Java函数签名，记录参数类型和个数，以及返回值类型
    void*       fnPtr; //Native层对应的函数指针
} JNINativeMethod;
```
在[JNI查找方式](#JNI查找方式)说到，JNI注册的两种时间，第一种已经介绍过了，我们自定义的native函数，基本都是会使用`System.loadLibrary(“xxx”)`，来进行JNI函数的关联。
#### loadLibrary(Android7.0)
``` java
public static void loadLibrary(String libname) {
   Runtime.getRuntime().loadLibrary0(VMStack.getCallingClassLoader(), libname);
}
```
调用到Runtime(libcore/ojluni/src/main/java/java/lang/Runtime.java)的loadLibrary0方法：
``` java
synchronized void loadLibrary0(ClassLoader loader, String libname) {
   ......
   String libraryName = libname;
   if (loader != null) {
      String filename = loader.findLibrary(libraryName);
      if (filename == null) {
            // It's not necessarily true that the ClassLoader used
            // System.mapLibraryName, but the default setup does, and it's
            // misleading to say we didn't find "libMyLibrary.so" when we
            // actually searched for "liblibMyLibrary.so.so".
            throw new UnsatisfiedLinkError(loader + " couldn't find \"" +
                                          System.mapLibraryName(libraryName) + "\"");
      }
      //doLoad
      String error = doLoad(filename, loader);
      if (error != null) {
            throw new UnsatisfiedLinkError(error);
      }
      return;
   }
   //loader 为 null
   ......
   for (String directory : getLibPaths()) {
      String candidate = directory + filename;
      candidates.add(candidate);

      if (IoUtils.canOpenReadOnly(candidate)) {
            String error = doLoad(candidate, loader);
            if (error == null) {
               return; // We successfully loaded the library. Job done.
            }
            lastError = error;
      }
   }
   ......
}
```
#### doLoad
``` java
private String doLoad(String name, ClassLoader loader) {
   //调用 native 方法
   synchronized (this) {
      return nativeLoad(name, loader, librarySearchPath);
   }
}
```
#### nativeLoad
进入到虚拟机代码`/libcore/ojluni/src/main/native/Runtime.c`
``` c++
JNIEXPORT jstring JNICALL
Runtime_nativeLoad(JNIEnv* env, jclass ignored, jstring javaFilename,
                   jobject javaLoader, jstring javaLibrarySearchPath)
{
    return JVM_NativeLoad(env, javaFilename, javaLoader, javaLibrarySearchPath);
}
```
然后调用`JVM_NativeLoad`，JVM_NativeLoad方法申明在jvm.h中，实现在`OpenjdkJvm.cc(/art/runtime/openjdkjvm/OpenjdkJvm.cc)`
``` C++
JNIEXPORT jstring JVM_NativeLoad(JNIEnv* env,
                                 jstring javaFilename,
                                 jobject javaLoader,
                                 jstring javaLibrarySearchPath) {
  ScopedUtfChars filename(env, javaFilename);
  if (filename.c_str() == NULL) {
    return NULL;
  }

  std::string error_msg;
  {
    art::JavaVMExt* vm = art::Runtime::Current()->GetJavaVM();
    bool success = vm->LoadNativeLibrary(env,
                                         filename.c_str(),
                                         javaLoader,
                                         javaLibrarySearchPath,
                                         &error_msg);
    if (success) {
      return nullptr;
    }
  }

  // Don't let a pending exception from JNI_OnLoad cause a CheckJNI issue with NewStringUTF.
  env->ExceptionClear();
  return env->NewStringUTF(error_msg.c_str());
}
```
#### LoadNativeLibrary
调用JavaVMExt的LoadNativeLibrary方法，方法在(art/runtime/java_vm_ext.cc)中，这个方法代码非常多，选取主要的部分进行分析
``` C++
bool JavaVMExt::LoadNativeLibrary(JNIEnv* env,
                                  const std::string& path,
                                  jobject class_loader,
                                  jstring library_path,
                                  std::string* error_msg) {
         ......
         bool was_successful = false;
         //加载so库中查找JNI_OnLoad方法，如果没有系统就认为是静态注册方式进行的，直接返回true，代表so库加载成功，
         //如果找到JNI_OnLoad就会调用JNI_OnLoad方法，JNI_OnLoad方法中一般存放的是方法注册的函数，
         //所以如果采用动态注册就必须要实现JNI_OnLoad方法，否则调用java中申明的native方法时会抛出异常
         void* sym = library->FindSymbol("JNI_OnLoad", nullptr);
         if (sym == nullptr) {
            VLOG(jni) << "[No JNI_OnLoad found in \"" << path << "\"]";
            was_successful = true;
         } else {
            // Call JNI_OnLoad.  We have to override the current class
            // loader, which will always be "null" since the stuff at the
            // top of the stack is around Runtime.loadLibrary().  (See
            // the comments in the JNI FindClass function.)
            ScopedLocalRef<jobject> old_class_loader(env, env->NewLocalRef(self->GetClassLoaderOverride()));
            self->SetClassLoaderOverride(class_loader);

            VLOG(jni) << "[Calling JNI_OnLoad in \"" << path << "\"]";
            typedef int (*JNI_OnLoadFn)(JavaVM*, void*);
            JNI_OnLoadFn jni_on_load = reinterpret_cast<JNI_OnLoadFn>(sym);
            //调用JNI_OnLoad方法
            int version = (*jni_on_load)(this, nullptr);

            if (runtime_->GetTargetSdkVersion() != 0 && runtime_->GetTargetSdkVersion() <= 21) {
               // Make sure that sigchain owns SIGSEGV.
               EnsureFrontOfChain(SIGSEGV);
            }

            self->SetClassLoaderOverride(old_class_loader.get());
         }
         ......
}                        
```
代码里的主要逻辑：
* 加载so库中查找JNI_OnLoad方法，如果没有系统就认为是静态注册方式进行的，直接返回true，代表so库加载成功
* 如果找到JNI_OnLoad就会调用JNI_OnLoad方法，JNI_OnLoad方法中一般存放的是方法注册的函数
* 所以如果采用动态注册就必须要实现`JNI_OnLoad`方法，否则调用Java中的native方法时会抛出异常

## jclass、jmethodID和jfieldID
如果要通过原生代码访问对象的字段，需要执行以下操作：
1. 使用 FindClass 获取类的类对象引用
2. 使用 GetFieldID 获取字段的字段 ID
3. 使用适当内容获取字段的内容，例如 GetIntField

具体的使用，放在第二篇文章中讲解

## JNI的引用
JNI规范中定义了三种引用：
* 局部引用（Local Reference）
* 全局引用（Global Reference）
* 弱全局引用（Weak Global Reference）

### 局部引用
也叫本地引用，在 JNI层函数使用的非全局引用对象都是Local Reference，最大的特点就是，JNI 函数返回后，这些声明的引用可能就会被垃圾回收
### 全局引用
这种声明的对象，不会主动释放资源，不会被垃圾回收
### 弱全局引用
一种特殊的全局引用，在运行过程中可能被回收，使用之前需要判断下是否为空

# 参考
* [Android：清晰讲解JNI 与 NDK（含实例教学）](https://juejin.im/post/59827fb86fb9a03c341907e6)
* [Android JNI学习](https://www.jianshu.com/nb/22528035)
* [Android JNI原理分析](http://gityuan.com/2016/05/28/android-jni/)
* [Android深入理解JNI（一）JNI原理与静态、动态注册](http://liuwangshu.cn/framework/jni/1-mediarecorder_register.html)
* [JNI Tips](https://developer.android.com/training/articles/perf-jni)
