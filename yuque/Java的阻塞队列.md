## <a name="i2gkir"></a>LinkedBlockingQueue

LinkedBlockingQueue是线程安全的阻塞队列，是经典的生产者/消费者模式的实现。

LinkedBlockingQueue 最常用的是put和take方法，put用来向队列中塞入元素，take用来取出元素。当队列满时，put方法将被阻塞，等待有空余位置塞入元素。当队列为空时take方法将被阻塞，等待有可取出的新元素。 

LinkedBlockingQueue 可以是无界的也可以是有界的，有界队列可能通过指定构造方法参数实例化。 

```java
LinkedBlockingQueue<String>queue = new LinkedBlockingQueue<>(10);
```

此队列最多容纳10个元素，否者put方法将被阻塞。 

无界队列的put不会被阻塞，除非队列中的元素达到 Integer.MAX\_VALUE 数量

除了  put 和 take 方法，LinkedBlockingQueue 还有两对存取方法

 add 和 remove

 offer 和 poll

当队列中元素数量达到上限时，使用add方法写入元素不会阻塞，而是抛出 IllegalStateException 异常

同样当队列为空时，调用 remove 方法也不会阻塞，而是抛出IllegalStateException  异常。 

 offer 和 poll 方法于 add 和 remove 方法的相同之处在于也没有阻塞的功能，不同之处在于它们在存取失败时并不会抛出异常，而是返回 false 

## <a name="z9isul"></a>ArrayBlockingQueue

除了LinkedBlockingQueue ，还又一种与他相似的队列 LinkedBlockingQueue， 它们的作用和使用方法没有差别，只是在实现方式上有所不同， 就跟LinkedList和ArrayList 差不多。不同的是 ArrayBlockingQueue 是一个有界队列，不具备 LinkedBlockingQueue的无界特性。

## <a name="2qh2hm"></a>SynchronousQueue

SynchronousQueue 是一个没有缓冲区的阻塞队列， 当向队列put一个元素时，必须对应有一个take调用，put才能成功， 你可以把它看作是一个长度为0的 LinkedBlockingQueue， 然而，长度为0的LinkedBlockingQueue是无法实例化，如果强行实例化会报LinkedBlockingQueue异常，这也是SynchronousQueue 存在的原因。

## <a name="263agv"></a>PriorityBlockingQueue

PriorityBlockingQueue和其它阻塞队列不同，它不是先进先出的。PriorityBlockingQueue内部是一个堆的数据结构，里面的元素是有顺序的，但使用put操作向PriorityBlockingQueue 中写如一个元素时， 元素按照堆算法被插如到内部数据结构固定的位置。PriorityBlockingQueue 的元素必须是可以比较的，通常我们会给它实现Comparable接口，take会根据相应的优先级取出队列中的元素，这个优先级由元素实现的compareTo方法而定，在PriorityBlockingQueue看来，compareTo返回的值小，则优先级高。 

#### <a name="r5edfb"></a>优先队列（堆）数据结构原理

堆也称为优先队列，与传统的元素按顺序进出的队列不同，堆中的元素是按优先级出队列的，换言之，不管元素何时进入堆，只要元素的优先级高，总是能先出队列。也就是说堆中的元素之间是有某种顺序关系的，是可以排序的。 

堆数据结构的实现并不是一个简单的排序数组，虽然这样也能满足优先队列的实现要求，可是插入和删除元素的效率太低了，通常，堆都是以二叉树结构来组织元素的，所以也叫二叉堆。 

我们假定某个堆护的是一组数值元素，那么，层次越深的节点的值越大，树根的值是最小的，树叶的值是最大的。 

堆中的元素是依次追加到树的叶节点上的， 所以堆的二叉树结构是很整齐的， 不像某些二叉树， 极端情况下会退化成链表。 

在堆上增加一个新节点后， 这个新的节点会和父节点比较，如果值比父节点小， 则和父节点交换位置，如果值比父节点大，则位置不变，并持续这个过程， 直到找到合适的位置位置。 所以在堆中，父节点的值总比子节点的小。 

 在堆中取出元素的时，总是取在根节点的元素，然后在进行结构调整保持堆结构的正确性。通常，根元素被取走以后，会拿最后一个叶子节点顶上，然后再拿这个节点和它的子节点比较，如果子比子节点大， 则和两个子节点中值较小的交换位置，如果比字节点小，则位置保持不变，并持续着个过程，直到找到合适的位置为止。 

显然，这种二叉堆的实现在最坏时间复杂度上要比利用有序数组实现优先队列要低。 

 

 

