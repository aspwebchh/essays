# 对JavaScript原型的理解

### 2018-4-30

## 一

在JavaScript中，我们使用构造函数创建对象。 每个构造函数都有一个prototype的对象类型属性， 这个属性同时会被构造函数的实例对象的__proto__属性引用

```javascript
function Person() {

}

var person = new Person();

console.log(person.__proto__ == Person.prototype) // true
```

## 二

当我们访问实例对象的某个属性时，访问步骤是先查找对象本身是否存在这个属性，存在则返回，  不存在则去对象的__proto__属性中查找，存在则返回，不存在则去目标对象的__proto__属性的__proto__属性中查找，也就是构造函数的prototype属性的__proto__中查找。构造函数的prototype属性是Object的实例，那么他引用的对象其实就是Object的prototype属性。所以访问对象属性最终的查找目标就是Object.prototype，当在Object.prototype也没有存在要找的属性时，整个查找过程就结束了。 原本其实还可以去Object.prototype.__proto__中查找，只不过这个属性的值为null，所以整个查找过程到了Object.prototype就结束了。  这就是所谓的原型链。


## 三

每个原型 对象都有一个 constructor 属性，这个属性会指回构造函数本身

```javascript
function Person() {

}

var person = new Person();

Person.prototype.constructor   == Person //true

 person.constructor  ==  Person //true

person.__proto__.constructor  == Person //true
 ```










