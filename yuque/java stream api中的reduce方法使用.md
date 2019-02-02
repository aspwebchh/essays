# java stream api中的reduce方法使用

java stream api是对函数式编程的支持，虽然stream api和c# linq比起来就是拖拉机和法拉利的区别，不过勉强能用，总比没有强。

stream api的reduce方法用于对stream中元素进行聚合求值，最常见的用法就是将stream中一连串的值合成为单个值，比如为一个包含一系列数值的数组求和。

reduce方法有三个重载的方法，方法签名如下

```java
Optional<T> reduce(BinaryOperator<T> accumulator);
```

```java
T reduce(T identity, BinaryOperator<T> accumulator);
```

```java
<U> U reduce(U identity,
                 BiFunction<U, ? super T, U> accumulator,
                 BinaryOperator<U> combiner);
```

第一个签名方法接受一个BinaryOperator类型的lambada表达式， 常规应用方法如下

```java
List<Integer> numList = Arrays.asList(1,2,3,4,5);
int result = numList.stream().reduce((a,b) -> a + b ).get();
System.out.println(result);
```

代码实现了对numList中的元素累加。lambada表达式的a参数是表达式的执行结果的缓存，也就是表达式这一次的执行结果会被作为下一次执行的参数，而第二个参数b则是依次为stream中每个元素。如果表达式是第一次被执行，a则是stream中的第一个元素。 

```java
int result = numList.stream().reduce((a,b) -> {
  System.out.println("a=" + a + ",b=" + b);
  return a + b;
} ).get();
```

在表达式中假如打印参数的代码，打印出来的内容如下

```
a=1,b=2
a=3,b=3
a=6,b=4
a=10,b=5
```

表达式被调用了4次， 第一次a和b分别为stream的第一和第二个元素，因为第一次没有中间结果可以传递， 所以 reduce方法实现为直接将第一个元素作为中间结果传递。

第二个签名的实现

```java
T reduce(T identity, BinaryOperator<T> accumulator);
```

与第一个签名的实现的唯一区别是它首次执行时表达式第一次参数并不是stream的第一个元素，而是通过签名的第一个参数identity来指定。我们来通过这个签名对之前的求和代码进行改进

```java
List<Integer> numList = Arrays.asList(1,2,3,4,5);
int result = numList.stream().reduce(0,(a,b) ->  a + b );
System.out.println(result);
```

其实这两种实现几乎差别，第一种比第一种仅仅多了一个字定义初始值罢了。 此外，因为存在stream为空的情况，所以第一种实现并不直接方法计算的结果，而是将计算结果用Optional来包装，我们可以通过它的get方法获得一个Integer类型的结果，而Integer允许null。第二种实现因为允许执行初始值，因此即使stream为空，也不会出现返回结果为null的情况，当stream为空，reduce为直接把初始值返回。

第三种签名的用法相较前两种稍显复杂，犹豫前两种实现有一个缺陷，它们的计算结果必须和stream中的元素类型相同，如上面的代码示例，stream中的类型为int，那么计算结果也必须为int，这导致了灵活性的不足，甚至无法完成某些任务， 比入我们咬对一个一系列int值求和，但是求和的结果用一个int类型已经放不下，必须升级为long类型，此实第三签名就能发挥价值了，它不将执行结果与stream中元素的类型绑死。

```java
List<Integer> numList = Arrays.asList(Integer.MAX_VALUE,Integer.MAX_VALUE);
long result = numList.stream().reduce(0L,(a,b) ->  a + b, (a,b)-> 0L );
System.out.println(result);
```

如上代码所示，它能见int类型的列表合并成long类型的结果。 
当然这只是其中一种应用罢了，犹豫拜托了类型的限制我们还可以通过他来灵活的完成许多任务，比入将一个int类型的ArrayList转换成一个String类型的ArrayList

```java
List<Integer> numList = Arrays.asList(1, 2, 3, 4, 5, 6);
ArrayList<String> result = numList.stream().reduce(new ArrayList<String>(), (a, b) -> {
	a.add("element-" + Integer.toString(b));
	return a;
}, (a, b) -> null);
System.out.println(result);
```

执行结果为

```
[element-1, element-2, element-3, element-4, element-5, element-6]
```

这个示例显得有点鸡肋，一点不实用，不过在这里我们的主要目的是说明代码能达到什么样的效果，因此代码示例也不必取自实际的应用场景。

从上面两个示例可以看出第三个reduce比前面两个强大的多，它的功能已经完全覆盖前面两个的实现，如果我们不考虑代码的简洁性，甚至可以抛弃前面两个。

另外，还需要注意的是这个reduce的签名还包含第三个参数，一个BinaryOperator<U>类型的表达式。在常规情况下我们可以忽略这个参数，敷衍了事的随便指定一个表达式即可，目的是为了通过编译器的检查，因为在常规的stream中它并不会被执行到，然而， 虽然此表达式形同虚设，可是我们也不是把它设置为null，否者还是会报错。 在并行stream中，此表达式则会被执行到，在这里我们不进行讲解，因为我自己也没用过。

```java
numList.parallelStream()
```

可获得并行stream
