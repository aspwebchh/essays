使用java读取磁盘文件内容容易出现乱码， 问题是由于java使用的编码和被读取文件的编码不一致导致的。 
 
假设有一个test.txt的文本文件，文件内容为：“测试java读取中文字符串乱码问题”， 其中包含中文，文件的编码格式为GBK。 假如我们使用的java平台默认编码为UTF-8
 
可使用 

```java
System.out.println(Charset.defaultCharset());
```

打印查看 
 
那么当我们使用不指定编码的方式读取文件内容时，得到的结果将会是乱码

```java
String path = "C:\\Users\\宏鸿\\Desktop\\test.txt";
FileReader fileReader = new FileReader(path);
char[] chars = new char[1024];
String content = "";
while (fileReader.read(chars) > 0 ) {
    content += new String( chars );
}
System.out.println(content);
```

结果



![1.png | center | 734x89](https://cdn.nlark.com/yuque/0/2018/png/127662/1533443528321-3ab775f2-20a7-400c-bb72-0f6202bb9dd7.png "")


然而， Java IO 系统Reader系列中的FileReader是没有办法指定编码的，而FileReader的父类InputStreamReader可以指定编码，所以我们可以使用它来解决乱码问题

```java
String path = "C:\\Users\\宏鸿\\Desktop\\test.txt";
FileInputStream fis = new FileInputStream(path);
InputStreamReader inputStreamReader = new InputStreamReader(fis, "GBK");
char[] chars = new char[1024];
String content = "";
while (inputStreamReader.read(chars) > 0 ) {
    content += new String( chars );
}
System.out.println(content);
```

结果



![2.png | center | 421x117](https://cdn.nlark.com/yuque/0/2018/png/127662/1533443569402-bfa0d1e2-86de-4ad1-a31d-6cfe14e30a6a.png "")


使用InputStreamReader代替FileReader，并在构造函数中指定以GBK编码读取FileInputStream中的内容，  便能打印正确的结果
 
当然，除了此解决方案以外， 我们也可以使用Java IO系统中的InputStream系列类解决问题。 InputStream和Reader是Java IO系统中用来读取内容的两个分支，InputStream面向的是字节流，Reader面向的是字符， 字符存在编码问题，而字节流却不存在编码问题， 不过在最终将字节流转换成字符显示时还是涉及到编码问题的。 下面给出InputStream读取文件内容的解决方案。

```java
String path = "C:\\Users\\宏鸿\\Desktop\\test.txt";
FileInputStream fileInputStream = new FileInputStream(path);
byte[] bytes = new byte[1024];
String content = "";
while (fileInputStream.read(bytes) > 0) {
    content += new String(bytes,"GBK");
}
System.out.println(content);
```

我们看到，从InputStream中读取字节时不涉及编码转换，但是要将字节转换成字符串时还是需要指定编码。
 
所以，彻底避免乱码的办法是我们一定要确定被读取文件的编码格式和java平台的编码格式一致，比如说我们可以手动修改文件的编码格式，用notepad和vscode可以很轻松做到， 保证文件和java平台编码格式一致。 如果我们无法控制被读取文件的编码格式，那么我们可以通过程序动态判断文件的编码格式

```java
public static String codeString(String fileName) throws IOException{
    File file = new File(fileName);
    if(file==null || !file.exists()){
        System.out.println("文件不存在..."+file.getAbsolutePath());
        return null;
    }

    BufferedInputStream bin = new BufferedInputStream( new FileInputStream(file));
    int p = (bin.read() << 8) + bin.read();
    String code = null;
    //其中的 0xefbb、0xfffe、0xfeff、0x5c75这些都是这个文件的前面两个字节的16进制数
    switch (p) {
        case 0xefbb:
            code = "UTF-8";
            break;
        case 0xfffe:
            code = "Unicode";
            break;
        case 0xfeff:
            code = "UTF-16BE";
            break;
        case 0x5c75:
            code = "ANSI|ASCII" ;
            break ;
        default:
            code = "GBK";
    }

    return code;
}
```

使用此函数（来自网络）可以获得文件编码格式
 
那么我们可以不关注编码格式是否一致也能正确读取文件内容了

```java
String path = "C:\\Users\\宏鸿\\Desktop\\test.txt";
FileInputStream fileInputStream = new FileInputStream(path);
byte[] bytes = new byte[1024];
String content = "";
while (fileInputStream.read(bytes) > 0) {
    content += new String(bytes,codeString(path));
}
System.out.println(content);
```


