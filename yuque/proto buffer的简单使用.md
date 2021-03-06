protobuf是google推出的一种数据格式，作用和json和xml一致，用于在不同终端之间数据通信。

但是在使用层面，protobuf和传统的json、xml略有不同， 他依赖与google推出的数据格式生成工具。

工具下载地址： [https://github.com/google/protobuf/releases](https://github.com/google/protobuf/releases)

以windows平台为例，我们下载当前最新的 protoc-3.5.1-win32.zip，解压后在bin目录下有 protoc.exe， 此程序即可当作protoc命令执行，使用此命令可以根据protobuf数据格式定义文件生成具体语言的数据格式，当前protobuf支持的编程语言有c++、java、c#、python、php、js、oc等。

我们通过一个java示例来大致讲解protobuf的使用

# <a name="dpwack"></a>在java中使用protobuf

创建一个person.proto文件，文件内容如下

```xml
syntax = "proto2";

package pto;

message PersonInfo{
    required string name = 1;
    required int32 age  = 2;
    required int32 gender = 3;
    optional string address = 4;    
    repeated string friend = 5;
}
```

文件内容的含义在文章后面再进行讲解。

执行命令一下命令生成java版本的数据格式 

```powershell
protoc.exe -I=.  --java_out=.  person.proto
```

命令执行完毕后，在目录下会生成一个pto包， 包里面有一个Person.java文件。将此文件加入java项目即可使用它。与此同时还需要在java项目中引入解析protobuf数据格式的jar包，可使用以下maven配置项导入包

```xml
<!-- https://mvnrepository.com/artifact/com.google.protobuf/protobuf-java -->
<dependency>
    <groupId>com.google.protobuf</groupId>
    <artifactId>protobuf-java</artifactId>
    <version>2.6.1</version>
</dependency>
```

```java
Person.PersonInfo.Builder builder  = Person.PersonInfo.newBuilder();
builder.setName("陈大侠");
builder.setAge(30);
builder.setGender(1);
builder.setAddress("杭州");
builder.addFriend("张三");
builder.addFriend("李四");
Person.PersonInfo personInfo = builder.build();
FileOutputStream fileOutputStream = new FileOutputStream("C:\\Users\\Desktop\\新建文本文档.txt");
personInfo.writeTo(fileOutputStream);
```

以上代码可将我们上面定义的格式的数据保存至文件，文件的内容是不可读的乱码，只有protobuf程序才能解码识别。 

读取protobuf数据格式的代码如下

```java
FileInputStream fileInputStream = new FileInputStream("C:\\Users\\Desktop\\新建文本文档.txt");
Person.PersonInfo personInfo1 =  Person.PersonInfo.parseFrom(fileInputStream);
System.out.println(personInfo1.toString());
```

下面我们讲解protobuf定义文件内容的具体含义

# <a name="ir6roq"></a>proto文件的含义

以之前的示例为例，文件内容如下

```protobuf
syntax = "proto2";

package pto;

message PersonInfo{
    required string name = 1;
    required int32 age  = 2;
    required int32 gender = 3;
    optional string address = 4;    
    repeated string friend = 5;
}
```

## <a name="xvbblo"></a>语法声明

文件第一行是语法声明， 在protobuf2中可以省略，在protobuf3中则必须要声明， 目前protobuf支持proto2和proto3两个语法版本。

在protobuf3中，假如不指定语法版本，那么执行protoc命令时将报错

```plain
[libprotobufWARNING google/protobuf/compiler/parser.cc:546] No syntax specified for theproto file: person.proto. Please use 'syntax = "proto2";' or 'syntax= "proto3";' to specify a syntax version. (Defaulted to proto2syntax.)
```

## <a name="mkb9rd"></a>包声明

package pto 是包声明，以java为例，将定义文件转换为java文件后， 此包既是java中的包。

## <a name="xancwz"></a>消息体声明

message 是消息体声明，一个message既是一个消息体， 类比于一个json对象。

## <a name="0nm7hz"></a>字段声明

消息中的是消息字段声明，字段声明由四部分组成，字段修饰符、字段数据类型、字段名称、字段编号标签。

### <a name="v3lbnb"></a>字段修饰符

required表示此字段的值是必须的，当构造数据时必须指定它

optional表示此字段值是可选的，当构造数据时可以不指定

repeated可以当作是声明一个列表类型

### <a name="m9cxlw"></a>字段数据类型

这里的字段数据类型和编程语言中的数据类型并没有两样，protobuf支持以下数据类型



![image.png | left | 468x396](https://cdn.yuque.com/yuque/0/2018/png/127662/1529025640653-f4a2b94d-111e-4130-8d02-218e448e4e42.png "")


### <a name="7ataoc"></a>字段名称

即字段的名称

### <a name="x3qfpo"></a>字段编号标签

关于字段声明中的这个部分， 可以当成是字段的身份，protobuf解析程序是通过这个编号去数据中寻找对应值的，而不是我们想象中的字段名称，可以把它看成是字段的ID。 如果我们根据一个message生成了数据并将数据保存在磁盘以便之后某个时候去读取， 可如果我们在读取之前修改了某个字段的编号标签，那么在读取的时候，此字段的值将无法被识别，因为它的ID变了。 这也表示，当我们指定message中字段的编号标签后， 在之后对message格式进行更新时 ， 字段的编号标签无论如何是不能变的。 

当然， protobuf是一种强大的数据结构，功能特性远不止此，它还支持许多其它常见的语法。

## <a name="t9liwm"></a>枚举

```protobuf
package pto;


import "addr.proto";

enum Gender {
    MALE = 1;
    FEMALE = 2;
}

message PersonInfo{
    required string name = 1;
    required int32 age  = 2;
    required Gender gender = 3;
    AddrInfo string= 4;    
    repeated string friend = 5;
}
```

我们扩展了person.ptoto文件的内容，在里面使用了枚举。protobuf支持枚举， 以java为例， 通过protoc命令将此定义文件编译对应的java格式，那么其中的Gender枚举会被编译为java中的枚举类型，和java中自己定义的枚举一般无二。 

## <a name="gp27fw"></a>导入文件

protobuf支持import功能， import的作用是将一个proto文件定义的内容导入另一个文件，和常规编程语言中的导入功能一样，是为了服用已存在的代码或者将通用的代码几种在一起供其它模块调用。 

先定义一个addr.proto文件，表示地址信息。

```protobuf
package pto;

message AddrInfo{
    required string addr = 1;
    optional int32 post = 2;
}
```

然后扩展person.ptoto的内容使用这个地址，可以在person.proto中使用import命令导入addr.proto文件的内容

```protobuf
package pto;


import "addr.proto";

enum Gender {
    MALE = 1;
    FEMALE = 2;
}

message PersonInfo{
    required string name = 1;
    required int32 age  = 2;
    required Gender gender = 3;
    AddrInfo address = 4;    
    repeated string friend = 5;
}
```


