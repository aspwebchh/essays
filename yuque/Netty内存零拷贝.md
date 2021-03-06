Netty内存零拷贝大致分为三部分

## <a name="y8ozzw"></a>FileRegion

我们知道java nio库中有一个FileChannel类，提供快速在文件之间传输数据的功能。

传统文件之间数据拷贝要经过四个步骤

1. 将源文件数据从磁盘拷贝到操作系统内核
2. 将数据从内核拷贝至用户空间缓冲区
3. 将缓冲区数据从用户空间拷贝至内核
4. 将数据从内核拷贝至目标文件

代码如下

```java
public static void copyFile(String srcFile, String destFile) throws Exception {
    byte[] temp = new byte[1024];
    FileInputStream in = new FileInputStream(srcFile);
    FileOutputStream out = new FileOutputStream(destFile);
    int length;
    while ((length = in.read(temp)) != -1) {
        out.write(temp, 0, length);
    }
    in.close();
    out.close();
}
```

使用FileChannal可以省略中间的两个步骤，将源文件数据拷贝至内核接着直接拷贝至磁盘上的目标文件，从而减少不必要的拷贝操作

```java
public static void copyFileWithFileChannel(String srcFileName, String destFileName) throws Exception {
    RandomAccessFile srcFile = new RandomAccessFile(srcFileName, "r");
    FileChannel srcFileChannel = srcFile.getChannel();

    RandomAccessFile destFile = new RandomAccessFile(destFileName, "rw");
    FileChannel destFileChannel = destFile.getChannel();

    long position = 0;
    long count = srcFileChannel.size();

    srcFileChannel.transferTo(position, count, destFileChannel);
}
```

FileRegion就是借用了FileChannel的能力

## <a name="gqbiuy"></a>Direct Buffers

要把堆内存空间的数据通过网路发送出去，必须要经过直接内存，Direct ByteBuf 能在直接内存中分配空间，在网络传输时避免了来回在堆内存和直接内存之间拷贝数据的开销，从而提升性能。

## <a name="pn5hpp"></a>CompositeByteBuf 

如果我们需要将传统的两个ByteBuffer合并，则需要创建一个新的ByteBuffer，然后将两个需要合并的ByteBuffer中的数据拷贝至新的ByteBuffer。如果我们需要将一个传统的ByteBuffer分割成两个新的ByteBuffer，则需要创建两个新的ByteBuffer，然后将源ByteBuffer中的数据拷贝至目标ByteBuffer。这中拷贝存在开销。

Composite Buffers的运行原理是对源ByteBuffer做一层封装，可以把它看成是源ByteBuffer的一层代理，所有对Composite Buffers的操作还是会被代理到源ByteBuffer上，他并不改变源数据的存储， 改变的只是元数据的外观， 可以把这种实现方式看成是代理模式或者装饰模式。

参考连接：
[http://blog.onlycatch.com/post/Netty%E4%B8%AD%E7%9A%84%E9%9B%B6%E6%8B%B7%E8%B4%9D](http://blog.onlycatch.com/post/Netty%E4%B8%AD%E7%9A%84%E9%9B%B6%E6%8B%B7%E8%B4%9D)
[https://segmentfault.com/a/1190000007560884](https://segmentfault.com/a/1190000007560884)

