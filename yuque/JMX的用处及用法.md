# JMX���ô����÷�

JMX����ĳ����Ǽ��Java����Ļ�����Ϣ������������κ�Java���򶼿��Կ���JMX��Ȼ��ʹ��JConsole��Visual VM����Ԥ������ͼ��ʹ��Jconsleͨ��JMX�鿴Java�����������Ϣ

![1.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863028681-a3a961b6-1b7f-49c4-b3d7-1e4bdc0da36f.png#align=left&display=inline&height=628&linkTarget=_blank&name=1.png&originHeight=750&originWidth=891&size=48391&width=746)

ΪJava������JMX�ܼ򵥣�ֻҪ������Java������������ָ�����������<br />?
```shell
-Djava.rmi.server.hostname=127.0.0.1
-Dcom.sun.management.jmxremote.port=1000
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
```
?<br />���Ǵ�Jconsole����ͼ��ǩ�м�����JConsoleͨ��JMXչʾ����Ϣ����Java�����ͨ����Ϣ�����ڴ�������߳���������������ȣ�����֮��ֻҪ��Java����Ͷ��߱���Щ��Ϣ����Щ��ϢΪ�����Ż��������ܡ��Ų�BUG�ǳ����ã���JMX���ǻ�ȡ��Щ��Ϣ�Ļ������������һ�ַǳ����õļ�����<br />?<br />Ȼ��JMX��ǿ��Զ��ֹ�ˣ����������ṩһЩͨ�õ���Ϣ���⣬����ͨ���ض��ı�̽ӿ��ṩһЩ��Ծ�������ר����Ϣ����JConsole��JMX�ͻ��˹�����չʾ�������˵���ǳ���Ա���԰���Ҫչʾ����Ϣ����һ�ֽ���MBean��Java�����ڣ�Ȼ��JConsole֮��Ŀͻ��˹��߿������ӵ�JMX����ʶ��MBean����ͼ�ν�������ʾ���Ӵ�����ĽǶȴ���������ʵ�е������������һ�������http��������Ȼ��http������ִ������������󲢷�����Ӧ�����ݣ���ĳ�ֽǶ���˵JConsole��JMXҲ�������ַ�ʽ�����ģ�ֻ������ʹ�õ�Э�鲻��http����������Э���ʽ����http���ݰ����������ǵ�ȷ���Կͻ���/����������ģʽ�����ģ�������ɵ�����Ҳ��ࡣ<br />?<br />��ô��Ȼ����http��JMX���кδ��������ء� ��ʵ�ϣ�JMX����ɵ�����ͨ��http��ȷ������ɣ�ֻ����ĳЩ�������JMX��������ӷ��㡣<br />?<br />����˵����Ҫ֪���������ϸ������г���������Ϣ�� ��ִ���˶��ٴ����ݿ����������������ж��ٸ������ڵȴ�����<br />?<br />��õĽ�����������ǻ��ڳ���������һ��http���񣬵����յ����Կͻ��˵�������Щ��Ϣ������ʱ�����ǵ�http������������Щ��Ϣ����ת�����ض���ʽ��������JSON���ظ��ͻ��ˣ��ͻ��˻���ĳ�ַ�ʽչ����Щ��Ϣ��<br />?<br />����JMX��Ϊ�����������������Ҳ����ˣ��������ݵĽ�����ʽ�ϻ����в�ͬ��<br />?<br />��������չʾJMX�������ɴ�����ġ�<br />?<br />һ������һ��չʾ������Ϣ��MBean�ӿ�

```java
public interface ServerInfoMBean {
    int getExecutedSqlCmdCount();
}
```

��ʹ�� Standard Mbean ��Ϊ���ݴ����������������ӿڵĶ����Ǳ���ģ� ���ҽӿ����Ʊ����ԡ�MBean��������ʽ�β��<br />?<br />����ʵ�־����MBean

```java
public class ServerInfo implements ServerInfoMBean {
    public int getExecutedSqlCmdCount() {
        return Dbutil.getExecutedSqlCmdCount();
    }
}
```

�����ڳ����ĳ���ط�����JMX����ע��ServerInfoMBean

```java
    public static void main(String[] args)  throws JMException, Exception{
        MBeanServer server = ManagementFactory.getPlatformMBeanServer();
        ObjectName name = new ObjectName("serverInfoMBean:name=serverInfo");
        server.registerMBean(new ServerInfo(), name);
    }
```

�ġ����г��򣬲�ͨ��JConsole�鿴<br />?<br />������������ڱ��أ�Jconsole���Զ���⵽����Ľ��̣����˫�����뼴��

![2.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863134753-067ac892-00e1-4bba-8311-251c7807510b.png#align=left&display=inline&height=621&linkTarget=_blank&name=2.png&originHeight=750&originWidth=900&size=61059&width=746)

��JConsole���漴��չʾ���Ƕ����MBean�е�����

![3.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863150584-938a15a3-662a-49a2-9d47-b1a4af607e10.png#align=left&display=inline&height=628&linkTarget=_blank&name=3.png&originHeight=750&originWidth=891&size=22039&width=746)

��ô����Java���򲢷������ڱ��ض���������Զ�˷�����������Ӧ�����ͨ���ͻ���ȥ�����أ� �ܼ򵥣�ֻҪʹ��JDK�ṩ��JMX�������˿��ṩ���񼴿�

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

����������Java����ָ�������в���Ҳ<br />?
```shell
-Djava.rmi.server.hostname=127.0.0.1
-Dcom.sun.management.jmxremote.port=10086
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
```
?<br />Ȼ��ʹ��JConsole������Զ�˽��̹��ܼ���

![4.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863217822-0080129f-38b2-4e54-8e54-9824e7532b61.png#align=left&display=inline&height=621&linkTarget=_blank&name=4.png&originHeight=750&originWidth=900&size=42655&width=746)

����Ĳ����ͱ����޲<br />?<br />��������ṩһ��http��������������ǲ���Ҫ���˲��٣�http��һ�����ӳ���Ӧ������㷺�����ܸ�ǿ��ķ�����������Ĺ���ҲҪ����һЩ��JMX����һ�����Ӿ��塢Ӧ���治��ô�㡢����Ҳû��httpǿ��ķ��񣬲�������ʤ�ڽ���ض�����������ɷ��㣬�����ʾ���Ѿ��ܺõ�˵���ˡ�<br />?<br />���⣬JMX��Jconsole��������ֻ��չʾ���ݣ�������ִ��Java�������������ʾ��Ϊ���������ٽ���һϵ�иĽ���

һ����չServerInfoMBean�ӿں�ʵ�ֵ���

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

�������г���ʹ��JConsole����

![5.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863265109-86d81634-0f77-4fbf-8384-d52ab34c7e8d.png#align=left&display=inline&height=621&linkTarget=_blank&name=5.png&originHeight=750&originWidth=900&size=52031&width=746)

mbeanҳǩ�г�������������ӵķ���<br />?<br />�������printString��ť���÷���

![6.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863277718-99b7248c-b909-41c7-8860-228064b8102f.png#align=left&display=inline&height=621&linkTarget=_blank&name=6.png&originHeight=750&originWidth=900&size=39705&width=746)

���������ã�ͬʱ����̨Ҳ��ӡ��ͨ��Jconsole���ݵĲ���

![7.png](https://cdn.nlark.com/yuque/0/2019/png/127662/1546863288945-2ad996ab-6201-4730-ba22-eb7430dd4a0f.png#align=left&display=inline&height=188&linkTarget=_blank&name=7.png&originHeight=188&originWidth=686&size=7860&width=686)

����ֻ�ǽ�����JMX���ô����������ʹ�÷�������ȻJMX�����ṩ�Ĺ���Զ�����ˣ����������Բ���JConsole���ǿͻ��˱�̵ķ�ʽ���ʵȵȣ� ����Ȥ��ͬѧ���������о���<br />?<br />�ܶ���֮�� �Ҿ���JMX��һ��С�ɾ����Ĺ��ߣ��ڲ���Ҫ������ĵ�ͨ��http��������server\client��ʽ�ṩ����ʱ�������������ô���ʱ���ˡ�

