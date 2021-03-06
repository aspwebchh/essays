# <a name="9l9rbw"></a>简述

Executors.newScheduledThreadPool 用于创建一种特殊的线程池，这种线程池用于定时执行任务，它的作用与Timer类似， 但是比Timer更加完善，可以把它当作是Timer的升级版，在能使用此线程池的Java版本种，就不应该再使用Timer。 

```java
ScheduledExecutorService service = Executors.newScheduledThreadPool(10);
```

newScheduledThreadPool接受一个数值，用于指定线程池的基本大小，它返回的ScheduledExecutorService类型是一个接口，具体的实现是 ScheduledThreadPoolExecutor，这从newScheduledThreadPool方法的代码种可以看出。

```java
public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize) {
    return new ScheduledThreadPoolExecutor(corePoolSize);
}
```

ScheduledThreadPoolExecutor有两个常用的方法，用于延时或定制执行任务。

## <a name="vgg6am"></a>schedule方法

schedule方法用于在指定之间之后执行某个任务

```java
service.schedule(()->{
    System.out.println("hello world");
},3, TimeUnit.SECONDS);
```

以上代码设定程序运行3秒后打印hello world字符串。

## <a name="uzwuyg"></a>scheduleAtFixedRate方法

scheduleAtFixedRate方法用于定时重复执行某个任务

```java
service.scheduleAtFixedRate(()->{
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    System.out.println(df.format(new Date()));
},5,1, TimeUnit.SECONDS);
```

以上代码设定程序运行5秒之后每隔一秒打印一次当前的时间

## <a name="k92odr"></a>scheduleWithFixedDelay方法 

scheduleWithFixedDelay方法与scheduleAtFixedRate方法的参数列表是一样的，它们之间的区别在于scheduleAtFixedRate的延时时间是从任务执行开始时计算的， 而scheduleWithFixedDelay是从任务执行完毕结束开始计算的的。 假如任务执行的间隔是5秒，任务本身的执行时间是1秒，那么使用scheduleAtFixedRate方法则任务执行间隔仍旧是5秒， 而使用scheduleWithFixedDelay则是6秒。

# <a name="dk2lzl"></a>与Timer的区别

Timer是基于系统绝对时间的， 当任务在运行时， 如果把系统时间给改了， 那么任务的运行会出问题。 在我的windows 10系统开发机山， 在Timer运行时，将系统时间调为比当前时间更早的时间时，任务会停止运行。 ScheduledThreadPoolExecutor不存在这种问题。 

Timer是基于单线程的， ScheduledThreadPoolExecutor是基于多线程的。当Timer同时执行多个任务时，任务相互之间会造成影响，比如设定某个Timer对象同时执行两个任务，每1秒执行一次，假如任务A代码执行本身就需要消耗1秒时间，也就任务A的真正执行间隔为2秒，那么即使任务B代码执行不消耗任何时间，它的任务间隔也会被拖慢至2秒，因为执行会受到任务A的影响 。 ScheduledThreadPoolExecutor则不会。 

当Timer执行的多个任务中的某个任务抛出异常， 那么其它任务也会受到波及而停止执行，而ScheduledThreadPoolExecutor则不会，因ScheduledThreadPoolExecutor为每个任务分配一个线程，在某个线程中的任务发生异常，其它线程中的任务并不受影响。

