RandomAccessFile同时具备读写文件的能力
 
# <a name="c9sbct"></a>读取文件内容
 
对于读取整个文件内容的需求，它提供将文件内容读取到字节数组的方法
 
```java
    private static String readString( Stringpath ) {
        try{
            File file = new File(path);
            RandomAccessFile raf = newRandomAccessFile(file,"rw");
            byte[] bytes = newbyte[(int)file.length()];
            raf.read(bytes);
            raf.close();
            String str = new String(bytes);
            return str;
        }catch (IOException e) {
            return "";
        }
    }
```
 
```java
 
        final String path ="C:\\Users\\admin\\Desktop\\text.txt";
        String content = readString(path);
        System.out.println( content );
```

注意：如果文件编码不是utf-8，则会读到乱码
 
# <a name="9z13kp"></a>写入文件内容
 
将内容通过RandomAccessFile写入文件实现起来比较麻烦， RandomAccessFile提供的写文件内容方法支持在已有文件内容的某个点插入新内容，而写文件的大多数需求是用新的内容覆盖掉旧的内容，RandomAccessFile却没有提供清空旧文件内容的方法。 所以要实现此功能我们必须使用FileChannel， FileChannel的truncate方法可以清空文件内容。 
 
```java
    private static void writeString( Stringpath, String content) {
        try{
            byte[] bytes = content.getBytes();
            File file = new File(path);
            RandomAccessFile raf = newRandomAccessFile(file,"rw");
            FileChannel fileChannel =raf.getChannel();
            fileChannel.truncate(0);
            ByteBuffer byteBuffer =ByteBuffer.wrap(bytes);
            fileChannel.write(byteBuffer);
            fileChannel.close();
            raf.close();
        }catch (IOException e) {
        }
    }
```
 
```java
        final String path ="C:\\Users\\admin\\Desktop\\text.txt";
        writeString(path,"content");
```
 
 以上代码的实现步骤是
 
1. 从RandomAccessFile获得FileChannel
2. 调用FileChannel的truncate方法清空文件，truncate接口一个数值参数， 此参数是一个位置值， 表示在文件内容中，此位置后面的内容将被删除，因此， 传递0就表示位置0后面的内容被删除，也就是整个文件中的内容被删除
3. 利用ByteBuffer往FileChannel中写入内容
 
# <a name="g23vqx"></a>使用标准的方式读写文件
 
使用RandomAccessFile读写文件显得非常繁琐。 事实，jdk中已经包含了专门实现读写文件功能的类库，如 FileReader 和 FileWriter
 
 
## <a name="0cdvle"></a>FileReader读取文件内容
 
```java
    private static StringreadStringByReader(String path) {
        try {
            File file = new File(path);
            FileReader fileReader = newFileReader(file);
            char[] chars = newchar[(int)file.length()];
            fileReader.read(chars);
            fileReader.close();
            String str = new String(chars);
            return str;
        } catch (IOException e) {
            return "";
        }
    }
 
```
 
## <a name="t5gpwu"></a>FileWriter写入文件内容
 
```java
    private static voidwriteStringByWriter(String path , String content ) {
        try {
            File file = new File(path);
            FileWriter fileWriter = newFileWriter(file);
            fileWriter.write(content);
            fileWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    } 
```
 
看， 使用专门的读写API实现读写文件的功能是不是方便很多， 不但使用方便， 而且可读性强。
 
 

