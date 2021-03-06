# <a name="iqacfc"></a>导入依赖包

logback是一个java日志记录工具， 使用以下maven配置可导入相关包和依赖
 
```xml
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.3</version>
</dependency>
```

# <a name="xyxpfa"></a>加载配置文件

使用logback需要一个xml配置文件，假定配置文件在程序的当前工作目录中，可使用以下代码为logback指定配置文件

```java
private static void initLog(String logPath) {
    LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
    try {
        JoranConfigurator configurator = new JoranConfigurator();
        configurator.setContext(lc);
        lc.reset();
        configurator.doConfigure(logPath);
    } catch (JoranException e) {
        throw new RuntimeException(e);
    }
}

 initLog(System.getProperty("user.dir") + "\\logback.xml" );
```

假如不手动指定配置文件，logback自己会去 classpath下寻找logback-test.xml或logback.xml配置文件，如果找不到，logback将在控制台输出日志。

# <a name="9egawz"></a>配置文件介绍

logback配置文件大致框架如下， 配置细节在此框架的基础上进行延申

```xml
<configuration>
	<property></property>
	<appender></appender>
	<root></root>
</configuration>
```

## <a name="1k97xw"></a>configuration根节点
根节点有三个属性

### <a name="2xivrn"></a>scan属性
此属性是一个布尔值，表示是否支持配置文件热更新

### <a name="fs54mq"></a>scanPeriod属性
scan属性为true时生效， 表示多久去检查配置文件一次， 以识别配置文件是否更新，此值默认单位是毫秒

### <a name="lh3apk"></a>debug属性
是否打印logback自身的调试信息

完整样例

```plain
<configurationscan="true" scanPeriod="10000" debug="false">
```

配置文件支持热更新，logback每10秒检查配置文件一次。 不打印调试信息

## <a name="5qfolz"></a>property节点

此节点可自定义属性，定义的属性可在配置文件其它位置使用

```plain
<property name="LOG_HOME"value="C:/Users/宏鸿/Desktop/log" />
```

如需要在配置文件其它位置使用此属性，可以 ${LOG\_HOME}的方式引用

## <a name="tibcgf"></a>appender节点

### <a name="cwdwxn"></a>将日志打印至控制台

```xml
<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
        <pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M : %m%n</pattern>
    </encoder>
</appender>
```

以此配置项为例，它的作用是将日志信息打印至控制台。将日志打印在控制台的逻辑是现在ConsoleAppender类中，ConsoleAppender类中有一个encoder属性，此属性对应的配置就是appender节点下encoder子节点中的内容。 

### <a name="73sdpe"></a>每天生成独立日志文件的配置

```xml
<appender name="FILE"  class="ch.qos.logback.core.rolling.RollingFileAppender">
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
        <fileNamePattern>${LOG_HOME}/log-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
        <maxHistory>30</maxHistory>
        <timeBasedFileNamingAndTriggeringPolicy
                class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
            <maxFileSize>10MB</maxFileSize>
        </timeBasedFileNamingAndTriggeringPolicy>
    </rollingPolicy>
    <encoder>
        <pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M : %m%n</pattern>
    </encoder>
</appender>
```

此配置表示每天生成一个配置文件，并保留30天。与此同时，每个日志文件将不大于10M， 如大于10M将新启一个文件存储

```xml
<timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
    <maxFileSize>10MB</maxFileSize>
</timeBasedFileNamingAndTriggeringPolicy>
```

是实现此功能的配置项。

### <a name="dm6mcg"></a>生成指定容量日志文件的配置

```xml
<appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <File>${LOG_HOME}/logback.log</File>

    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
        <FileNamePattern>${LOG_HOME}/log.%i.log</FileNamePattern>
        <MinIndex>1</MinIndex>
        <MaxIndex>12</MaxIndex>
    </rollingPolicy>

    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
        <MaxFileSize>5MB</MaxFileSize>
    </triggeringPolicy>
    <encoder>
        <Pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M %m%n</Pattern>
    </encoder>
</appender>
```
 
此配置项表示将日志记录至文件，文件内容不大于5M，超过5M则创建新文件。文件最多12个，超过12个，最旧的文件将被删除。

### <a name="rst6dc"></a>记录特定级别的日志

可以在 appender 设置 filter 子节点，用于指定只记录特定级别的日志

```xml
 <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <filter class="ch.qos.logback.classic.filter.LevelFilter">
        <level>ERROR</level>
        <OnMismatch>DENY</OnMismatch>
        <OnMatch>ACCEPT</OnMatch>
    </filter>

    <File>${LOG_HOME}/logback.log</File>

    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
        <FileNamePattern>${LOG_HOME}/log.%i.log</FileNamePattern>
        <MinIndex>1</MinIndex>
        <MaxIndex>12</MaxIndex>
    </rollingPolicy>

    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
        <MaxFileSize>5MB</MaxFileSize>
    </triggeringPolicy>
    <encoder>
        <Pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M %m%n</Pattern>
    </encoder>
</appender>
```

此配置表示只记录 logger.error级别的日志

## <a name="1vxviv"></a>root节点

root节点有两个作用，一是指定记录的日志级别，二是指定记录日志的目标

### <a name="20igfy"></a>指定记录的日志级别

logback的5种日志级别定义在  ch.qos.logback.classic.Level 类中，分别是ERROR、WARN、INFO、DEBUG、TRACE，其中ERROR是最严重的级别，TRACE是最平常的级别。

 root几点有一个level属性， 用于自定日志级别，如果指定某个级别，那么比此级别轻微的日志都将不被记录， 假如指定ERROR级别， 那么除了ERROR日志其它日志都将不被记录；假如指定TRACE级别，那么所有日志都将被记录。

```plain
<root level="TRACE"></root>
```

除此之外， 你还可以指定OFF和ALL两个选项，它们一个是不记录任何级别日志， 一个是记录所有级别的日志。

```java
public static final Level OFF = new Level(2147483647, "OFF");
public static final Level ERROR = new Level(40000, "ERROR");
public static final Level WARN = new Level(30000, "WARN");
public static final Level INFO = new Level(20000, "INFO");
public static final Level DEBUG = new Level(10000, "DEBUG");
public static final Level TRACE = new Level(5000, "TRACE");
public static final Level ALL = new Level(-2147483648, "ALL");
```

这从传递给level构造函数的数字大小就能推测出其作用。

### <a name="xq60nt"></a>指定记录日志的目标
```xml
<root level="ALL">
    <appender-ref ref="STDOUT"/>
    <appender-ref ref="FILE"/>
</root>
```

可使用appender-ref指定记录目标，换句话说，它的作用是使配置文件中的appender节点配置生效。

## <a name="ctghzq"></a>完整配置文件样例

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<configuration scan="true" scanPeriod="10000" debug="false">
    <property name="LOG_HOME" value="C:/Users/宏鸿/Desktop/log" />

    <!-- 控制台输出日志 -->
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M : %m%n</pattern>
        </encoder>
    </appender>

    <!-- 按照每天生成日志文件 -->
    <appender name="FILE1"  class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!-- rollover daily -->
            <fileNamePattern>${LOG_HOME}/log-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxHistory>5</maxHistory>
            <timeBasedFileNamingAndTriggeringPolicy
                    class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <!-- or whenever the file size reaches 100MB -->
                <maxFileSize>10MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M : %m%n</pattern>
        </encoder>
    </appender>

    <!-- 文件输出日志 (文件大小策略进行文件输出，超过指定大小对文件备份)-->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <File>${LOG_HOME}/logback.log</File>

        <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
            <FileNamePattern>${LOG_HOME}/log.%i.log</FileNamePattern>
            <MinIndex>1</MinIndex>
            <MaxIndex>12</MaxIndex>
        </rollingPolicy>

        <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
            <MaxFileSize>5MB</MaxFileSize>
        </triggeringPolicy>
        <encoder>
            <Pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M %m%n</Pattern>
        </encoder>
    </appender>

    <appender name="FILE-ERROR" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>ERROR</level>
            <OnMismatch>DENY</OnMismatch>
            <OnMatch>ACCEPT</OnMatch>
        </filter>

        <File>${LOG_HOME}/logback-err.log</File>

        <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
            <FileNamePattern>${LOG_HOME}/log-error.%i.log</FileNamePattern>
            <MinIndex>1</MinIndex>
            <MaxIndex>12</MaxIndex>
        </rollingPolicy>

        <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
            <MaxFileSize>5MB</MaxFileSize>
        </triggeringPolicy>
        <encoder>
            <Pattern>%d{yyyy-MM-dd HH:mm:ss}, %p, %c, %t, %r, %ex, %F, %L, %C{1}, %M %m%n</Pattern>
        </encoder>
    </appender>

    <root level="ALL">
        <appender-ref ref="STDOUT"/>
        <appender-ref ref="FILE"/>
        <appender-ref ref="FILE-ERROR"/>
    </root>
</configuration>
```
 

 


