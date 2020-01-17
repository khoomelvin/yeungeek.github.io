---
title: Android Camera-Camera1使用
date: 2020-01-17 09:32:39
tags:
   - Camera
categories:
   - Camera 
---
Android Camera API和Android版本一样，也是碎片化比较严重，所以Google官方推出了[CameraView](https://github.com/google/cameraview)，提供给开发者参考和学习，现在最新的可以使用[Jetpack CameraX](https://developer.android.com/jetpack/androidx/releases/camerax)来开发，大大简化了开发的复杂度。本系列从Camera1->Camera2->CameraView->CameraX，一步步讲解Camera的进化过程，本篇先介绍Camera1的使用。
<!--more-->
相机开发的流程：
1. 检测设备摄像头，打开相机
2. 创建预览画面，显示实时预览画面
3. 设置相机参数，进行拍照监听
4. 监听中，保存图片资源或者直接操作原始数据
5. 释放相机资源

上面的是基本的相机开发流程，不同的Camera API在实现上会有不同，整体流程上还是统一的。  

# Camera1使用
## 权限声明
``` xml
<uses-feature
        android:name="android.hardware.camera"
        android:required="true" />

<uses-permission android:name="android.permission.CAMERA" />
```
相机必须声明`CAMERA`权限，在Android6.0上，你还需要在代码中动态申请权限
``` java
ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA},
                    REQUEST_CAMERA_PERMISSION);
```
## 开发流程
下图是一个开发流程的导览：
[![Camera1开发流程](https://s2.ax1x.com/2020/01/17/lxqhbq.md.png)](https://imgchr.com/i/lxqhbq)

### 打开相机
``` java
Camera.open()
```
该方法的系统源码实现
``` java
public static Camera open() {
    int numberOfCameras = getNumberOfCameras();
    CameraInfo cameraInfo = new CameraInfo();
    for (int i = 0; i < numberOfCameras; i++) {
        getCameraInfo(i, cameraInfo);
        if (cameraInfo.facing == CameraInfo.CAMERA_FACING_BACK) {
            return new Camera(i);
        }
    }
    return null;
}
```
这里会检查可用的摄像头，默认使用的`CameraInfo.CAMERA_FACING_BACK`后置摄像头
### 创建预览画面
这里使用的是`SurfaceView`
``` java
private SurfaceView mSurfaceView;
private SurfaceHolder mSurfaceHolder;
...
mSurfaceHolder = mSurfaceView.getHolder();
mSurfaceHolder.addCallback(new SurfaceHolder.Callback() {
    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        ...
        startPreview();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        releaseCamera();
    }
});
...
private void startPreview() {
    try {
        //设置实时预览
        mCamera.setPreviewDisplay(mSurfaceHolder);
        //Orientation
        setCameraDisplayOrientation();
        //开始预览
        mCamera.startPreview();

        startFaceDetect();
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```
设置预览的时候，可以设置`setPreviewCallback`监听预览数据的回调
``` java
void onPreviewFrame(byte[] data, Camera camera);
```
### 设置相机参数
设置相机参数后，需要重新启动预览，这边在初始化的时候，已经设置好了。
``` java
private void initParameters(final Camera camera) {
    mParameters = camera.getParameters();
    mParameters.setPreviewFormat(ImageFormat.NV21); //default

    if (isSupportFocus(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE)) {
        mParameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
    } else if (isSupportFocus(Camera.Parameters.FOCUS_MODE_AUTO)) {
        mParameters.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
    }

    //设置预览图片大小
    setPreviewSize();
    //设置图片大小
    setPictureSize();

    camera.setParameters(mParameters);
}
```
Camera.Parameters可以设置的参数非常多，这里就介绍几个比较常用的
![Camera.Parameters](https://s2.ax1x.com/2020/01/15/lXPg5q.png)
#### 1.setFocusMode
设置对焦模式    
* FOCUS_MODE_AUTO：自动对焦
* FOCUS_MODE_INFINITY：无穷远
* FOCUS_MODE_MACRO：微距
* FOCUS_MODE_FIXED：固定焦距
* FOCUS_MODE_EDOF：景深扩展
* FOCUS_MODE_CONTINUOUS_PICTURE：持续对焦(针对照片)
* FOCUS_MODE_CONTINUOUS_VIDEO：(针对视频)

#### 2.setPreviewSize
设置预览图片大小
#### 3.setPreviewFormat
支持的格式： 
* ImageFormat.NV16
* ImageFormat.NV21
* ImageFormat.YUY2
* ImageFormat.YV12
* ImgaeFormat.RGB_565
* ImageFormat.JPEG
如果不设置，默认返回NV21的数据

#### 4.setPictureSize
设置保存图片的大小
#### 5.setPictureFormat
设置保存图片的格式，格式和`setPreviewFormat`一样
#### 6.setDisplayOrientation
设置相机预览画面旋转的角度，degress取值0，90，180，270
#### 7.setPreviewDisplay
设置实时预览SurfaceHolder
#### 8.setPreviewCallback
监听相机预览数据回调
#### 9.setParameters
设置相机的Parameters
其他一些设置，大家可以查看Android文档进行相应的设置

### 设置方向
设置相机的预览方向，[orientation比较详细的介绍](https://juejin.im/post/5d6d1155e51d4561ea1a94a4#heading-7)
``` java
private void setCameraDisplayOrientation() {
    Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
    Camera.getCameraInfo(mCameraId, cameraInfo);
    int rotation = getWindowManager().getDefaultDisplay().getRotation();  //自然方向
    int degrees = 0;
    switch (rotation) {
        case Surface.ROTATION_0:
            degrees = 0;
            break;
        case Surface.ROTATION_90:
            degrees = 90;
            break;
        case Surface.ROTATION_180:
            degrees = 180;
            break;
        case Surface.ROTATION_270:
            degrees = 270;
            break;
    }

    int result;
    //cameraInfo.orientation 图像传感方向
    if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
        result = (cameraInfo.orientation + degrees) % 360;
        result = (360 - result) % 360;
    } else {
        result = (cameraInfo.orientation - degrees + 360) % 360;
    }

    mOrientation = result;
    //相机预览方向
    mCamera.setDisplayOrientation(result);
}
```
### 拍照
``` java
private void takePicture() {
    if (null != mCamera) {
        mCamera.takePicture(new Camera.ShutterCallback() {
            @Override
            public void onShutter() {

            }
        }, new Camera.PictureCallback() {
            @Override
            public void onPictureTaken(byte[] data, Camera camera) {
                //base data
            }
        }, new Camera.PictureCallback() {
            @Override
            public void onPictureTaken(final byte[] data, Camera camera) {
                mCamera.startPreview();
                //save data
            }
        });
    }
}
```
takePicture的源码实现：
``` java
public final void takePicture(ShutterCallback shutter, PictureCallback raw,
            PictureCallback jpeg) {
        takePicture(shutter, raw, null, jpeg);
    }
```
* shutter(ShutterCallback)：快门按下后的回调
* raw(PictureCallback)：raw图像数据
* jpeg(PictureCallback)：jpeg图像生成以后的回调

### 释放相机资源
在使用完成后，onPause或者onDestory中进行相机资源的释放
``` java
private void releaseCamera() {
    if (null != mCamera) {
        mCamera.stopPreview();
        mCamera.stopFaceDetection();
        mCamera.setPreviewCallback(null);
        mCamera.release();
        mCamera = null;
    }
}
```
* stopPreview：停止预览
* release：释放资源

Camera1的开发上，还是相对比较简单的，需要定制的功能项比较少，下面一篇开始介绍Camera2的使用。

# 参考
* [Android Camera 编程从入门到精通](https://www.jianshu.com/p/f63f296a920b)
* [Android之Camera1实现相机开发](https://juejin.im/post/5d6d1155e51d4561ea1a94a4)