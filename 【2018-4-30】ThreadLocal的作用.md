# ThreadLocal的作用

### 2018-4-29

来看一段代码

```java
class Main {
    static class Task implements Runnable {
        Map<Long, Object> map = Collections.synchronizedMap(new HashMap<Long,Object>());

        @Override
        public void run() {
            Long id = Thread.currentThread().getId();
            map.put(id, Math.random() * 100);
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println( "thread id :" + id + "; value:" + map.get(id));
        }
    }

    public static void main(String[] args) {
        Task task1 = new Task();
        Thread thread1 = new Thread(task1);
        Thread thread2 = new Thread(task1);
        thread1.start();
        thread2.start();
    }
}
```

代码的逻辑很容易理解，为每个线程生成一个随机数放在一个map数据结构中， 并通过线程的ID进行存取。

然而这么写略微显得有点啰嗦， Java有一项内建的机制来实现这种功能， 也就是ThreadLocal

```java
class Main {
    static class Task1 implements Runnable{
        ThreadLocal<Object> threadLocal = new ThreadLocal<>();

        @Override
        public void run() {
            Long id = Thread.currentThread().getId();
            threadLocal.set(Math.random() * 100);
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println( "thread id :" + id + "; value:" + threadLocal.get());
        }
    }

    public static void main(String[] args) {
        Task1 task1 = new Task1();
        Thread thread1 = new Thread(task1);
        Thread thread2 = new Thread(task1);
        thread1.start();
        thread2.start();
    }
}
```

ThrealLocal是一个容器，只是它有一种奇异的功能，能对不同线程的数据进行归类， 存取的时候能自动识别， 不会造成线程间访问的冲突。 