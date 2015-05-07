title: Android监听来电和去电
date: 2014-09-12 11:11:37
tags:
- Phone
categories:
- Phone
---

#Android监听来电和去电
Android在电话状态改变是会发送action为`android.intent.action.PHONE_STATE`的广播，而拨打电话时会发送action为`android.intent.action.NEW_OUTGOING_CALL`的广播。
来电没有直接广播，通过`android.intent.action.PHONE_STATE`和`android.intent.action.NEW_OUTGOING_CALL`两个进行过滤。  
思路：如果电话状态改变了，而且接受到的不是NEW_OUTGOING_CALL广播，可以确定是来电状态，以此来区分拨打电话和来电。
<!-- more -->

##拨打电话
注册Intent.ACTION_NEW_OUTGOING_CALL广播

##来电
结合了拨打电话的广播，非去电就是来电  
通过`TelephonyManager tm = (TelephonyManager)context.getSystemService(Service.TELEPHONY_SERVICE)`  
进行电话状态的获取

##实现
###广播监听
``` java
public class PhoneReceiver extends BroadcastReceiver {
    private static boolean incomingFlag = false;
//    private String incomingNumber;
    @Override
    public void onReceive(Context context, Intent intent) {
        //拨打电话
        if (intent.getAction().equals(Intent.ACTION_NEW_OUTGOING_CALL)) {
            incomingFlag = false;
            final String phoneNum = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER);
            Log.d("PhoneReceiver", "phoneNum: " + phoneNum);
        } else {
            TelephonyManager tm = (TelephonyManager) context.getSystemService(Service.TELEPHONY_SERVICE);
            tm.listen(listener,PhoneStateListener.LISTEN_CALL_STATE);
        }
    }
    final PhoneStateListener listener=new PhoneStateListener(){
        @Override
        public void onCallStateChanged(int state, String incomingNumber) {
            super.onCallStateChanged(state, incomingNumber);
            switch(state){
                //电话等待接听
                case TelephonyManager.CALL_STATE_RINGING:
                    incomingFlag = true;
                    Log.i("PhoneReceiver", "CALL IN RINGING :" + incomingNumber);
                    break;
                //电话接听
                case TelephonyManager.CALL_STATE_OFFHOOK:
                    if (incomingFlag) {
                        Log.i("PhoneReceiver", "CALL IN ACCEPT :" + incomingNumber);
                    }
                    break;
                //电话挂机
                case TelephonyManager.CALL_STATE_IDLE:
                    if (incomingFlag) {
                        Log.i("PhoneReceiver", "CALL IDLE");
                    }
                    break;
            }
        }
    };
}
```

###广播注册
``` xml
<receiver android:name="com.huaban.deskspirit.receiver.PhoneReceiver" >
       <intent-filter>
           <!-- 获取来电广播 -->
           <action android:name="android.intent.action.PHONE_STATE" />
           <!-- 获取去电广播 -->
           <action android:name="android.intent.action.NEW_OUTGOING_CALL" />
       </intent-filter>
</receiver>
```

###注意
拦截的广播不能进行动态注册，动态注册不能监听到`NEW_OUTGOING_CALL`，拨打电话的状态。

虽然是个简单的功能，还是非常的使用的，可以结合**归属地**，**地图**，以及**桌面的电话拦截**等等
