mysql的limit操作无法利用索引的有序扫描能力，使用不当会出现性能问题。

limit接受两个参数，第一个参数是偏移的位置（offset），第二个参数是返回的行数（length）。 当查询的结果集数据量过大， 那么当limit的offset参数过大时，查询就会变慢。

```sql
select * from user where gender = '男'  order by id desc limit 9000000, 10;
```

以此SQL为例。假如user表中有2000W条记录，gender字段为男的记录有1200W条，那么当limit的offset值设为900W时，SQL语句将被执行相当长的时间才能返回结果， 这在应用系统中是无法接受的， 但是因为分页需要，我们不得不执行这样的操作。

与此同时，offset为较小的值时，却能很快得出结果。 我们来解释一下其中原因

假设表的gender字段上有一个非聚集索引，那么执行的过程大致如下

1. 通过 gender='男' 这个筛选， 在索引上找到符合要求的1200W条记录的主键ID值
2. 通过这些ID找到对应的数据，这个操作一般都是利用数据库的聚集索引查找（回表）能力完成
3. 检查上一步所找到数据的offset是否符合limit中offset参数的要求， 符合则返回，不符合则丢弃

因为limit中offset值是900W， 所以找到符合要求的命中率非常低， 前900W次 回表+匹配 操作都在做无用功， 这个查询变得很慢也是必然的。

解决这个问题有一个思路，如果能将limit offset匹配的操作提前，也就是先拿到符合limit要求的ID， 再进行回表寻找数据，那么效率的提升是必然的。

实现这个思路我们可以利用非聚集索引的覆盖能力，由于索引的特性，我们可以直接查询索引就能得到表记录的ID标识，为这些ID执行limit操作的到符合offset和length参数要求的ID集，然后再执行回表。因为这些ID就是符合要求记录的ID， 因此回表的操作一次也不回被浪费，查询速度自然就上来了。

通常， 以这个思路为背景的实现方案有两种

## <a name="k9v0wk"></a>一

先通过索引得到ID

```sql
select id from user where gender = '男'  order by id desc limit 9000000, 10;
```

这个查询相对较快，因为查询只设计到索引

得到ID集后，在执行一个查询获得真正的结果

```sql
select * from user where id in (id1,id2,id3…)
```

这种做法的好处是简单明了，坏处是在程序代码中要执行两步查询

## <a name="pysaga"></a>二

利用sql表联接语法，一步得到结果，代价是SQL语句变的复杂了

```sql
select * from user as a INNER JOIN (
SELECT id
FROM user
WHERE gender = '男'
ORDER BY id DESC
LIMIT  9000000, 10
) as b on a.id = b.id;
```


