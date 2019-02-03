# java stream api reduce与collect的用法差异

java stream api中 reduce与collect 在功能上有差异也有重叠，但是重叠部分的实现也存在差异。

比入我们要为一个数值列表求和，求和的结果将从int升级成long，因为多个int值相加有可能会变成long。 用reduce可通过如下代码实现

```java
List<Integer> numList = Arrays.asList(1,Integer.MAX_VALUE);
long reduceResult = numList.stream().reduce(0L, (a, b) -> a + b, (a, b) -> 0L);
System.out.println(reduceResult);
```

reduce方法接受3个参数，第一个是基础值。第二个参数是一个表达式，作用是将结果累加，并将每一个的累加结果返回。第三个参数可以无视，它只在parallelStream中有效。

再来看看collect的实现方法

```java
        List<Integer> numList = Arrays.asList(1,Integer.MAX_VALUE);
        long collectResult = numList.stream().collect(
                () -> new AtomicLong(0),
                (a, b) -> a.addAndGet(b),
                (a, b) -> {
                })
                .get();
        System.out.println(collectResult);
```

collect也接受3个参数，第一个参数也是基础值，不过这个基础值并非和reduce方法中的第一个参数一样直接接受一个基础值，它接受的是一个表达式，此表达式返回一个基础值。第二个参数作用也和reduce的第二个参数相同，用于每一步的累加操作，不同的是collect中此表达式参数不用返回执行后的结果，因此它操作的对象必须是一个引用，否者操作的结果就丢失了。这也导致了collect的运算对象必须是一个引用，包括第一个参数返回的基础值也必须是一个引用，这便是collect和reduce这这个相同的功能中的不同点。这也是上面的代码不适用long而使用AtomicLong的原因，如果你不喜欢使用AtomicLong，那么也可以使用long类型的数组代替，代码如下，能达到和上面相同的效果

```java
        List<Integer> numList = Arrays.asList(1,Integer.MAX_VALUE);
        long collectResult = numList.stream().collect(
                () -> {
                    long[] array = new long[]{0};
                    return array;
                },
                (a, b) -> a[0] += b,
                (a, b) -> {})[0];
        System.out.println(collectResult);
```

因为数组是引用类型。

至于第三个参数， 和reduce的第三个参数相同，它在普通的stream不会被执行到，在parallelStream中才会被执行，所以通常我们可以随便些一个表达式填充下通过编译起的编译即可。