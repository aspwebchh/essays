# Thread的run方法与start方法的区别

### 2018-4-29

Thread类的start方法用来启动一个线程这点无异议

而run方法其实只是Thread类将执行的动作委托到 Runnable的run方法上而已

这点从Thread类的源代码中可以观察到
```java
    @Override
    public void run() {
        if (target != null) {
            target.run();
        }
    }
```
target变量就是传递给Thread的Runnable的引用



