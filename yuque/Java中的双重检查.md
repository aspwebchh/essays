
```java
public class Singleton {

    private static Singleton instance;

    public static Singleton create() {
        if( instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}
```

这是最简单的单例模式实现，看似可用， 可在多线程情形下却会出问题。

要是此单例实现线程安全很简单，只需要将create方法声明为同步方法即可。 

```java
public synchronized static Singleton create() {
    if( instance == null) {
        instance = new Singleton();
    }
    return instance;
}
```

但是这种做法对性能不友好，在实例已经被创建的情况下直接返回也需要synchronized这种重量级的锁定操作，显然不是好方案。 

使用双重检查的单例可以兼顾线程安全与性能问题

```java
public class Singleton {

    private static Singleton instance;

    public static Singleton create() {
        if( instance == null) {
            synchronized (Singleton.class) {
                if( instance == null) 
                    instance = new Singleton();
            }
        }
        return instance;
    }
}
```

此单例的逻辑是先检查instance是否被初始化，如果被初始化则直接返回instance实例。 如果未被初始化，则进入同步快，获得锁， 创建对象。  那为什么在同步快中还要加上一个实例是否为空的判断呢？ 因为但有两个或以上的线程同时进入第一个判断时，当第一个线程释放创建实例成功并释放锁之后，第二个线持有锁进入同步快后仍旧创建操作，只有在同步快是在进行一次判断，才能避免重复创建单例。 换句话说，第一个判断用来保证性能，第二个判断是用来保证正确性的。

事实上，这个单例并不完美，只有把instance变量用volatile关键字修饰才能完全保证程序符合我们的要求运行。 

```java
private volatile  static Singleton instance;
```

因为在不使用volatile关键字修饰的情况

instance被初始化时，可能不能立刻被同步回主内存，从而造成instance变量的值无法让其它线程实时可见，从而照成逻辑上错误。 

