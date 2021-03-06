可以把golang中的结构体看做是传统面向对象编程语言中的类，它有属性也有方法。 

```go
type Person struct {
	Name   string
	Gender string
	Age    int
	Addr   string
}

func (self *Person) ModifyAddr(addr string) {
	self.Addr = addr
}
```

Name、Gender是结构体Person的属性，ModifyAddr是结构体Person的方法。

我们看到，ModifyAddr方法第一个括号中接受的参数类型是一个Person类型的指针，在这里，这个类型并不一定需要是结构的指针类型，也可以是结构的原始类型。

```go
func (self Person) ModifyAddr(addr string) {
	self.Addr = addr
}
```

因为golang语法的特殊性，使人迷惑与着两者的区别。其实方法

```go
func (self *Person) ModifyAddr(addr string) {
	self.Addr = addr
}
```

与函数

```go
func ModifyAddr( self *Person, addr string)  {
	self.Addr = addr
}
```

是同意的，只是方法将参数列表拆开了而已。 所以

```go
func (self *Person) ModifyAddr(addr string) 
```

与

```go
func (self Person) ModifyAddr(addr string) 
```

的区别其实就是

```go
func ModifyAddr( self *Person, addr string)  
```

与

```go
func ModifyAddr( self Person, addr string)  
```

的区别。 一个按指针（引用）传递，一个按值传递， 传递指针的方法可修改原始结构的属性值；而传递值的则不可以， 因为传递的值是原始结构的拷贝。所以

```go
func (self Person) ModifyAddr(addr string) {
	self.Addr = addr
}
```

如果这么写，其实是没有意义的，因为对self对象的修改只反应到了原始结构的拷贝上而已。 


