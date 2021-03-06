在java反射机制中，代表java类型的Class<?>对象有两个获得类字段的方法getFields和getDeclareFields，这两个方法的区别如下

# <a name="5gz1rx"></a>getFields方法

返回一个Field类型数组，其中包含当前类的public字段，如果此类继承于某个父类，同事包括父类的public字段。其它的proteced和private字段，无论是属于当前类还是父类都不被此方法获取。 

# <a name="vedzup"></a>getDeclareFields方法

返回一个Field类型数组，结果包含当前类的所有字段，private、protected、public或者无修饰符都在内。另外，此方法返回的结果不包括父类的任何字段。 此方法只是针对当前类的。 

# <a name="wz3avn"></a>代码示例

```java
public class MainSuper {
    public int publicField;
    protected long protecedField;
    private String privateField;
    public static int staticPublicField;
    protected static long staticProtectedField;
    private static String staticPrivateField;
}
```

```java
public class Main extends MainSuper {

    public int publicField;
    protected long protectedField;
    private String privateField;

    public static int staticPublicField;
    protected static long staticProtectedField;
    private static String staticPrivateField;

    public static void main(String[] args) {
        System.out.println("getFields方法");
        System.out.println("..................................................");
        printFields(Main.class.getFields());
        System.out.println("--------------------------------------------------");
        System.out.println("getDeclaredFields");
        System.out.println("..................................................");
        printFields(Main.class.getDeclaredFields());
    }

    private static void printFields( Field[] fields ) {
        for(Field field : fields) {
            System.out.println(field);
        }
    }
}
```

执行结果如下

```plain
getFields方法
..................................................
public int Main.publicField
public static int Main.staticPublicField
public int MainSuper.publicField
public static int MainSuper.staticPublicField
--------------------------------------------------
getDeclaredFields
..................................................
public int Main.publicField
protected long Main.protectedField
private java.lang.String Main.privateField
public static int Main.staticPublicField
protected static long Main.staticProtectedField
private static java.lang.String Main.staticPrivateField
```

# <a name="i82kgd"></a>相似的方法
与获得字段的方法对应，获得方法、内部类、构造方法也有对应的方法

getMethods
getDeclaredMethods

getClasses
getDeclaredClasses

getConstructors
getDeclaredConstructors

# <a name="w1emol"></a>访问私有成员
当我们通过 getDeclaredXXX 系列方法获得私有成员时，默认是无法访问的，强行访问会报类似的错误

```plain
java.lang.IllegalAccessException: Class client.Debugger can not access a member of class client.ClientServer with modifiers "private static final"
	at sun.reflect.Reflection.ensureMemberAccess(Reflection.java:102)
```

要使私有成员能访问，进行如下调用即可

```java
field.setAccessible(true);
```


