写的一个java程序处理一个文本文件，文本文件中内容有简体中文汉字和繁体中文汉字，繁体中文汉字部分读取到程序时出现乱码现象。 
 
据推测这应该是一个常见的编码问题。  
 
然而， 奇怪的是程序在intellijidea中启动运行并未出现此现象，使用 
 
`java -jar xxx.jar `
 
命令启动程序则出现乱码问题
 
再三比对 intellijidea启动执行程序的命令和手动编写的命令间的差异， 发现少指定了一项参数
 
`-Dfile.encoding=utf-8`
 
执行java命令时指定此参数， 问题消失
 
`java -Dfile.encoding=utf-8  -jar xxx.jar `

