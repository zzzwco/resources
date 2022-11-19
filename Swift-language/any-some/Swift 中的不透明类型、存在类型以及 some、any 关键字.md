<br>

`2022/07/13`  `Xcode 14b3`  `Swift 5.7`

# 不透明类型、some 关键字

`some` 关键字由 Swift 5.1 引入，它用来修饰某个协议，使之成为**不透明类型**。

不透明类型是隐藏类型信息的抽象类型，其底层的具体类型不可动态改变。

初次接触 SwiftUI 的读者会看到这样的代码：

```swift
var body: some View {
  Text("Hello")
}
```

`body` 是不透明类型 `some View`，调用者只知其是一个遵循 `View` 协议的抽象类型，却不知其底层的具体类型（`Text`），因为不透明类型对调用者隐藏了类型信息。

这里的”不可见“是对调用者而言的，而编译器具有”透视“视角，它能够在编译期获取到不透明类型底层的具体类型（`Text`），并确保其底层类型是静态的。

如果在 `body` 内这样写：

```swift
Bool.random() ? Text("Hello") : Image(systemName: "swift")
```

编译器能够诊断出 `Text` 和 `Image` 是不同的类型，因而抛出错误。假设 `body` 内部可以动态地改变其底层的具体类型，这意味着更多的内存占用和复杂计算，这会导致程序的性能损耗。

基于以上特性，不透明类型非常适合在模块之间调用，它可以保护类型信息为私有状态而不被暴露，而编译器能够访问类型信息并作出优化工作。

不透明类型受实现者约束，这和泛型受调用者约束是相反的。因此，不透明类型又被称为**反向泛型**。比如下面的代码：

```swift
func build1<V: View>(_ v: V) -> V {
  v
}
// v1 is Text
let v1 = build1(Text("Hello"))

func build2() -> some View {
  Text("Hello")
}
// v2 is View
let v2 = build2()
```

调用 `build1` 时就需要指定具体类型，此处入参为 `Text` 类型，因此 `v1` 的类型也是 `Text`。

`build2` 返回的具体类型由内部实现决定，这里返回的是 `Text` 类型。鉴于不透明类型对调用者隐藏了类型信息，因此 `v2` 的类型在编译期是 `View`，在运行时是 `Text`。

# 更优雅的泛型

下面的代码用于比较两个集合，如果所有元素相同，返回 true。

```swift
func compare<C1: Collection, C2: Collection>(_ c1: C1, _ c2: C2) -> Bool
where C1.Element == C2.Element, C1.Element: Equatable {
  if c1.count != c2.count { return false }
  for i in 0..<c1.count {
    let v1 = c1[c1.index(c1.startIndex, offsetBy: i)]
    let v2 = c2[c2.index(c2.startIndex, offsetBy: i)]
    if v1 != v2 {
      return false
    }
  }
  return true
}

let c1: [Int] = [1, 2, 3]
let c2: Set<Int> = [1, 2, 3]
let ans = compare(c1, c2) // true
```

这里使用泛型约束保证 `C1` 和 `C2` 是集合类型，使用 `where` 分句确保二者的关联类型 `Element` 是能够判等的相同类型。功能虽已实现，但写起来非常繁琐，也不利于阅读。那么，该如何简化呢？

在简化之前，先来看看 Swift 5.7 新增的两个新特性：

1. 使用范围更广的不透明类型

   此前，不透明类型只能用于返回值。现在，我们还可以将其用于属性、下标以及函数参数。

2. 主要关联类型

   协议支持多个关联类型，使用尖括号声明（类似泛型写法）的则是主要关联类型。

   如下 `Collection` 协议中的 `Element`，就是主要关联类型。

   借助这一特性，在使用具有关联类型的协议时，写法可以非常简洁。比如上面的 `where` 分句，我们可以简写成 `Collection<Equatable>`。

   ```swift
   public protocol Collection<Element> : Sequence {
     
     associatedtype Element
     associatedtype Iterator = IndexingIterator<Self>
     ...
   }
   ```

将以上两点结合起来，更优雅的写法如下：

```swift
func compare<E: Equatable>(_ c1: some Collection<E>, _ c2: some Collection<E>) -> Bool {
  ...
}
```

`c1` 和 `c2` 可以是任意集合类型，如果没有使用 `some` 标记，它就是下文提到的存在类型，编译器会提示使用 `any` 修饰。但这里将其声明为不透明类型，基于以下两点：

1. 旧函数在调用时就已经确定了入参的具体类型，这和 `any` 的表达的意思有悖。
2. 此处的不透明类型并没有用作返回值，只是在函数被调用时的入参，其具体类型是固定的，没有必要使用 `any`，这和旧函数表达的意图一致。

仔细对比两个函数，能够发现：`some P` 和 `T where T: P` 表达的意思其实是一样的。如果 `P` 带有关联类型 `E`，那么 `T where T: P, T.E: V` 可以简写为 `some P<V>`。

# 存在类型、any 关键字

`any` 关键字由 Swift 5.6 引入，它用来修饰**存在类型**：一个能够容纳任意遵循某个协议的的具体类型的容器类型**。**

我们结合下面的代码来理解这段抽象的描述：

```swift
protocol P {}

struct CP1: P {}
struct CP2: P {}

func f1(_ p: any P) -> any P {
  p
}

func f2<V: P>(_ p: V) -> V {
  p
}
```

`f1` 中的 `p` 及其返回值都是存在类型，只要是遵循协议 `P` 的类型实例都是合法的。

`f2` 中的 `p` 及其返回值都不是存在类型，而是遵循协议 `P` 的某个**具体类型**。

在编译期间，`f1` 中 `p` 是存在类型（`any P`），它将 `p` 底层的具体类型包装在一个“容器”中。而在运行时，从容器中取出内容物才能得知 `p` 底层的具体类型。`p` 的类型可被任何遵循协议 `P` 的某个具体类型进行替换，因此存在类型具有**动态分发**的特性。

比如下面的代码：

```swift
func f3() -> any P {
  Bool.random() ? CP1() : CP2()
}
```

`f3` 的返回类型在编译期间是存在类型 `any P`，但是在运行期间的具体类型是 `CP1` 或 `CP2`。

而 `f2` 中的 `p` 没有被“容器”包装，无需进行装箱、拆箱操作。由于泛型的约束，当我们调用该方法时，就已经确定了它的具体类型。无论是编译期还是运行时，它的类型都是具体的，这又称为**静态分发**。比如这样调用时：`f2(CP1())` ，入参和返回值类型都就已经固化为 `CP1`，在编译期和运行时都保持为该具体类型。

因为动态分发会带来一定的性能损耗，因此 Swift 引入了 `any` 关键字来向我们警示存在类型的负面影响，我们应该尽量避免使用它。

上面的示例代码不使用 `any` 关键字还能通过编译，但从 Swift 6 开始，当我们使用存在类型时，编译器会强制要求使用 `any` 关键字标记，否则会报错。

在实际开发中，推荐优先使用泛型和 `some`，尽可能地避免使用 `any`，除非你真的需要一个动态的类型。

------

*文中涉及源码参考：[Source code](https://github.com/zzzwco/resources/blob/main/Swift-language/any-some/main.swift)。*
