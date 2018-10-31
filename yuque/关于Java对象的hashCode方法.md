# 关于Java对象的hashCode方法

hashCode 方法是所有Java对象都拥有的一个方法，位于继承树顶端的Object对象之中。
hashCode方法返回一个Integer类型的哈希值，其作用是标识对象， 比如在HashTable、HashSet之类的数据结构中就是用它来标识和定位元素的。br ?br Java规定，任何相同的对象也是就用equals方法比较返回true的两个对象调用hashCode返回的值必须相同， 但是并不规定不同的对象返回的hashCode值一定不同，换言之即使不同的两个对象调用hashCode返回的值也是可以相同的。这不难理解， hashCode方法返回的值是一个Integer类型，这个值是有范围的， 假如某个Java程序中对象的数量超出这个范围，那么总会存在两个对象哈希到同一个点上，因此hashCode也就相同的。 虽说出现这种情况是小概率事件，可是我们还应该避免在程序中假定对象的hashCode总是不同的，对于出现相同值的情况应该进行特殊处理，否则程序运行还是有可能出现意料之外的结果。br ?br 与此同时，当我们重写对象的equals方法时也应该一并重写hashCode方法，我们在前面说过，两个对象比较时equals方法返回为true，那么hashCode返回的值也应该相同。举个例子，Student对象表示学生，那么两个学生对象的名称字段、性别字段、学生证号码字段相同时，从逻辑上讲这两个对象应该算相同的，我们会这样重写Student的equals方法br ?
```java
    public boolean equals(Student obj) {
        return this.name.equals(obj.name) &&
                this.gender.equals(obj.gender) &&
                studendId.equals(obj.studendId);

    }
```

从逻辑上我们重新定义对象的相等性，可是在物理上即使所有信息相同的Student对象还是不同的，他们的hashCode还是从Object上继承下来的native方法，返回的值还是不同的，这就违背了Java设计hashCode方法的初衷，当equals方法返回为true的情况下hashCode方法也必须返回相同的值这一点，因此为了使程序能安全正常的运行，我们也应该重新设计hashCode方法，使其符合equals方法的逻辑， 否则当你使用Java集合相关的功能时会出现预期之外的错误或者性能低下等情况。
