在当前线程的Runnable中调用Thread.yield方法， 表示当前线程让出CPU执行自己的权利，使CPU可以去执行其它线程，此方法有改变线程优先级的能力。

```java
Thread thread1 = new Thread(() -> {
    for (int i = 0; i < 100; i++) {
        System.out.println(Thread.currentThread().getName() + ":" + i);
        Thread.yield();
    }
});
Thread thread2 = new Thread(() -> {
    for (int i = 0; i < 100; i++) {
        System.out.println(Thread.currentThread().getName() + ":" + i);
        Thread.yield();
    }
});
thread1.start();
thread2.start();
```

代码执行的某个阶段输出的结果如下

```plain
Thread-0:43
Thread-1:48
Thread-0:44
Thread-1:49
Thread-0:45
Thread-1:50
Thread-0:46
Thread-1:51
Thread-0:47
Thread-1:52
Thread-1:53
Thread-0:48
Thread-1:54
Thread-0:49
Thread-1:55
```

两个线程在循环中不断的执行yield方法， 因此会不断的中断自己的执行而将执行机会让给另一个线程，交替输出的结果可以证明这点。 

