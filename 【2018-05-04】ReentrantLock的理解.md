# ReentrantLock的理解

相对与同步快，ReentrantLock的好处是可撤销、支持公平获取锁、支持锁条件

## Condition

ReentrantLock  提供  Condition 机制， 可以调用  ReentrantLock  的
newCondition 方法获得 Condition 实例。

```java
ReentrantLock lock = new ReentrantLock();
Condition cond = lock.newCondition();
```

Condition 对象有两个方法 await 和 signal，功能对应 object 的 wait 和 notify 方法。我们知道调用object的wait和notify方法的代码必须出现在同步快内，ReentrantLock 本就是同步块的替代品， 那么自然需要一种和wait和notify拥有同样效果的机制，因此Condition应运而生。 

```java
public class Main {
    static final ReentrantLock lock = new ReentrantLock();
    static final Condition cond = lock.newCondition();

    static class Task implements Runnable{
        public void run() {
            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            lock.lock();
            System.out.println("notify");
            cond.signal();
            lock.unlock();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(new Task());
        thread.start();
        lock.lock();
        System.out.println("await");
        cond.await();
        lock.unlock();
        System.out.println("end");
    }
}
```

不过 Condition 具有传统的等待\通知模式的不具备的有点： 通过 ReentrantLock 可以创建多一个 Condition 

```java
ReentrantLock lock = new ReentrantLock();
Condition cond = lock.newCondition();
Condition cond2 = lock.newCondition();
```

多 Condition  在   ReentrantReadWriteLock 中会有应用场景
