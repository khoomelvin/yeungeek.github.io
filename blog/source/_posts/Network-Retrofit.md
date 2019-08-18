---
title: Retrofit源码角度分析Http
date: 2019-07-25 19:31:38
tags:
   - Network
   - Android
   - Http
   - Retrofit
categories:
   - Android应用层
---
上一篇讲解了OKHttp，本篇来介绍下它的黄金搭档Retrofit，OKHttp+Retrofit是网络框架的不二之选。同是Square出品，和OKHttp融合起来非常简单。
Retofit是一个RESTful的HTTP网络请求框架，有以下特点：
* 基于OKHttp
* 通过注解配置网络请求参数
* 支持同步、异步请求
* 支持多种序列化、反序列化格式
* 解耦彻底、模块高度封装，使用很多设计模式来实现
<!--more-->

# 基本使用
下面讲解的是官网的例子
## 创建网络请求接口
``` java
public interface GitHubService {
  @GET("users/{user}/repos")
  Call<List<Repo>> listRepos(@Path("user") String user);
}
```
## 创建Retrofit实例(使用建造者模式)
```
Retrofit retrofit = new Retrofit.Builder()
    .baseUrl("https://api.github.com/")
    .addConverterFactory(GsonConverterFactory.create())
    .build();
```
## 创建网络接口实例
``` java
GitHubService service = retrofit.create(GitHubService.class);

Call<List<Repo>> repos = service.listRepos("yeungeek");
```
## 发送网络请求
默认返回的是OKHttpCall，实际真正发送请求的就是OKHttp
### 同步
``` java
Response<List<Repo>> list = repos.execute()
```
### 异步
``` java
call.enqueue(new Callback<List<Repo>>() {
   @Override
   public void onResponse(Call<List<Repo>> call, Response<List<Repo>> response) {
   }

   @Override
   public void onFailure(Call<List<Repo>> call, Throwable t) {
   }
});
```
# 请求流程
具体的请求流程可以分为7大步骤
![retrofit](https://s2.ax1x.com/2019/08/13/mPNBQK.png)
1. 解析网络请求接口的注解，配置网络请求参数
2. 通过动态代理生成网络请求对象
3. 通过CallAdapter，将网络请求对象进行平台适配(Android,Java8)
4. 通过网络请求执行器(Call)，发送网络请求
5. 通过Converter进行数据解析
6. 通过回调执行器，进行线程切换
7. 在主线程处理返回结果

Refrofit最大特点是使用了大量的设计模式，来进行解耦，下图是完整的流程图(来自[Stay 在 Retrofit分析-漂亮的解耦套路](https://www.jianshu.com/p/45cb536be2f4))：
![retrofit 流程图](https://s2.ax1x.com/2019/08/17/muu48s.png)
接下来通过源码分析，详细讲解上面的流程
# 源码分析
## Retrofit初始化
``` java
Retrofit retrofit = new Retrofit  //1. Retrofit声明
    .Builder()                    //2. Builder
    .baseUrl("https://api.github.com/")   //3. baseUrl
    .addConverterFactory(GsonConverterFactory.create())  //4. Converter Factory
    .addCallAdapterFactory(RxJava2CallAdapterFactory.create())  //5. CallAdapter Factory
    .build();                    //6. 生成实例
```
### Retrofit声明
在使用Retrofit时，首先通过建造者模式构建Retrofit。
``` java
public final class Retrofit {
  private final Map<Method, ServiceMethod<?, ?>> serviceMethodCache = new ConcurrentHashMap<>();

  final okhttp3.Call.Factory callFactory;
  final HttpUrl baseUrl;
  final List<Converter.Factory> converterFactories;
  final List<CallAdapter.Factory> callAdapterFactories;
  final @Nullable Executor callbackExecutor;
  final boolean validateEagerly;

  Retrofit(okhttp3.Call.Factory callFactory, HttpUrl baseUrl,
      List<Converter.Factory> converterFactories, List<CallAdapter.Factory> callAdapterFactories,
      @Nullable Executor callbackExecutor, boolean validateEagerly) {
    this.callFactory = callFactory;
    this.baseUrl = baseUrl;
    this.converterFactories = converterFactories; // Copy+unmodifiable at call site.
    this.callAdapterFactories = callAdapterFactories; // Copy+unmodifiable at call site.
    this.callbackExecutor = callbackExecutor;
    this.validateEagerly = validateEagerly;
  }
  ......
}
```
* serviceMethodCache：网络请求配置对象缓存，通过解析网络请求接口后得到请求对象
* callFactory：网络请求器工厂(Call)，默认实现是OKHttp
* baseUrl：网络请求Url地址
* converterFactories：数据转换器工厂集合
* callAdapterFactories：请求适配器工厂集合
* callbackExecutor：回调方法执行器
* validateEagerly：是否提前验证请求方法

剩下的步骤都是来初始化上面的参数
### Builder
``` java
public static final class Builder {
    private final Platform platform;
    private @Nullable okhttp3.Call.Factory callFactory;
    private HttpUrl baseUrl;
    private final List<Converter.Factory> converterFactories = new ArrayList<>();
    private final List<CallAdapter.Factory> callAdapterFactories = new ArrayList<>();
    private @Nullable Executor callbackExecutor;
    private boolean validateEagerly;

    Builder(Platform platform) {
      this.platform = platform;
    }

    public Builder() {
      this(Platform.get());
    }
    ......
}
```
Builder中的参数和 Retrfit 是意义一一对应的，默认构造函数进行平台的选择
``` java
class Platform {
  private static final Platform PLATFORM = findPlatform();

  static Platform get() {
    return PLATFORM;
  }

  private static Platform findPlatform() {
    try {
      Class.forName("android.os.Build");
      if (Build.VERSION.SDK_INT != 0) {
        return new Android();
      }
    } catch (ClassNotFoundException ignored) {
    }
    try {
      Class.forName("java.util.Optional");
      return new Java8();
    } catch (ClassNotFoundException ignored) {
    }
    return new Platform();
  }
  ......
}
```
通过反射来判断选择Android还是Java8，以前版本还有对IOS平台的支持，最新版本已经去掉了。  
我们看下Android平台：
``` java
static class Android extends Platform {
    @Override public Executor defaultCallbackExecutor() {
      //默认回调执行器，会切换到主线程
      return new MainThreadExecutor();
    }

    @Override CallAdapter.Factory defaultCallAdapterFactory(@Nullable Executor callbackExecutor) {
      if (callbackExecutor == null) throw new AssertionError();
      //默认的 CallAdapter
      return new ExecutorCallAdapterFactory(callbackExecutor);
    }

    static class MainThreadExecutor implements Executor {
      private final Handler handler = new Handler(Looper.getMainLooper());

      @Override public void execute(Runnable r) {
        handler.post(r);
      }
    }
  }
```
### baseUrl
``` java
public Builder baseUrl(String baseUrl) {
   checkNotNull(baseUrl, "baseUrl == null");
   HttpUrl httpUrl = HttpUrl.parse(baseUrl);
   if (httpUrl == null) {
     throw new IllegalArgumentException("Illegal URL: " + baseUrl);
   }
   return baseUrl(httpUrl);
 }
......
public Builder baseUrl(HttpUrl baseUrl) {
  checkNotNull(baseUrl, "baseUrl == null");
  List<String> pathSegments = baseUrl.pathSegments();
  //检查合法性
  if (!"".equals(pathSegments.get(pathSegments.size() - 1))) {
    throw new IllegalArgumentException("baseUrl must end in /: " + baseUrl);
  }
  this.baseUrl = baseUrl;
  return this;
}
```
把String url 转换成HttpUrl，会对baseUrl进行合法性校验(URL参数是不是以"/"结尾)
### ConverterFactory
``` java
public Builder addConverterFactory(Converter.Factory factory) {
   converterFactories.add(checkNotNull(factory, "factory == null"));
   return this;
 }
```
把factory加到数据转换器集合中，看下GsonFactory.create()具体的实现：
``` java
public static GsonConverterFactory create(Gson gson) {
  if (gson == null) throw new NullPointerException("gson == null");
  return new GsonConverterFactory(gson);
}

private final Gson gson;

private GsonConverterFactory(Gson gson) {
  this.gson = gson;
}

@Override
public Converter<ResponseBody, ?> responseBodyConverter(Type type, Annotation[] annotations,
    Retrofit retrofit) {
  TypeAdapter<?> adapter = gson.getAdapter(TypeToken.get(type));
  return new GsonResponseBodyConverter<>(gson, adapter);
}

@Override
public Converter<?, RequestBody> requestBodyConverter(Type type,
    Annotation[] parameterAnnotations, Annotation[] methodAnnotations, Retrofit retrofit) {
  TypeAdapter<?> adapter = gson.getAdapter(TypeToken.get(type));
  return new GsonRequestBodyConverter<>(gson, adapter);
}
```
GsonConverterFactory使用Gson 为初始化参数，实现`responseBodyConverter`和`requestBodyConverter`接口，进行真正的数据转换处理。
### CallAdapterFactory
``` java
public Builder addCallAdapterFactory(CallAdapter.Factory factory) {
  callAdapterFactories.add(checkNotNull(factory, "factory == null"));
  return this;
}
```
把factory加到请求适配器工厂集合中，Android 平台默认实现是ExecutorCallAdapterFactory，后面再进行详细讲解。
### build
最后一步build生成Retrofit对象
``` java
public Retrofit build() {
  if (baseUrl == null) {
    throw new IllegalStateException("Base URL required.");
  }
  
  okhttp3.Call.Factory callFactory = this.callFactory;
  if (callFactory == null) {
    callFactory = new OkHttpClient();
  }

  Executor callbackExecutor = this.callbackExecutor;
  if (callbackExecutor == null) {
    callbackExecutor = platform.defaultCallbackExecutor();
  }

  // Make a defensive copy of the adapters and add the default Call adapter.
  List<CallAdapter.Factory> callAdapterFactories = new ArrayList<>(this.callAdapterFactories);
  callAdapterFactories.add(platform.defaultCallAdapterFactory(callbackExecutor));

  // Make a defensive copy of the converters.
  List<Converter.Factory> converterFactories =
      new ArrayList<>(1 + this.converterFactories.size());

  // Add the built-in converter factory first. This prevents overriding its behavior but also
  // ensures correct behavior when using converters that consume all types.
  converterFactories.add(new BuiltInConverters());
  converterFactories.addAll(this.converterFactories);

  return new Retrofit(callFactory, baseUrl, unmodifiableList(converterFactories),
      unmodifiableList(callAdapterFactories), callbackExecutor, validateEagerly);
}
```
* callFactory配置，默认OkHttpClient
* callbackExecutor配置，Android 平台默认使用`MainThreadExecutor`
* callAdapterFactories配置，先加入自定义的callAdapter，然后再加入defaultCallAdapterFactory
* converterFactories配置，先加入内建转换器(BuiltInConverters)，然后加入自定义的数据转换器
* 生成Retrofit对象

## 创建网络接口实例
``` java
public interface GitHubService {
  @GET("users/{user}/repos")
  Call<List<Repo>> listRepos(@Path("user") String user);
}
//创建接口实例
GitHubService service = retrofit.create(GitHubService.class);
//生成请求对象
Call<List<Repo>> repos = service.listRepos("yeungeek");
```
Retrofit通过外观模式和动态代理生成网络接口实例，网络接口的请求参数从接口声明获取
### create
``` java
public <T> T create(final Class<T> service) {
  Utils.validateServiceInterface(service);
  if (validateEagerly) {
    eagerlyValidateMethods(service);
  }
  return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
      new InvocationHandler() {
        private final Platform platform = Platform.get();
        @Override public Object invoke(Object proxy, Method method, @Nullable Object[] args)
            throws Throwable {
          // If the method is a method from Object then defer to normal invocation.
          if (method.getDeclaringClass() == Object.class) {
            return method.invoke(this, args);
          }
          if (platform.isDefaultMethod(method)) {
            return platform.invokeDefaultMethod(method, service, proxy, args);
          }
          ServiceMethod<Object, Object> serviceMethod =
              (ServiceMethod<Object, Object>) loadServiceMethod(method);
          OkHttpCall<Object> okHttpCall = new OkHttpCall<>(serviceMethod, args);
          return serviceMethod.adapt(okHttpCall);
        }
      });
}
```
create方法中最重要的是使用了动态代理，调用接口的方法都会到Proxy的invoke方法中，在invoke方法中最重要的就是下面三行代码
``` java
ServiceMethod<Object, Object> serviceMethod =
              (ServiceMethod<Object, Object>) loadServiceMethod(method);
OkHttpCall<Object> okHttpCall = new OkHttpCall<>(serviceMethod, args);
return serviceMethod.adapt(okHttpCall);
```
### loadServiceMethod
该方法读取网络请求接口里的方法，根据配置生成ServiceMethod对象
``` java
ServiceMethod<?, ?> loadServiceMethod(Method method) {
  ServiceMethod<?, ?> result = serviceMethodCache.get(method);
  if (result != null) return result;
  synchronized (serviceMethodCache) {
    result = serviceMethodCache.get(method);
    if (result == null) {
      result = new ServiceMethod.Builder<>(this, method).build();
      serviceMethodCache.put(method, result);
    }
  }
  return result;
}
```
loadServiceMethod会先从cache中获取对象，如果获取不到，则通过建造者模式生成ServiceMethod对象。
``` java
new ServiceMethod.Builder<>(this, method).build();
```
#### ServiceMethod
``` java
final class ServiceMethod<R, T> {
  // Upper and lower characters, digits, underscores, and hyphens, starting with a character.
  static final String PARAM = "[a-zA-Z][a-zA-Z0-9_-]*";
  static final Pattern PARAM_URL_REGEX = Pattern.compile("\\{(" + PARAM + ")\\}");
  static final Pattern PARAM_NAME_REGEX = Pattern.compile(PARAM);

  private final okhttp3.Call.Factory callFactory;
  private final CallAdapter<R, T> callAdapter;

  private final HttpUrl baseUrl;
  private final Converter<ResponseBody, R> responseConverter;
  private final String httpMethod;
  private final String relativeUrl;
  private final Headers headers;
  private final MediaType contentType;
  private final boolean hasBody;
  private final boolean isFormEncoded;
  private final boolean isMultipart;
  private final ParameterHandler<?>[] parameterHandlers;

  ServiceMethod(Builder<R, T> builder) {
    this.callFactory = builder.retrofit.callFactory();
    this.callAdapter = builder.callAdapter;
    this.baseUrl = builder.retrofit.baseUrl();
    this.responseConverter = builder.responseConverter;
    this.httpMethod = builder.httpMethod;
    this.relativeUrl = builder.relativeUrl;
    this.headers = builder.headers;
    this.contentType = builder.contentType;
    this.hasBody = builder.hasBody;
    this.isFormEncoded = builder.isFormEncoded;
    this.isMultipart = builder.isMultipart;
    this.parameterHandlers = builder.parameterHandlers;
  }
  ......
}
```
* callFactory：网络请求器工厂，和retrofit对象声明中的含义一样
* callAdapter：网络请求适配器工厂
* baseUrl：网络请求Url地址
* responseConverter：Response 数据转换器
* httpMethod：http 请求方法
* relativeUrl：网络请求相对地址
* headers：网络请求头
* contentType：网络请求 body 类型
* parameterHandlers：方法处理解析器

#### ServiceMethod.Builder
``` java
Builder(Retrofit retrofit, Method method) {
   this.retrofit = retrofit;
   this.method = method;
   this.methodAnnotations = method.getAnnotations();
   this.parameterTypes = method.getGenericParameterTypes();
   this.parameterAnnotationsArray = method.getParameterAnnotations();
}
```
* methodAnnotations：网络请求接口方法注解
* parameterTypes：网络请求接口方法里的参数注解
* parameterAnnotationsArray：网络请求接口方法里的注解内容

#### build
``` java
public ServiceMethod build() {
   //1. 从 Retrofit 中获取网络请求器
   callAdapter = createCallAdapter();
   responseType = callAdapter.responseType();
   if (responseType == Response.class || responseType == okhttp3.Response.class) {
     throw methodError("'"
         + Utils.getRawType(responseType).getName()
         + "' is not a valid response body type. Did you mean ResponseBody?");
   }
   //2. 从 Refrofit 中获取数据转换器
   responseConverter = createResponseConverter();
   for (Annotation annotation : methodAnnotations) {
   //3. 解析网络请求接口中方法的注解
     parseMethodAnnotation(annotation);
   }
   .....
   int parameterCount = parameterAnnotationsArray.length;
   parameterHandlers = new ParameterHandler<?>[parameterCount];
   for (int p = 0; p < parameterCount; p++) {
     Type parameterType = parameterTypes[p];
     if (Utils.hasUnresolvableType(parameterType)) {
       throw parameterError(p, "Parameter type must not include a type variable or wildcard: %s",
           parameterType);
     }
     Annotation[] parameterAnnotations = parameterAnnotationsArray[p];
     if (parameterAnnotations == null) {
       throw parameterError(p, "No Retrofit annotation found.");
     }

     //4. 创建ParameterHandler<?>，用来解析来解析参数使用到注解
     parameterHandlers[p] = parseParameter(p, parameterType, parameterAnnotations);
   }
   ......
   return new ServiceMethod<>(this);
}
```
createCallAdapter：根据接口方法返回类型、接口请求的注解，获取网络请求器
``` java
private CallAdapter<T, R> createCallAdapter() {
  //获取接口方法的返回类型
  Type returnType = method.getGenericReturnType();
  if (Utils.hasUnresolvableType(returnType)) {
    throw methodError(
        "Method return type must not include a type variable or wildcard: %s", returnType);
  }
  if (returnType == void.class) {
    throw methodError("Service methods cannot return void.");
  }
  //获取接口请求的注解
  Annotation[] annotations = method.getAnnotations();
  try {
    //noinspection unchecked
    return (CallAdapter<T, R>) retrofit.callAdapter(returnType, annotations);
  } catch (RuntimeException e) { // Wide exception range because factories are user code.
    throw methodError(e, "Unable to create call adapter for %s", returnType);
  }
}
```

createResponseConverter：根据接口请求注解类型、返回类型，获取数据数据转换器
``` java
private Converter<ResponseBody, T> createResponseConverter() {
  //获取接口请求的注解
  Annotation[] annotations = method.getAnnotations();
  try {
     //从Rtrofit中获取数据转换器
    return retrofit.responseBodyConverter(responseType, annotations);
  } catch (RuntimeException e) { // Wide exception range because factories are user code.
    throw methodError(e, "Unable to create converter for %s", responseType);
  }
}
```
parseMethodAnnotation：解析请求接口的方法注解，主要有以下标签
* Http请求方法
* Headers
* Multipart
* FormUrlEncoded

parseParameter：对方法的参数注解进行解析   
包含：Url，Path，Query，QueryName，QueryMap，Header，HeaderMap，Field，FieldMap，Part，PartMap，Body
``` java
private ParameterHandler<?> parseParameter(
    int p, Type parameterType, Annotation[] annotations) {
  ParameterHandler<?> result = null;
  for (Annotation annotation : annotations) {
    //参数注解解析
    ParameterHandler<?> annotationAction = parseParameterAnnotation(
        p, parameterType, annotations, annotation);
    if (annotationAction == null) {
      continue;
    }
    if (result != null) {
      throw parameterError(p, "Multiple Retrofit annotations found, only one allowed.");
    }
    result = annotationAction;
  }
  if (result == null) {
    throw parameterError(p, "No Retrofit annotation found.");
  }
  return result;
}
```
### OKHttpCall
根据serviceMethod和请求参数，创建OkHttpCall对象
``` java
final class OkHttpCall<T> implements Call<T> {
  private final ServiceMethod<T, ?> serviceMethod;
  private final @Nullable Object[] args;

  private volatile boolean canceled;

  @GuardedBy("this")
  private @Nullable okhttp3.Call rawCall;
  @GuardedBy("this") // Either a RuntimeException, non-fatal Error, or IOException.
  private @Nullable Throwable creationFailure;
  @GuardedBy("this")
  private boolean executed;

  OkHttpCall(ServiceMethod<T, ?> serviceMethod, @Nullable Object[] args) {
    this.serviceMethod = serviceMethod;
    this.args = args;
  }
  ......
}
```
serviceMethod和 args不做介绍了
* rawCall：OKHttp，真正发送网络请求
* canceled：取消请求标志位
* executed：是否执行标志位
* creationFailure：异常标志位

### adapt
根据ServiceMethod的中的callAdapter，来真正执行adapt方法  
ServiceMethod的adapt方法
``` java
T adapt(Call<R> call) {
   return callAdapter.adapt(call);
}
```
Android 默认的返回 ExecutorCallAdapterFactory的Call  
这里使用了静态代理delegate，加入一些额外的操作
``` java
public Call<Object> adapt(Call<Object> call) {
   return new ExecutorCallAdapterFactory.ExecutorCallbackCall(ExecutorCallAdapterFactory.this.callbackExecutor, call);
}
......
ExecutorCallbackCall(Executor callbackExecutor, Call<T> delegate) {
   this.callbackExecutor = callbackExecutor;
   this.delegate = delegate;
}
```

RxJavaCallAdapterFactory返回的是Observable
``` java
@Override public Object adapt(Call<R> call) {
  Observable<Response<R>> responseObservable = isAsync
      ? new CallEnqueueObservable<>(call)
      : new CallExecuteObservable<>(call);
  Observable<?> observable;
  if (isResult) {
    observable = new ResultObservable<>(responseObservable);
  } else if (isBody) {
    observable = new BodyObservable<>(responseObservable);
  } else {
    observable = responseObservable;
  }
  if (scheduler != null) {
    observable = observable.subscribeOn(scheduler);
  }
  if (isFlowable) {
    return observable.toFlowable(BackpressureStrategy.LATEST);
  }
  if (isSingle) {
    return observable.singleOrError();
  }
  if (isMaybe) {
    return observable.singleElement();
  }
  if (isCompletable) {
    return observable.ignoreElements();
  }
  return observable;
}
```
经过上面几步操作 `Call<List<Repo>> repos = service.listRepos("yeungeek")`，返回了一个 OKHttpCall 对象。
## 发送网络请求
请求和 OKHttp 一样，分为同步请求和异步请求
### 同步请求
execute 首先会调用ExecutorCallbackCall的execute方法：
``` java
@Override public Response<T> execute() throws IOException {
  return delegate.execute();
}
```
delegate代理实际是 OKHttpCall，最终会调用OKHttpCall的execute方法
``` java
@Override public Response<T> execute() throws IOException {
  okhttp3.Call call;
  ......
    call = rawCall;
    if (call == null) {
      try {
        call = rawCall = createRawCall();
      } catch (IOException | RuntimeException | Error e) {
        throwIfFatal(e); //  Do not assign a fatal error to creationFailure.
        creationFailure = e;
        throw e;
      }
    }
  }
  if (canceled) {
    call.cancel();
  }
  return parseResponse(call.execute());
}
```
#### createRawCall
创建真正发送的请求Request对象
``` java
private okhttp3.Call createRawCall() throws IOException {
  okhttp3.Call call = serviceMethod.toCall(args);
  if (call == null) {
    throw new NullPointerException("Call.Factory returned null.");
  }
  return call;
}
//调用serviceMethod的 toCall 方法
okhttp3.Call toCall(@Nullable Object... args) throws IOException {
  //Request 的 builder 生成 Reuqest 对象
  RequestBuilder requestBuilder = new RequestBuilder(httpMethod, baseUrl, relativeUrl, headers,
      contentType, hasBody, isFormEncoded, isMultipart);
  @SuppressWarnings("unchecked") // It is an error to invoke a method with the wrong arg types.
  ParameterHandler<Object>[] handlers = (ParameterHandler<Object>[]) parameterHandlers;
  int argumentCount = args != null ? args.length : 0;
  if (argumentCount != handlers.length) {
    throw new IllegalArgumentException("Argument count (" + argumentCount
        + ") doesn't match expected count (" + handlers.length + ")");
  }
  for (int p = 0; p < argumentCount; p++) {
    handlers[p].apply(requestBuilder, args[p]);
  }
  return callFactory.newCall(requestBuilder.build());
}
```
#### parseResponse
调用OKHttp的execute发送网络请求，根据网络请求结果再进行结果解析
``` java
Response<T> parseResponse(okhttp3.Response rawResponse) throws IOException {
  ResponseBody rawBody = rawResponse.body();
  // Remove the body's source (the only stateful object) so we can pass the response along.
  rawResponse = rawResponse.newBuilder()
      .body(new NoContentResponseBody(rawBody.contentType(), rawBody.contentLength()))
      .build();
  int code = rawResponse.code();
  if (code < 200 || code >= 300) {
    try {
      // Buffer the entire body to avoid future I/O.
      ResponseBody bufferedBody = Utils.buffer(rawBody);
      return Response.error(bufferedBody, rawResponse);
    } finally {
      rawBody.close();
    }
  }
  if (code == 204 || code == 205) {
    rawBody.close();
    return Response.success(null, rawResponse);
  }
  ExceptionCatchingRequestBody catchingBody = new ExceptionCatchingRequestBody(rawBody);
  try {
    T body = serviceMethod.toResponse(catchingBody);
    return Response.success(body, rawResponse);
  } catch (RuntimeException e) {
    // If the underlying source threw an exception, propagate that rather than indicating it was
    // a runtime exception.
    catchingBody.throwIfCaught();
    throw e;
  }
}
```
先对响应码进行处理，再通过serviceMethod.toResponse选择数据转换器，对数据进行解析后，生成Response对象返回
### 异步请求
异步请求的流程和同步请求一样，就是再回调处理会进行线程切换   
ExecutorCallbackCall的enqueue方法
``` java
@Override public void enqueue(final Callback<T> callback) {
  checkNotNull(callback, "callback == null");

  delegate.enqueue(new Callback<T>() {
    @Override public void onResponse(Call<T> call, final Response<T> response) {
      callbackExecutor.execute(new Runnable() {
        @Override public void run() {
          if (delegate.isCanceled()) {
            // Emulate OkHttp's behavior of throwing/delivering an IOException on cancellation.
            callback.onFailure(ExecutorCallbackCall.this, new IOException("Canceled"));
          } else {
            callback.onResponse(ExecutorCallbackCall.this, response);
          }
        }
      });
    }

    @Override public void onFailure(Call<T> call, final Throwable t) {
      callbackExecutor.execute(new Runnable() {
        @Override public void run() {
          callback.onFailure(ExecutorCallbackCall.this, t);
        }
      });
    }
  });
}
```
代理执行加入了线程切换到逻辑，通过callbackExecutor切换到主线程   
OKHttpCall的enqueue方法：
``` java
  @Override public void enqueue(final Callback<T> callback) {
    checkNotNull(callback, "callback == null");

    okhttp3.Call call;
    Throwable failure;

    synchronized (this) {
      if (executed) throw new IllegalStateException("Already executed.");
      executed = true;

      call = rawCall;
      failure = creationFailure;
      if (call == null && failure == null) {
        try {
          call = rawCall = createRawCall();
        } catch (Throwable t) {
          throwIfFatal(t);
          failure = creationFailure = t;
        }
      }
    }

    if (failure != null) {
      callback.onFailure(this, failure);
      return;
    }

    if (canceled) {
      call.cancel();
    }

    call.enqueue(new okhttp3.Callback() {
      @Override public void onResponse(okhttp3.Call call, okhttp3.Response rawResponse) {
        Response<T> response;
        try {
          response = parseResponse(rawResponse);
        } catch (Throwable e) {
          callFailure(e);
          return;
        }

        try {
          callback.onResponse(OkHttpCall.this, response);
        } catch (Throwable t) {
          t.printStackTrace();
        }
      }

      @Override public void onFailure(okhttp3.Call call, IOException e) {
        callFailure(e);
      }

      private void callFailure(Throwable e) {
        try {
          callback.onFailure(OkHttpCall.this, e);
        } catch (Throwable t) {
          t.printStackTrace();
        }
      }
    });
  }
```
如果使用到RxJava，在上一节已经提到， adapt会进行适配，RxJava2CallAdapter的adapt方法中有对RxJava转换，具体逻辑实现这边先不展开
``` java
Observable<Response<R>> responseObservable = isAsync
        ? new CallEnqueueObservable<>(call)
        : new CallExecuteObservable<>(call);
```
# Retrofit中的HTTP实现
Retrofit真正请求网络，底层使用的是OKHttp，Refrofit主要负责网络请求接口的封装，看下源码中与HTTP相关的注解
![Retrofit-HTTP](https://s2.ax1x.com/2019/08/17/munlOf.png)
这些注解都是在接口上的声明，主要是HTTP的请求方法和参数，具体可以参考[Android网络编程-HTTP/HTTPS](/2019/07/12/Network-Http/#请求报文)，这里也不具体展开了
# 设计模式应用
我们再回顾下这张流程图:
![retrofit-stay](https://s2.ax1x.com/2019/08/17/muu48s.png)
## 构建者模式
这个模式运用的比较多，Retrofit的Builder，ServiceMethod的Builder等   
设计模式可以参考[建造者模式（Bulider模式）详解](http://c.biancheng.net/view/1354.html)
## 工厂模式
在Retrofit 初始化，addCallAdapterFactory中的CallAdapter就是用工厂方法模式
``` java
public interface CallAdapter<R, T> {
  Type responseType();
  T adapt(Call<R> call);

  abstract class Factory {
    public abstract @Nullable CallAdapter<?, ?> get(Type returnType, Annotation[] annotations,
        Retrofit retrofit);

    protected static Type getParameterUpperBound(int index, ParameterizedType type) {
      return Utils.getParameterUpperBound(index, type);
    }
    protected static Class<?> getRawType(Type type) {
      return Utils.getRawType(type);
    }
  }
}
```
实现Factory中抽象方法get，就会返回不同的 CallAdapter 对象
设计模式可以参考[工厂方法模式（详解版）](http://c.biancheng.net/view/1348.html)
## 外观模式(门面模式)
Retrofit 就是一个典型的外观类，它屏蔽了所有的实现细节，提供给使用者方便的接口，统一调用创建接口实例和网络请求配置的方法     
设计模式可以参考[外观模式（Facade模式）详解](http://c.biancheng.net/view/1369.html)
## 策略模式
主要应用CallAdapter类的adapt方法，在 Retrofit addCallAdapterFactory，对应 Factory 生成不同的CallAdapter，adapt就可以调用到不同实现   
CallAdapter就是一个Strategy，Retrofit 对应上下文(Context)
设计模式可以参考[策略模式（策略设计模式）详解](http://c.biancheng.net/view/1378.html)
## 适配器模式
还是在CallAdapter得到应用，Retrofit可以适配Android，Java8，RxJava,guava等平台， 不同平台有不同的特性，addCallAdapterFactory可以生成不同的平台的CallAdapter，把不同平台的特性，统一在一个接口中
设计模式可以参考[适配器模式（Adapter模式）详解](http://c.biancheng.net/view/1361.html)
## 代理模式
Retrofit实例的create方法，使用了动态代理模式，网络请求接口，都会调用到`Proxy.newProxyInstance`的 invoke 方法中
``` java
public <T> T create(final Class<T> service) {
  Utils.validateServiceInterface(service);
  if (validateEagerly) {
    eagerlyValidateMethods(service);
  }
  return (T) Proxy.newProxyInstance(service.getClassLoader(), new Class<?>[] { service },
      new InvocationHandler() {
        private final Platform platform = Platform.get();

        @Override public Object invoke(Object proxy, Method method, @Nullable Object[] args)
            throws Throwable {
          // If the method is a method from Object then defer to normal invocation.
          if (method.getDeclaringClass() == Object.class) {
            return method.invoke(this, args);
          }
          if (platform.isDefaultMethod(method)) {
            return platform.invokeDefaultMethod(method, service, proxy, args);
          }
          ServiceMethod<Object, Object> serviceMethod =
              (ServiceMethod<Object, Object>) loadServiceMethod(method);
          OkHttpCall<Object> okHttpCall = new OkHttpCall<>(serviceMethod, args);
          return serviceMethod.adapt(okHttpCall);
        }
      });
}
```
除了使用动态代理，Retrofit 还使用了静态代理模式，ExecutorCallbackCall的delegate，在发送请求和接收响应的过程中，增加了一些额外逻辑 
``` java
@Override public void enqueue(final Callback<T> callback) {
  checkNotNull(callback, "callback == null");  delegate.enqueue(new Callback<T>() {
    @Override public void onResponse(Call<T> call, final Response<T> response) {
      callbackExecutor.execute(new Runnable() {
        @Override public void run() {
          if (delegate.isCanceled()) {
            // Emulate OkHttp's behavior of throwing/delivering an IOException on cancellation.
            callback.onFailure(ExecutorCallbackCall.this, new IOException("Canceled"));
          } else {
            callback.onResponse(ExecutorCallbackCall.this, response);
          }
        }
      });
    }    @Override public void onFailure(Call<T> call, final Throwable t) {
      callbackExecutor.execute(new Runnable() {
        @Override public void run() {
          callback.onFailure(ExecutorCallbackCall.this, t);
        }
      });
    }
  });
}
```   
设计模式可以参考[代理模式（代理设计模式）详解](http://c.biancheng.net/view/1359.html)   
Retrofit使用了大量的设计模式，上面只是在主流过程使用到的，其他设计模式的应用，大家可以继续深入源码去分析，总之，Refrofit框架是非常值得深入研究的框架

# 参考
* [Retrofit官网](https://square.github.io/retrofit/)
* [Android：手把手带你深入剖析 Retrofit 2.0 源码](https://blog.csdn.net/carson_ho/article/details/73732115)
* [拆轮子系列：拆 Retrofit](https://blog.piasy.com/2016/06/25/Understand-Retrofit/index.html)
* [Retrofit分析-漂亮的解耦套路](https://www.jianshu.com/p/45cb536be2f4)
* [Retrofit2 源码解析之动态代理](https://segmentfault.com/a/1190000014823244)
* [Retrofit分析-经典设计模式案例](https://www.jianshu.com/p/fb8d21978e38)