# <a name="eze5ci"></a>thrift的使用场景

thrift是一个跨语言RPC框架，所以它定义了一种数据格式， 以便用于在不同语言中交互。我们可以利用这种数据结构作为协助我们更好的完成工作的工具。 

比如说我们可以将一个thrift类转换成二进制数据，并储存起来

```java
AccountInfo accountInfo = new AccountInfo();
accountInfo.setAge(30);
accountInfo.setSex(1);
accountInfo.setNickName("陈大侠");

TSerializer tSerializer = new TSerializer(new TCompactProtocolFactory());
byte[] data = tSerializer.serialize(accountInfo);
save(data);
```

有需要的时候将事先存储的二进制数据读取出来，转换成原本的类型在程序种使用

```java
byte[] data = read();
TDeserializer tDeserializer = new TDeserializer(new TCompactProtocolFactory());
AccountInfo accountInfo1 = new AccountInfo();
tDeserializer.deserialize(accountInfo1,data);
System.out.println(accountInfo1);
```

这种序列化和反序列化的需求在程序设计种非常常见， thrift提供了非常适合解决这种问题的方案。

# <a name="nki9xg"></a>thrift的类型定义

thrift支持一种数据格式定义文件，并提供一个编译程序， 通过这个编译程序可将数据格式定义转换成特定语言的相关类型。 

以java语言为例

创建一个 persion.thrift 文件

在文件中定义一个struct结构类型

```plain
struct Person{
    1:string name;
    2:i32 age;
    3:i16 gender;
    4:string addr;
}
```

执行编译命令后

```powershell
.\thrift.exe -genjava .\person.thrift
```

会生成一个Person.java 文件， 里面定义了一个Person类型，Person，类里面有上面定义的结构中的属性以及这些属性的get set方法， 换句话说， thrift格式定义中的struct结构会被编译器转换成java类，其它各种数据类型也会被转换成java相应的数据类型。一言蔽之， thrift中的数据类型与java相应的类型一一对应，可通过编译器转换。

下面是thrift支持的语法以及数据类型

## <a name="g0hgnm"></a>基本类型

bool: 布尔类型，占一个字节
byte: 有符号字节
i16：16位有符号整型
i32：32位有符号整型
i64：64位有符号整型
double：64位浮点数
string：未知编码或者二进制的字符串

## <a name="5u42ta"></a>容器类型

List<t1>：一系列t1类型的元素组成的有序列表，元素可以重复
Set<t1>：一些t1类型的元素组成的无序集合，元素唯一不重复
Map<t1,t2>：key/value对，key唯一

## <a name="io9dbg"></a>结构体

使用struct关键字定义，对应java中的class2

## <a name="sxudtx"></a>异常类型

```plain
exception MyException {
    1: i32 errorCode,
    2: string message
}
```

异常定义与struct类型，只是生成的类是一个异常类，继承至 TException

## <a name="p767ty"></a>服务

此类型的作用与使用脱离了此文所要表述内容的范围，因此不在这里进行讲解。

## <a name="s4vxap"></a>类型定义

```plain
typedef i32 MyInteger   
typedef Tweet ReTweet  
```

类型定义在java种似乎不受支持

# <a name="acxmys"></a>thrift的代码生成

编译工具下载地址： [https://thrift.apache.org/download](https://thrift.apache.org/download)

执行编译命令：
```powershell
 .\thrift.exe -gen java .\person.thrift
```

# <a name="r8k0mk"></a>thrift的使用

以java为例

使用如下maven配置项导入thrift库

```xml
<!-- https://mvnrepository.com/artifact/org.apache.thrift/libthrift -->
<dependency>
    <groupId>org.apache.thrift</groupId>
    <artifactId>libthrift</artifactId>
    <version>0.9.3</version>
</dependency>
```

导入根据类型定义文件生成的java类至项目中即可使用

