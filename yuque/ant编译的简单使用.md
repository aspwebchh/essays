ant是一种java程序构建工具，通俗的讲就是一种打包工具，用来打包jar的。 

下面我们通过一个实际的例子来讲解如何在idea中使用ant打包java程序。

# <a name="3bprte"></a>新建项目

在idea中新建一个普通的java项目，这个项目依赖两个第三方jar包，jar包在lib目录下



![未命名图片.png | center | 306x289](https://cdn.yuque.com/yuque/0/2018/png/127662/1529407534176-53d24229-6ee7-4d20-b138-a97eeb3620e6.png "")


# <a name="mmo0vz"></a>添加build.xml文件

在项目根目录下新建build.xml文件

点击idea右侧的ant build按钮调出ant操作对话框， 再点击对话框上面的加号，将build.xml文件导入，并将下面的xml内容复制到build.xml文件里

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!--Ant的所有内容必须包含在<project></project>里面，name是你给它取的名字，basedir指工作的根目录，.代表当前目录，default代表默认要做的事情。-->
<project name="ant-test" default="run" basedir=".">
    <!--<property />设置变量-->
    <property name="src" value="src"/>
    <property name="dest" value="classes"/>
    <property name="ant-test-jar" value="ant-test.jar"/>
    <property name="jar-lib" value="jar-lib"/>

    <path id="compile.classpath">
        <fileset dir="${jar-lib}">  <!-- 编译java程序用到的第三方包所在的目录 -->
            <include name="*.jar" />
        </fileset>
    </path>

    <!--每个target代表你想做的操作，给这个操作命名，及name值，depends是它所依赖的target在执行这个target，例如这里的compile之前ant会先检查init是否曾经被执行过，如果执行
        过则直接直接执行compile，如果没有则会先执行它依赖的target例如这里的init，然后在执行这个target-->
    <!--新建文件夹-->
    <target name="init">
        <mkdir dir="${dest}"/>
    </target>


    <target name="copy">
        <copy todir="${jar-lib}">
            <fileset dir="./lib">  <!-- 编译java程序用到的第三方包所在的目录 -->
                <include name="*.jar" />
            </fileset>
        </copy>
    </target>

    <!--开始运行编译-->
    <target name="compile" depends="init">
        <javac srcdir="${src}" destdir="${dest}">
            <classpath refid="compile.classpath" />
        </javac>
    </target>
    <!--创建jar包-->
    <target name="build" depends="compile">
        <pathconvert property="mf.classpath" pathsep=" ">
            <mapper>
                <chainedmapper>
                    <!-- jar包文件只留文件名，去掉目录信息 -->
                    <flattenmapper/>
                    <!-- add lib/ prefix -->
                    <globmapper from="*" to="${jar-lib}/*"/>
                </chainedmapper>
            </mapper>
            <path refid="compile.classpath"/>
        </pathconvert>
        <jar jarfile="${ant-test-jar}" basedir="${dest}">
            <manifest>
                <attribute name="Main-Class" value="Main" />
                <attribute name="Class-Path" value="${mf.classpath}"/>
            </manifest>
        </jar>
    </target>
    <!--开始运行-->
    <target name="run" depends="build">
        <java jar="${ant-test-jar}" fork="true"/>
    </target>
    <!--删除生成的文件-->
    <target name="clean" depends="run">
        <delete dir="${dest}"/>
        <delete file="${ant-test-jar}"/>
    </target>
    <target name="rerun" depends="clean,run">
        <ant target="clean" />
        <ant target="run" />
    </target>

</project>

```

# <a name="yc4gzh"></a>build.xml内容讲解

## <a name="5r4saa"></a>project节点
project节点是配置文件的根节点，其中有三个属性

### <a name="gzegrq"></a>name属性
表示名称

### <a name="l0mgrg"></a>default属性
表示默认运行target

### <a name="ofydxp"></a>basedir属性
表示ant执行的路径

## <a name="1xfeat"></a>property节点
property节点用于定义build.xml中各处可以应用的属性，如果拿java代码来做类比，相当于成员变量。此节点有两个属性，分别是name和value，对应属性名和属性值。  配置文件各处可以${property\_name} 的方式引用定义的属性。

## <a name="nu0fwg"></a>target节点
target节点用于定义操作，配置文件中的每个target节点都会在idea的ant对话框中出现



![未命名图片1.png | center | 320x300](https://cdn.yuque.com/yuque/0/2018/png/127662/1529407613301-0f84ec79-852d-4680-a43d-da0e79b3522c.png "")


target节点有一些常用的属性

### <a name="4g19td"></a>name属性
表示操作名称

### <a name="rxycyh"></a>depends属性
表示此操作依赖的前置操作

```xml
<target name="compile" depends="init">
    <javac srcdir="${src}" destdir="${dest}">
        <classpath refid="compile.classpath" />
    </javac>
</target>
```

以此操作为例，它表示编译操作执行时init操作必须实现执行，假如init操作未执行， 那么也会被自动执行

## <a name="am46la"></a>path节点 

表示一组引用的路径 

```xml
<path id="compile.classpath">
    <fileset dir="./lib">  
        <include name="*.jar" />
    </fileset>
</path>
```

以上示例配置表示lib目录下的所有jar文件。定义的路径节点可以通过

```xml
<classpath refid="compile.classpath" />
<path refid="compile.classpath"/>
```

等方式引用

