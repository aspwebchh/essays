Java NIO拥有单线程并发处理的能力，实现的机制是IO多路复用，换言之，Java NIO的核心API就是对传统IO多路复用的封装。 

Selector、Channel、Buffer是Java NIO编程的核心类库，它们分别对应传统IO多路复用中的select函数或者poll函数、文件描述符和文件内容读写函数。由此可见，IO多路复用是Java NIO的基础，只要了解IO多路复用机制，对于掌握Java NIO就不存在门槛， 所以在讲解Java NIO之前，我们先讲解IO多路复用。 

在服务器端，串行socket处理是最简单的方式，但这种方式服务器只能串行的读写socket，当读写网络连接数据出现阻塞时，程序也只能跟着阻塞，因此，服务器只有处理完当前的网络连接才能继续处理下一个， 显然这在生产环境下没有意义，服务器同时进来两个客户端连接，另一个就被搁置了。 

一种解决方案是使用多线程技术，使用多个线程并发处理多个socket连接。 这种方案使一个服务器可以同时为多个客户端服务， 然而这种方案的问题是性能损耗严重。首先，使用线程对于操作系统而言是重量级操作，线程通常也被称为轻量级进程，调度线程是内核的操作，开销很大。 其次，每个线程都有自己的执行空空间，在Java中，一个线程就会占用1M的内存，同时存在的线程数量一多， 内存势必消耗严重。

IO多路复用使得即使不使用多线程服务器也能并发处理多个socket连接。 在传统的单线程模式中，服务器读取socket中的数据，当数据未准备就绪时，如数据还未传输至服务器，数据读取操作将陷入阻塞，程序就什么也不能干，只能陷入空等。 IO多路复用得以实现，是操作系统提供的能力， 从最开始的select到后来的poll，之后再是epoll，就是IO多路复用的核心。 以select为例，它拥有在一个线程中监控多个socket连接的能力，这种能力是系统内核赋予它的。select通常处于一个无限循环当中被不停的调用， 每次调用，它都会不停的检查它监控的所有socket连接中是否有连接处于可读可写等就绪状态，  当存在时便标记这个连接的状态使程序可以得知，并返回，接下来程序可以通过标记的状态找到这个连接进行读写操作。如果没有连接准备就绪，select调用将陷入阻塞，此时的阻塞健康的，因为没有连接准备就绪，也就是没有客户端需要得到服务，陷入等待在情理之中。 __这个流程大概的模样就是select函数调用不断检查当前服务区所有的连接，一旦发现有连接处于就绪状态，就通知程序进行相应处理，而不是在一个连接上吊死。这种模式使得程序中不存在无意义的阻塞，CPU得到充分的利用，资源不被浪费，属于玩命压榨服务器性能，有活干的时候不能让它偷懒， 程序性能自然就上去了。__

Java  NIO就是基于这种模式实现的，下面我们讲解一个利用NIO实现的简单的并发Web服务器。

```java
private void listen() throws IOException {
    Selector selector = Selector.open();
    ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
    serverSocketChannel.bind(new InetSocketAddress(8000));
    serverSocketChannel.configureBlocking(false);
    serverSocketChannel.register(selector,  SelectionKey.OP_ACCEPT );

    while (true) {
        selector.select();
        Iterator<SelectionKey> keyIterator = selector.selectedKeys().iterator();
        while (keyIterator.hasNext()) {
            SelectionKey key = keyIterator.next();
            keyIterator.remove();

            if(key.isAcceptable()) {
                onAccept(selector,key);
            }

            if( key.isReadable()) {
                onRead(selector,key);
            }

            if(key.isValid() && key.isWritable()) {
                onWrite(selector,key);
            }
        }
    }
}
```

此方法是我们实现的服务器的核心，其中 Selector的作用就是用来检测所有它所监控的Socket连接的状态，一旦发现有连接准备就绪就通知程序进行处理。

ServerSocketChannel表示当前的服务器

```java
serverSocketChannel.bind(new InetSocketAddress(8000));
serverSocketChannel.configureBlocking(false);
```

它监听了8000端口，并被设置为非阻塞，在IO多路复用中，它必须被设置为非阻塞， 否则selector再检查所监控的Socket连接时，当某个连接未准备就绪，就会被阻塞住， IO复用亦无法实现。 

```java
serverSocketChannel.register(selector,  SelectionKey.OP_ACCEPT );
```

将serverSocketChannel设为被selector监控的对象， SelectionKey.OP\_ACCEPT 表示当有新的连接进入服务器时，selector将做出响应。

```java
 while (true) {
    selector.select();
    Iterator<SelectionKey> keyIterator = selector.selectedKeys().iterator();
    while (keyIterator.hasNext()) {
        SelectionKey key = keyIterator.next();
        keyIterator.remove();
        
        if(key.isAcceptable()) {
            onAccept(selector,key);
        }
        if( key.isReadable()) {
            onRead(selector,key);
        }
        if(key.isValid() && key.isWritable()) {
            onWrite(selector,key);
        }
    }
}
```

selector.select() 在无限循环中被调用，它会不停的检测它所监控的连接是否有相应的事件发生，如果没有则阻塞，如果有则返回并执行之后的代码。 

程序刚开始时，我们向selector添加了一个监控对象和一个OP\_ACCEPT事件，当有新连接进入时，事件被触发，selector.select()检查到存在此事件并响应，代码继续往下执行，key.isAcceptable()条件成立，onAccept方法被执行。

```java
private void onAccept(Selector selector, SelectionKey key) throws IOException {
    SocketChannel clientChannel = ((ServerSocketChannel) key.channel()).accept();
    clientChannel.configureBlocking(false);
    clientChannel.register(selector, SelectionKey.OP_READ );
}
```

onAccept方法会获得一个新的Socket连接，并将连接设为selector的监控对象， 同时注册OP\_READ事件。OP\_READ表示当selector检测到此连接数据准备就绪可以读取时，从 selector.select()调用中返回，去执行响应的读取操作。

```java
if( key.isReadable()) {
    onRead(selector,key);
}
```

```java
private  void  onRead(Selector selector, SelectionKey key) throws IOException {
    SocketChannel clientChannel = (SocketChannel) key.channel();
    ByteBuffer buf = ByteBuffer.allocate(1024);
    long bytesRead = -1;
    try{
        bytesRead = clientChannel.read(buf);
    }catch (IOException ioe) {}

    if (bytesRead == -1) {
        clientChannel.close();
    } else if (bytesRead > 0) {
        buf.flip();
        while (buf.hasRemaining()) {
            System.out.print((char) buf.get());
        }
        key.interestOps(SelectionKey.OP_READ | SelectionKey.OP_WRITE);
    }
}
```

onRead方法读取客户端发送过来的数据并打印，同时像selector增加一个写操作事件

```java
  key.interestOps(SelectionKey.OP_READ | SelectionKey.OP_WRITE);
```

selector.select()会检测到socket连接可以写入数据，onWrite方法被执行

```java
if(key.isValid() && key.isWritable()) {
    onWrite(selector,key);
}
```

```java
private void  onWrite(Selector selector, SelectionKey key) throws  IOException{
    String content = getHtmlContent();
    int contentLength  = content.getBytes().length;
    String response = "HTTP/1.1 200 OK\n" +
            "Content-Type:text/html;charset=UTF-8\n" +
            "Content-Length:"+ contentLength +"\n" +
            "\n" +
            content;
    ByteBuffer buf = ByteBuffer.allocate(response.getBytes().length);
    buf.put(response.getBytes());
    buf.flip();
    SocketChannel clientChannel = (SocketChannel) key.channel();
    clientChannel.write(buf);
    key.interestOps(SelectionKey.OP_READ);
}

private String getHtmlContent() {
    return "<html>\n" +
            "<head>\n" +
            "<title>welcome</title>\n" +
            "</head>\n" +
            "<body>\n" +
            "hello world\n" +
            "</body>\n" +
            "</html>";
}
```

onWrite方法会向客户端发送一个完整的http报文。

完整代码如下

```java
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;


public class WebServer {
    public WebServer(){
        try {
            listen();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private void onAccept(Selector selector, SelectionKey key) throws IOException {
        SocketChannel clientChannel = ((ServerSocketChannel) key.channel()).accept();
        clientChannel.configureBlocking(false);
        clientChannel.register(selector, SelectionKey.OP_READ );
    }

    private  void  onRead(Selector selector, SelectionKey key) throws IOException {
        SocketChannel clientChannel = (SocketChannel) key.channel();
        ByteBuffer buf = ByteBuffer.allocate(1024);

        long bytesRead = -1;
        try{
            bytesRead = clientChannel.read(buf);
        }catch (IOException ioe) {}

        if (bytesRead == -1) {
            clientChannel.close();
        } else if (bytesRead > 0) {
            buf.flip();
            while (buf.hasRemaining()) {
                System.out.print((char) buf.get());
            }
            key.interestOps(SelectionKey.OP_READ | SelectionKey.OP_WRITE);
        }
    }

    private void  onWrite(Selector selector, SelectionKey key) throws  IOException{
        String content = getHtmlContent();
        int contentLength  = content.getBytes().length;
        String response = "HTTP/1.1 200 OK\n" +
                "Content-Type:text/html;charset=UTF-8\n" +
                "Content-Length:"+ contentLength +"\n" +
                "\n" +
                content;
        ByteBuffer buf = ByteBuffer.allocate(response.getBytes().length);
        buf.put(response.getBytes());
        buf.flip();
        SocketChannel clientChannel = (SocketChannel) key.channel();
        clientChannel.write(buf);
        key.interestOps(SelectionKey.OP_READ);
    }

    private String getHtmlContent() {
        return "<html>\n" +
                "<head>\n" +
                "<title>welcome</title>\n" +
                "</head>\n" +
                "<body>\n" +
                "hello world\n" +
                "</body>\n" +
                "</html>";
    }

    private void listen() throws IOException {
        Selector selector = Selector.open();
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        serverSocketChannel.bind(new InetSocketAddress(8000));
        serverSocketChannel.configureBlocking(false);
        serverSocketChannel.register(selector,  SelectionKey.OP_ACCEPT );

        while (true) {
            selector.select();
            Iterator<SelectionKey> keyIterator = selector.selectedKeys().iterator();
            while (keyIterator.hasNext()) {
                SelectionKey key = keyIterator.next();
                keyIterator.remove();

                if(key.isAcceptable()) {
                    onAccept(selector,key);
                }
                if( key.isReadable()) {
                    onRead(selector,key);
                }
                if(key.isValid() && key.isWritable()) {
                    onWrite(selector,key);
                }
            }
        }
    }
}
```

```java
public class Main {
    public static void main(String[] args) {
        new WebServer();
    }
}
```

运行此代码，在本机浏览器地址栏键入 [http://localhost:8000/](http://localhost:8000/)  会展示服务器输出的html。

