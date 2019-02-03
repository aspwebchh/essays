# javascript中caller与callee的作用以及用法

这两个关键字在平时编码中几乎难以用到，但它们既然存在于javascript语言体系中，那么还是有必要了解下。

**caller**是javascript函数类型的一个属性，它引用调用当前函数的函数

```javascript
function func() {
    alert(func.caller);
}

function func1() {
    func();
}

func1();
```

比如上面的代码，  因为func函数是杯func1函数调用的， 所以func函数中对caller的引用就是func1函数。如果func函数直接在顶层的javascript环境中被调用，那么caller将返回null。

我们可以利用caller的特性跟踪函数的调用链

```javascript
function func() {
	let caller = func.caller;
	while(caller != null) {
		console.log(caller.name);
		caller = caller.caller;
	}
}

function func1() {
	func();
}

function func2() {
	func1();
}

function func3() {
	func2();
}

func3();
```

以上代码将func3到func的函数调用链打印出来。

**callee**则不是函数对象的属性，它是函数上下文中arguments对象的属性

```javascript
function func() {
	alert(arguments.callee);
}
```

它引用的是函数自身，在上面的代码中，arguments.callee引用的就是func函数本身。既然他引用的是函数本身，那么似乎显得有点多余，当我们需要在函数体内使用函数本身时，直接通过函数名调用就可以了，干嘛还要多此一举的通过arguments.callee这样去调用。然而我觉得callee存在的意义可能是想解耦函数本身对函数名称的依赖吧， 比如说在递归的环境下，函数内部通常还要调用函数本身， 而调用函数本身就免不了硬编码函数名称， 如果函数名称有变化， 那么函数中的代码也需要修改，使用callee就可以避免此类情况。

```javascript
function factorial( num ) {
	if( num == 1 ) {
		return 1;
	}
	let result = num * factorial(num - 1);
	return result;
}

alert(factorial(100));
```

上面的阶乘函数通过callee可以改造成

```javascript
function factorial( num ) {
	if( num == 1 ) {
		return 1;
	}
	let result = num * arguments.callee(num - 1);
	return result;
}

alert(factorial(100));
```

如此同样实现递归， 但是可以做到函数体不依赖函数名称。
