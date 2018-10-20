# 关于SingleThreadExecutor以及FinalizableDelegatedExecutorService

Executors.newSingleThreadExecutor方法用于创建只用单个线程处理任务的线程池，此方法是一个静态方法，具体代码如下

```java
    public static ExecutorService newSingleThreadExecutor() {
        return new FinalizableDelegatedExecutorService
            (new ThreadPoolExecutor(1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>()));
    }
```

从代码中实例化线程池的部分可以看出它是一个线程数量默认大小和最大大小都为1的线程池

```java
new ThreadPoolExecutor(1, 1,

0L, TimeUnit.MILLISECONDS,

new LinkedBlockingQueue<Runnable>())new ThreadPoolExecutor(1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>())
```

跟 Executors.newFixedThreadPool(1) 差不多的效果。<br />然而newFixedThreadPool不一样的是newSingleThreadExecutor创建的线程池又被一个FinalizableDelegatedExecutorService包装了一下，如果不看FinalizableDelegatedExecutorService中的源代码会让人不明白在这是干啥用的。

FinalizableDelegatedExecutorService的代码如下

```java
    static class FinalizableDelegatedExecutorService
        extends DelegatedExecutorService {
        FinalizableDelegatedExecutorService(ExecutorService executor) {
            super(executor);
        }
        protected void finalize() {
            super.shutdown();
        }
    }

```

它很简单， 只是继承了DelegatedExecutorService类并增加了一个finalize方法，finalize方法会在虚拟机利用垃圾回收清理对象时被调用，换言之，FinalizableDelegatedExecutorService的实例即使不手动调用shutdown方法关闭现称池，虚拟机也会帮你完成此任务，不过从严谨的角度出发，我们还是应该手动调用shutdown方法，毕竟Java的finalize不是C++的析构函数，必定会被调用，Java虚拟机不保证finalize一定能被正确调用，因此我们不应该依赖于它。

再来看看DelegatedExecutorService，源代码如下

```java
    static class DelegatedExecutorService extends AbstractExecutorService {
        private final ExecutorService e;
        DelegatedExecutorService(ExecutorService executor) { e = executor; }
        public void execute(Runnable command) { e.execute(command); }
        public void shutdown() { e.shutdown(); }
        public List<Runnable> shutdownNow() { return e.shutdownNow(); }
        public boolean isShutdown() { return e.isShutdown(); }
        public boolean isTerminated() { return e.isTerminated(); }
        public boolean awaitTermination(long timeout, TimeUnit unit)
            throws InterruptedException {
            return e.awaitTermination(timeout, unit);
        }
        public Future<?> submit(Runnable task) {
            return e.submit(task);
        }
        public <T> Future<T> submit(Callable<T> task) {
            return e.submit(task);
        }
        public <T> Future<T> submit(Runnable task, T result) {
            return e.submit(task, result);
        }
        public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks)
            throws InterruptedException {
            return e.invokeAll(tasks);
        }
        public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks,
                                             long timeout, TimeUnit unit)
            throws InterruptedException {
            return e.invokeAll(tasks, timeout, unit);
        }
        public <T> T invokeAny(Collection<? extends Callable<T>> tasks)
            throws InterruptedException, ExecutionException {
            return e.invokeAny(tasks);
        }
        public <T> T invokeAny(Collection<? extends Callable<T>> tasks,
                               long timeout, TimeUnit unit)
            throws InterruptedException, ExecutionException, TimeoutException {
            return e.invokeAny(tasks, timeout, unit);
        }
    }
```

它也是一个线程池，确切的说是线程池的一个代理模式的实现，对它所有方法的调用其实是被委托到它持有的目标线程池上，不过它的功能是被阉割的， 因为他只实现并委托了部分方法，真实线程池存在的那些未被委托的方法在这里将无法使用。<br />综上所述newSingleThreadExecutor创建的线程池是一个

1. 单线任务处理的线程池
1. shutdown方法必然会被调用
1. 不具备ThreadPoolExecutor所有功能的线程池


