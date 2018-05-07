# ReentrantReadWriteLock的理解

同步块和ReentrantLock是排他锁，一旦有线程持有了对象的锁，其他线程想持有锁只能干等，什么也干不了。显然，这种机制粒度有点粗，不灵活，太霸道，对性能不友好。 

Java并发包中了另一种相对灵活的锁叫做 ReentrantReadWriteLock， 这是一个读写锁， 这个类看着是一个锁，其实它维护了一对锁。 

```java
ReadWriteLock readWriteLock = new ReentrantReadWriteLock();
Lock readLock = readWriteLock.readLock();
Lock writeLock = readWriteLock.writeLock();
```

这一对锁分别是读锁和写锁。 写锁可以看成是传统意义上的锁，是独占的，一旦有线程获得锁，其它线程只能排队等待获取锁的线程释放锁以后才能再次获取。 

读锁则不是独占的，它的限制相对宽松。 当一个线程持有读锁后，其它线程以然可以持有读锁，而不会被阻塞，读锁是一个共享锁。 然而， 读锁和写锁却是互斥的，当某个线程持有读锁后，其它线程必须等待读锁被释放后才能持有写锁。  

```java
public class Main {
    static ReadWriteLock readWriteLock = new ReentrantReadWriteLock();
    static Lock readLock = readWriteLock.readLock();
    static Lock writeLock = readWriteLock.writeLock();

    static long time = System.currentTimeMillis();

    static long readTime() {
        try {
            readLock.lock();
            TimeUnit.SECONDS.sleep(5);
            return time;
        } catch (InterruptedException e) {
            e.printStackTrace();
            return -1;
        } finally {
            readLock.unlock();
        }
    }

    static long readTimeSpan() {
        try {
            readLock.lock();
            return System.currentTimeMillis() - time;
        } finally {
            readLock.unlock();
        }
    }

    static long readTimeSpanWithWriteLock() {
        try {
            writeLock.lock();
            return System.currentTimeMillis() - time;
        } finally {
            writeLock.unlock();
        }
    }

    public static void main(String[] args) throws InterruptedException {
        ExecutorService pool = Executors.newFixedThreadPool(3);

        pool.execute(new Runnable() {
            public void run() {
                System.out.println( "time:" + readTime() );
            }
        });
        pool.execute(new Runnable() {
            public void run() {
                System.out.println( "readlock:" + readTimeSpan());
            }
        });
        pool.execute(new Runnable() {
            public void run() {
                System.out.println( "writelock:" + readTimeSpanWithWriteLock());
            }
        });
        pool.shutdown();
    }
}
```

上面的代码main方法中会启动三个形成，第一个线程持有一个读锁5秒。第二个线程也请求一个读锁，但并没有被阻塞，顺利获得结果。 第三个线程请求一个写锁，在读写锁中， 读锁和写锁是互斥的， 读锁阻塞写锁，第三个线程等待5秒后知道第一个线程释放读锁才获得结果。 这三个线程的运行结果说明了读锁和写锁之间的互斥关系。 

此外， ReentrantReadWriteLock是重入锁，在同一个线程中可以嵌套持有锁，持有写锁的线程可以嵌套持有写锁以及读锁，持有读锁的线程可以嵌套持有读锁但是不能持有写锁，否者线程将被阻塞。 

这样可以

```java
writeLock.lock();
readLock.lock();
//dosomething
readLock.unlock();
writeLock.unlock();
```

这样不行

```java
readLock.lock();
writeLock.lock();
//dosomething
writeLock.unlock();
readLock.unlock();
```