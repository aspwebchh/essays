# JMX的用处及用法

JMX最常见的场景是监控Java程序的基本信息和运行情况，任何Java程序都可以开启JMX，然后使用JConsole或Visual VM进行预览。下图是使用Jconsle通过JMX查看Java程序的运行信息

![1.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863028681-a3a961b6-1b7f-49c4-b3d7-1e4bdc0da36f.png#align=left&display=inline&height=628&linkTarget=_blank&name=1.png&originHeight=750&originWidth=891&size=48391&width=746)

为Java程序开启JMX很简单，只要在运行Java程序的命令后面指定如下命令即可<br />?
```shell
-Djava.rmi.server.hostname=127.0.0.1
-Dcom.sun.management.jmxremote.port=1000
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
```
?<br />我们从Jconsole的视图标签中见到，JConsole通过JMX展示的信息都是Java程序的通用信息，如内存情况、线程情况、类加载情况等，换言之，只要是Java程序就都具备这些信息。这些信息为我们优化程序性能、排查BUG非常有用，而JMX就是获取这些信息的基础，因此它是一种非常有用的技术。<br />?<br />然而JMX的强大远不止此，它出了能提供一些通用的信息以外，还能通过特定的编程接口提供一些针对具体程序的专有信息并在JConsole等JMX客户端工具中展示，具体点说就是程序员可以把需要展示的信息放在一种叫做MBean的Java对象内，然后JConsole之类的客户端工具可以连接到JMX服务，识别MBean并在图形界面中显示。从纯抽象的角度触发，这其实有点像浏览器发送一个请求给http服务器，然后http服务器执行浏览器的请求并返回相应的数据，从某种角度来说JConsole和JMX也是以这种方式工作的，只是它们使用的协议不是http，交换数据协议格式不是http数据包，但是他们的确是以客户端/服务器这种模式工作的，而且完成的事情也差不多。<br />?<br />那么既然有了http，JMX又有何存在意义呢。 事实上，JMX能完成的任务通过http的确都能完成，只不过某些情况下用JMX来做会更加方便。<br />?<br />比如说你需要知道服务器上个运行中程序的相关信息， 如执行了多少次数据库操作、任务队列中有多少个任务在等待处理<br />?<br />最常用的解决方案，我们会在程序中启动一个http服务，当接收到来自客户端的请求这些信息的请求时，我们的http处理程序会获得这些信息，并转换成特定格式的数据如JSON返回给客户端，客户端会以某种方式展现这些信息。<br />?<br />如以JMX作为解决方案，核心流程也是如此，但在数据的交换方式上会略有不同。<br />?<br />下面我们展示JMX是如何完成此任务的。<br />?<br />一、定义一个展示所需信息的MBean接口

```java
public interface ServerInfoMBean {
    int getExecutedSqlCmdCount();
}
```

在使用 Standard Mbean 作为数据传输对象的情况下这个接口的定义是必须的， 并且接口名称必须以“MBean”这个单词结尾。<br />?<br />二、实现具体的MBean

```java
public class ServerInfo implements ServerInfoMBean {
    public int getExecutedSqlCmdCount() {
        return Dbutil.getExecutedSqlCmdCount();
    }
}
```

三、在程序的某个地方启动JMX服务并注册ServerInfoMBean

```java
    public static void main(String[] args)  throws JMException, Exception{
        MBeanServer server = ManagementFactory.getPlatformMBeanServer();
        ObjectName name = new ObjectName("serverInfoMBean:name=serverInfo");
        server.registerMBean(new ServerInfo(), name);
    }
```

四、运行程序，并通过JConsole查看<br />?<br />如果程序运行在本地，Jconsole会自动检测到程序的进程，鼠标双击进入即可

![2.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863134753-067ac892-00e1-4bba-8311-251c7807510b.png#align=left&display=inline&height=621&linkTarget=_blank&name=2.png&originHeight=750&originWidth=900&size=61059&width=746)

在JConsole下面即会展示我们定义的MBean中的内容

![3.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863150584-938a15a3-662a-49a2-9d47-b1a4af607e10.png#align=left&display=inline&height=628&linkTarget=_blank&name=3.png&originHeight=750&originWidth=891&size=22039&width=746)

那么假如Java程序并非运行在本地而是运行在远端服务器上我们应该如何通过客户端去连接呢， 很简单，只要使用JDK提供的JMX类库监听端口提供服务即可

```java
                  
public class Main {
    public static void main(String[] args)  throws JMException, Exception{
        MBeanServer server = ManagementFactory.getPlatformMBeanServer();
        ObjectName name = new ObjectName("serverInfoMBean:name=serverInfo");
        server.registerMBean(new ServerInfo(), name);


        LocateRegistry.createRegistry(8081);
        JMXServiceURL url = new JMXServiceURL
                ("service:jmx:rmi:///jndi/rmi://localhost:8081/jmxrmi");
        JMXConnectorServer jcs = JMXConnectorServerFactory.newJMXConnectorServer(url, null, server);
        jcs.start();
    }
}
```

或者在启动Java程序指定命令行参数也<br />?
```shell
-Djava.rmi.server.hostname=127.0.0.1
-Dcom.sun.management.jmxremote.port=10086
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
```
?<br />然后使用JConsole的连接远端进程功能即可

![4.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863217822-0080129f-38b2-4e54-8e54-9824e7532b61.png#align=left&display=inline&height=621&linkTarget=_blank&name=4.png&originHeight=750&originWidth=900&size=42655&width=746)

其余的操作和本地无差。<br />?<br />这相对于提供一个http服务来完成任务是不是要简单了不少，http是一个更加抽象、应用面更广泛、功能更强大的服务，因此所作的工作也要更多一些。JMX则是一个更加具体、应用面不那么广、功能也没有http强大的服务，不过呢它胜在解决特定问题更加轻松方便，上面的示例已经很好的说明了。<br />?<br />此外，JMX和Jconsole并不仅仅只能展示数据，它还能执行Java方法。以上面的示例为基础我们再进行一系列改进。

一、扩展ServerInfoMBean接口和实现的类

```java
public interface ServerInfoMBean {
    int getExecutedSqlCmdCount();
    void printString(String fromJConsole);
}

public class ServerInfo implements ServerInfoMBean {
    public int getExecutedSqlCmdCount() {
        return 100;
    }

    public void printString(String fromJConsole) {
        System.out.println(fromJConsole);
    }
}
```

二、运行程序并使用JConsole连接

![5.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863265109-86d81634-0f77-4fbf-8384-d52ab34c7e8d.png#align=left&display=inline&height=621&linkTarget=_blank&name=5.png&originHeight=750&originWidth=900&size=52031&width=746)

mbean页签中出现了我们新添加的方法<br />?<br />三、点击printString按钮调用方法

![6.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863277718-99b7248c-b909-41c7-8860-228064b8102f.png#align=left&display=inline&height=621&linkTarget=_blank&name=6.png&originHeight=750&originWidth=900&size=39705&width=746)

方法被调用，同时控制台也打印了通过Jconsole传递的参数

![7.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863288945-2ad996ab-6201-4730-ba22-eb7430dd4a0f.png#align=left&display=inline&height=188&linkTarget=_blank&name=7.png&originHeight=188&originWidth=686&size=7860&width=686)

这里只是讲解了JMX的用处和最基础的使用方法，显然JMX真正提供的功能远不及此，比如它可以不用JConsole而是客户端编程的方式访问等等， 有兴趣的同学可以深入研究。<br />?<br />总而言之， 我觉得JMX是一种小巧精悍的工具，在不需要大张旗鼓的通过http或者其他server\client方式提供服务时，就是他发挥用处的时机了。

