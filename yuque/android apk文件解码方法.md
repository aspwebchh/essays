android apk安装包中的代码和资源可以通过工具反编译出来

## <a name="iaahmo"></a>反编译资源

1. 下载apktool.jar， 下载地址： [https://bitbucket.org/iBotPeaches/apktool/downloads/](https://bitbucket.org/iBotPeaches/apktool/downloads/)
2. 将下载下来的apktool-x.x.jar（带版本号）文件重命名为apktool.jar
3. 下载apktool.bat， 下载地址：[https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat](https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/windows/apktool.bat)
4. 运行apktool命令  apktool.bat d  ../../xxx.apk  反编译出apk 中的资源文件

通过 apktool.jar只能提取apk包中的资源文件， 不能反编译出java代码

参考链接： [https://ibotpeaches.github.io/Apktool/install/](https://ibotpeaches.github.io/Apktool/install/)

## <a name="v4hygo"></a>反编译代码

可以使用 dex2jar 将 apk包中的classes.dex反编译成.class文件

1. 下载 dex2jar工具 ，下载地址： [https://sourceforge.net/projects/dex2jar/files/](https://sourceforge.net/projects/dex2jar/files/)
2. 使用压缩软件解压apk文件， 并在解压后的文件夹中找到classes.dex文件，将之复制到 dex2jar 文件夹下
3. 执行命令 d2j-dex2jar classes.dex 反编译得到jar包 classes-dex2jar.jar
4. 使用 jd-gui 工具查看 jar 包中的代码，  jd-gui 下载地址：[http://jd.benow.ca/](http://jd.benow.ca/)

参考链接： [https://blog.csdn.net/coder\_pig/article/details/51379463](https://blog.csdn.net/coder_pig/article/details/51379463)

 

