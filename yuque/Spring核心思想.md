# <a name="u08nle"></a>依赖注入

依赖注入是面型接口编程的一种体现，是Spring的核心思想。 事实上依赖注入并不是什么高深的技术， 只是被Sping这么以包装就显得有些神秘。 

```java
class Main {
    interface Language {
        void print(String s);
    }

    static class Java implements Language{
        @Override
        public void print(String x) {
            System.out.println("System.out.print(\""+ x +"\")");
        }
    }

    static class Coder {
        private Language lang = new Java();

        public void helloWorld() {
            lang.print("hello world");
        }
    }

    public static void main(String[] args) {
        Coder coder = new Coder();
        coder.helloWorld();
    }
}

```

如上代码清单所示，Coder使用Java语言打印helloworld字符串， 在这里它不但依赖Language接口， 还依赖Java类，这使得它和Java类耦合在一起。 要消除这种依赖或者说解耦很容易

```java
class Main {
    interface Language {
        void print(String s);
    }

    static class Java implements Language{
        @Override
        public void print(String x) {
            System.out.println("System.out.print(\""+ x +"\")");
        }
    }

    static class Coder {
        private Language lang;

        public void setLang(Language lang) {
            this.lang = lang;
        }

        public void helloWorld() {
            lang.print("hello world");
        }
    }

    public static void main(String[] args) {
        Coder coder = new Coder();
        Language java = new Java();
        coder.setLang(java);
        coder.helloWorld();
    }
}
```

我们给Coder类增加了设置具体语言的方法，使得Coder类只依赖Language接口而不依赖具体的语言实现，换言之，Coder类和具体的语言解耦了，此时我们可以轻而易举的使用其它语言代替Java，比如说使用C#

```java
static class CSharp implements Language{
    @Override
    public void print(String x) {
        System.out.println("Console.Write(\""+ x +"\")");
    }
}


public static void main(String[] args) {
    Coder coder = new Coder();
    Language csharp = new CSharp();
    coder.setLang(csharp);
    coder.helloWorld();
}
```

这种在外部设置某个对象所依赖的具体对象的技巧就是依赖注入，这很很令人以外，一种最常见不过的编码技巧居然还有如此高大山的名称。 

对于Coder类来说，确定使用何种语言原本实在编译器期确定的，使用依赖注入后，使用何种语言便延时至运行期。

Spring框架的核心思想便是基于此，不过它的实现更进一步，它把创建各个对象设置依赖关系的过程动态化和通用化了。在我们的代码清单中，创建对象和设置依赖关系的main方法只适用与当前的情况，而Spring的IOC容器能适用与任何情况

通常，Spring的依赖关系由XML表示，IOC容器解析XML完成对象的创建和依赖注入。

我们将之前的代码用Spring框架来实现

```java
interface Language {
    void print(String s);
}
```

```java
 class Java implements Language{
    @Override
    public void print(String x) {
        System.out.println("System.out.print(\""+ x +"\")");
    }
}
```

```java
class CSharp implements Language{
    @Override
    public void print(String x) {
        System.out.println("Console.Write(\""+ x +"\")");
    }
}
```

```java
class Coder {
    private Language lang;

    public void setLang(Language lang) {
        this.lang = lang;
    }

    public Language getLang() {
        return lang;
    }

    public void helloWorld() {
        lang.print("hello world");
    }
}
```

依赖关系将由XML配置实现

```xml
<?xml version="1.0" encoding="utf-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
 http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

    <bean id="java" class="Java">
    </bean>

    <bean id="csharp" class="CSharp">
    </bean>

    <bean id="coder" class="Coder">
        <property name="lang" ref="csharp"></property>
    </bean>
</beans>
```

创建Coder对象的代码变为

```java
public static void main(String[] args) {
    ApplicationContext context = new FileSystemXmlApplicationContext("applicationContext.xml");
    Coder coder = (Coder) context.getBean("coder");
    coder.helloWorld();
}
```

具体的对象创建和依赖关系的设置将由IOC根据XML配置来完成。 

Spring使得依赖注入机制自动化，但是依赖注入的本质却没有变花。 

# <a name="kdb3sk"></a>面向切面编程

面向切面编程能实现不改变原有代码的前提下动态的对功能进行增强， 比如说在一个方法执行前或执行后做某些事情如记录日志、计算运行时间等等。

Spring中完美集成Aspectj，因此可以很方便的进行面向切面编程。 

Spring Aspectj有几个注解用以实现常用的面向切面编程功能

```java
@Aspect
public class Logger {
    @Before("execution(* controller.Default.*(..))")
    public void before(JoinPoint join){}

    @After("execution(* controller.Default.*(..))")
    public void after(){}

    @AfterReturning("execution(* controller.Default.*(..))")
    public void afterReturning() {}

    @AfterThrowing("execution(* controller.Default.*(..))")
    public void afterThrowing(){}

    @Around("execution(* controller.Default.*(..))")
    public void around(ProceedingJoinPoint jp) {}
}
```

如上代码所示， 此类对controller.Default类下的所有方法进行增强。 

## <a name="acvvcq"></a>@Before注解
@Before注解修饰的方法会在被增强的方法执行前被执行

## <a name="pcn8lc"></a>@After注解
@After注解修饰的方法会在被增强的方法执行后被执行

## <a name="4g1wyx"></a>@AfterReturning注解
@AfterReturning注解修饰的方法会在被增强的方法执行后被执行，但前提是被修饰的方法顺利执行结束，假如方法中途抛出异常，那么AfterReturning注解修饰的方法将不会被执行，而After注解修饰的方法是无论如何都会被执行。

## <a name="suuzgf"></a>@AfterThrowing注解
@AfterThrowing注解修饰的方法会在被增强的方法执行出错抛出异常的情况下被执行。

## <a name="pwokql"></a>@Around注解
@Around注解是@Before注解和@After注解的综合，它可以在被增强的方法的前后同时进行增强

```java
@Around("execution(* controller.Default.*(..))")
public void around(ProceedingJoinPoint jp) {
    try {
        System.out.println("before");
        jp.proceed();
        System.out.println("after");
    } catch (Throwable e) {
        System.out.println(e.getMessage());
    }
}
```

使用此注解，被增强的方法需要手动编码调用

jp.proceed();

如果在增强代码中不写这一句，那么被增强的方法将不会运行。

此外， 还有一个重要的注解 @Pointcut

## <a name="qybxri"></a>@Pointcut注解

此注解可以用来提炼切入点

```java
@Aspect
public class Logger {
    @Pointcut( value = "execution(* controller.Default.*(..))")
    public void pointcut() {}
    
    @Before("pointcut()")
    public void before(JoinPoint join){}

    @After("pointcut()")
    public void after(){}

    @AfterReturning("pointcut()")
    public void afterReturning() {}

    @AfterThrowing("pointcut()")
    public void afterThrowing(){}

    @Around("pointcut()")
    public void around(ProceedingJoinPoint jp) {}
}

```

@Before、@After等注解可以应用此注解声明的切入点，从而减少代码的重复。

