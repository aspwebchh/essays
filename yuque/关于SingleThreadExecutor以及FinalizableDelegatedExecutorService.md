# ����SingleThreadExecutor�Լ�FinalizableDelegatedExecutorService

Executors.newSingleThreadExecutor�������ڴ���ֻ�õ����̴߳���������̳߳أ��˷�����һ����̬�����������������

```java
    public static ExecutorService newSingleThreadExecutor() {
        return new FinalizableDelegatedExecutorService
            (new ThreadPoolExecutor(1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>()));
    }
```

�Ӵ�����ʵ�����̳߳صĲ��ֿ��Կ�������һ���߳�����Ĭ�ϴ�С������С��Ϊ1���̳߳�

```java
new ThreadPoolExecutor(1, 1,

0L, TimeUnit.MILLISECONDS,

new LinkedBlockingQueue<Runnable>())new ThreadPoolExecutor(1, 1,
                                    0L, TimeUnit.MILLISECONDS,
                                    new LinkedBlockingQueue<Runnable>())
```

�� Executors.newFixedThreadPool(1) ����Ч����<br />Ȼ��newFixedThreadPool��һ������newSingleThreadExecutor�������̳߳��ֱ�һ��FinalizableDelegatedExecutorService��װ��һ�£��������FinalizableDelegatedExecutorService�е�Դ��������˲����������Ǹ�ɶ�õġ�

FinalizableDelegatedExecutorService�Ĵ�������

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

���ܼ򵥣� ֻ�Ǽ̳���DelegatedExecutorService�ಢ������һ��finalize������finalize��������������������������������ʱ�����ã�����֮��FinalizableDelegatedExecutorService��ʵ����ʹ���ֶ�����shutdown�����ر��ֳƳأ������Ҳ�������ɴ����񣬲������Ͻ��ĽǶȳ��������ǻ���Ӧ���ֶ�����shutdown�������Ͼ�Java��finalize����C++�������������ض��ᱻ���ã�Java���������֤finalizeһ���ܱ���ȷ���ã�������ǲ�Ӧ������������

��������DelegatedExecutorService��Դ��������

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

��Ҳ��һ���̳߳أ�ȷ�е�˵���̳߳ص�һ������ģʽ��ʵ�֣��������з����ĵ�����ʵ�Ǳ�ί�е������е�Ŀ���̳߳��ϣ��������Ĺ����Ǳ��˸�ģ� ��Ϊ��ֻʵ�ֲ�ί���˲��ַ�������ʵ�̳߳ش��ڵ���Щδ��ί�еķ��������ｫ�޷�ʹ�á�<br />��������newSingleThreadExecutor�������̳߳���һ��

1. ������������̳߳�
1. shutdown������Ȼ�ᱻ����
1. ���߱�ThreadPoolExecutor���й��ܵ��̳߳�


