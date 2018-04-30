# CopyOnWrite容器

### 2018-4-26

## 运行原理

CopyOnWrite容器是Java并发包提供的一类容器，简称COW， 有 CopyOnWriteArrayList和CopyOnWriteArraySet两种，它们的区别已经通过它们的名称表明了，CopyOnWriteArrayList中的元素可重复，CopyOnWriteArraySet中的元素不可以重复。 

COW的实现方式很简单，COW容器持有一个数组对象，在调用add之类的方法往容器中插入元素时 ，容器会先复制一个存放容器元素数组的副本，然后往副本中插入新的元素。这时如果并发的读容器的元素，实际上读的还是旧数组中的元素。当写入完成时，容器会将旧数组的引用指向准专门为写操作复制出来的副本，表示写操作的结束，这个过程在源代码中可以获知

```java
public boolean add(E e) {
    final ReentrantLock lock = this.lock;
    lock.lock();
    try {
        Object[] elements = getArray();
        int len = elements.length;
        Object[] newElements = Arrays.copyOf(elements, len + 1);
        newElements[len] = e;
        setArray(newElements);
        return true;
    } finally {
        lock.unlock();
    }
}
```

## 存在问题

COW有两个问题

第一，因为读操作在源数组上，写操作副本上，所以在写的时候，读到的数据可能是过期的， 如果写入的数据要立马读到，那么就不用用这种容器

第二， 因为写入的时候要先复制一个副本，这会消耗内存和对性能造成影响，所以在使用时这一点是不得不考虑的要素。 此外，为避免频繁复制副本，要尽量减少对容器的写操作， 比入说在写入多个元素是，应调用addAll方法，而不是add。 

## 使用场景

总而言之，COW应该在多写少读的场景下面被使用，比如说缓存。 


参考连接：[http://ifeve.com/java-copy-on-write/](http://ifeve.com/java-copy-on-write/) 

