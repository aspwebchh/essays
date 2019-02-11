当我们使用java io系统进行外部数据读取，如网络、文件等内容读取很容易被复杂的类库搞的头昏脑胀，岁虽然要理解java的io系统以及复杂的类层次结构是一项艰难的任务，所以对于通过类库满足我们的需求通常是千遍一律的，比如如何读取到互联网上一张网页的内容、如何读取磁盘上一个文件的内容，这种需求的职责很单一、功能很明确，解决方案网上一搜一大把，而且大多数需要用到java io系统的需求也就是这些需求，因此即使我们不能完整的理解java io系统的细节，也不妨碍我们使用它，我们只需要从互联网上把代码复制到自己的程序中调用就可以了。

然而只知其然不知其所以然总归不是一件舒服的事情，而要理解整个io系统的细节又如此艰难，因此我们可以做一个折中，去理解那些覆盖面广且常用但又不那么艰深的内容，这样是最大化投入产出比一种方案。

接下来我们谈谈在大多数情况下使用java io系统读取内容的一种规律，我们来看一个代码片段，这个代码片段应该能代表相当一部分通过java读取外部内容的情况了

```java
URL url = new URL("https://www.jd.com/");
URLConnection urlConnection = url.openConnection();
InputStream inputStream = urlConnection.getInputStream();
InputStreamReader inputStreamReader = new InputStreamReader(inputStream,"utf8");
BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
StringBuilder content = new StringBuilder();
String line = bufferedReader.readLine();
while(line != null){
  content.append(line);
  content.append("\n");
  line = bufferedReader.readLine();
}
System.out.println(content.toString());
```

我们抓取互联网上一张网内的内容到程序中并转换成字符串输出， 可以将整个过程分解成一下步骤

####1、获得一个表示网页内容的InputStream

```java
URL url = new URL("https://www.jd.com/");
URLConnection urlConnection = url.openConnection();
InputStream inputStream = urlConnection.getInputStream();
```

InputStream非常常见，我们在很多场景下能见到他，很多系统类库访问外部资源返回的都是InputStream或者它的派生类，比如说文件内容读取、网路内容读取，甚至System.in等都会用到InputStream

```java
 FileInputStream fileInputStream = new FileInputStream("C:\\Users\\Desktop\\新建文本文档.txt");
```

可以使用FileInputStream读取磁盘文件，FileInputStream 是 InputStream 的一个派生类。

因此对于使用java io读取在许多情况下就是使用InputStream

####2、将InputStream转换成InputStreamReader

从数据类型的角度讲，java io系统类库有两种实现，一种是面向字节的InputStream/OutputStream，另一种是面向字符的Reader和Writer，字节相对与字符更加贴近系统，而字符相对于字节更加接近于用户，因为当我们需要输出用户可见的内容时更适合使用Reader/Writer系列的类库。当然我们也可以自己处理InputStream的字节内容并转换成字符使用，可这明显不是明智的做法，因为Reader/Writer已经帮我们完成任务。

Java提供了InputStreamReader类型来将InputStream转换成Reader类型

```java
InputStreamReader inputStreamReader = new InputStreamReader(inputStream,"utf8");
```

InputStreamReader还有一个绝无仅有的强大功能，它可以指定读取内容的编码，这时其它Reader系列的类库不具备的，比如FileReader。

使用InputStreamReader可以将InputStream的内容读取成字符串，然而它却并不高效。我们每调用一次InputStreamReader的read方法读取一次内容，InputStreamReader就需要根据传入的参数从磁盘上的文件中获取相应的内容，那么read的相应调用次数就等于访问磁盘文件的次数，这是低效的行为。

####3、使用BufferedReader引入缓冲机制

BufferedReader是具备缓冲功能的一种Reader，它会预先把一部分内容从磁盘加载至内容，然而当我们读取内容时，BufferedReader会从已经存在内存中缓冲数据中读取内容，而不是直接访问磁盘，当当前部分内容读取完毕时，BufferedReader会从磁盘中加载新的内容至内存缓冲区，如此便能减少磁盘的访问次数提升运行效率

```java
 BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
```

BufferedReader一装饰者的身份对Reader增加缓冲区功能

####4、读取内容并输出

```java
StringBuilder content = new StringBuilder();
String line = bufferedReader.readLine();
while(line != null){
  content.append(line);
  content.append("\n");
  line = bufferedReader.readLine();
}
System.out.println(content.toString());
```
这一步非常简单，它从bufferedReader中读取字符串行并追加到一个StringBuilder中，最后输出到控制台。

总的来说的话，如果碰到要读取外部设备内容的需求，那么我们只要能获得代表内容的InputStream，之后的处理大致上是相同而且简单的，所以通过java io处理输入内容，大致过成不外乎

1. 获得一个inputStream
1. 将inputStream转换成InputStreamReader
1. 使用BufferedReader装饰 InputStreamReader 来读取具体内容

