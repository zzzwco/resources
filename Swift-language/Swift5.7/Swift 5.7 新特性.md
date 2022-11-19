<br>

`2022/07/15` ` Xcode 14 beta 3`  ` Swift 5.7`

# 简化的可选绑定（[SE-0345](https://github.com/apple/swift-evolution/blob/main/proposals/0345-if-let-shorthand.md)）

对可选类型解包时无需显式绑定，写法更简洁：

```swift
let s1: String? = "s1"

if let s1 {
  print(s1)
}

guard let s1 else {
  exit(0)
}
print(s1)
```

# 更强大的类型推断

## 默认表达式的类型推断（[SE-0347](https://github.com/apple/swift-evolution/blob/main/proposals/0347-type-inference-from-default-exprs.md)）

Swift 现在支持给泛型参数赋予默认值，并且能根据上下文推断泛型参数的具体类型。

```swift
func compute<C: Collection>(_ values: C = [0, 1, 2]) { }

compute([1, 2, 3]) // [Int]
compute(["a", "b", "c"]) // [String]
compute([1, "2", {}]) // [Any]
```

## 多语句闭包的类型推断（[SE-0326](https://github.com/apple/swift-evolution/blob/main/proposals/0326-extending-multi-statement-closure-inference.md)）

以前的多语句闭包必须写明参数和返回值类型：

```swift
let _ = [-1, 0, 1].map { v -> String in
  if v < 0 {
    return "negative"
  } else if v > 0 {
    return "positive"
  } else {
    return "zero"
  }
}
```

现在，编译器会自动推断：

```swift
let _ = [-1, 0, 1].map {
  if $0 < 0 {
    return "negative"
  } else if $0 > 0 {
    return "positive"
  } else {
    return "zero"
  }
}
```

# 更灵活的正则表达式

## 正则类型（[SE-0350](https://github.com/apple/swift-evolution/blob/main/proposals/0350-regex-type-overview.md)）

Swift 5.7 新增了正则类型 `Regex<Output>`，用于便捷地构建正则表达式。

```swift
let s = "Stay hungry, stay foolish."
let regex1 = try! Regex("[Ss]tay")
let matches1 = s.matches(of: regex1)
for match in matches1 {
  let l = match.range.lowerBound
  let r = match.range.upperBound
  printLog(s[l..<r])
}
```

## 正则构造器 DSL（[SE-0351](https://github.com/apple/swift-evolution/blob/main/proposals/0351-regex-builder.md#regex-builder-dsl)）

正则表达式简洁有力，但难以书写。因此 Swift 提供了 DSL 供我们使用，便于方便地书写正则表达式。比如下面示例代码中的 `OneOrMore(.word)` 表达的意思和 `/[A-Za-z0-9]+/` 是一样的。

```swift
**import RegexBuilder**

let regex2 = Regex {
  "Stay "
  Capture {
    OneOrMore(.word) // matches2.1
  }
  ", stay "
  Capture {
    OneOrMore(.word) // matches2.2
  }
  "."
}
if let matches2 = try regex2.wholeMatch(in: s) {
  // matches2.0 是整个匹配的字符串
  printLog(matches2.0, matches2.1, matches2.2)
}
```

Regex 还支持使用别名和下标来获取匹配结果：

```swift
let ref1 = Reference(Substring.self)
let ref2 = Reference(Substring.self)
let regex3 = Regex {
  "Stay "
  Capture(as: ref1) { // res[ref1]
    OneOrMore(.word)
  }
  ", stay "
  Capture(as: ref2) { // res[ref2]
    OneOrMore(.word)
  }
  "."
}
if let matches3 = try regex3.wholeMatch(in: s) {
  printLog(matches3[ref1], matches3[ref2])
}
```

另外，RegexBuilder 中的 [buildPartialBlock](https://github.com/apple/swift-evolution/blob/main/proposals/0348-buildpartialblock.md) 实现了基于结果生成器的重载。这是 SwiftUI 喜闻乐见的，因为此前的 [ViewBuilder](https://developer.apple.com/documentation/swiftui/viewbuilder) 最多只能从 10 个子 view 构建，但 `buildPartialBlock` 可以突破这个限制。这和 `reduce` 函数有点类似，在前一个生成的结果基础上，继续累积新的值。

更多相关 API 请查看：[RegexBuilder](https://developer.apple.com/documentation/RegexBuilder)。

## 正则字面量（[SE-0354](https://github.com/apple/swift-evolution/blob/main/proposals/0354-regex-literals.md)）

Swift 支持使用字面量直接构建正则表达式，构建方式非常简单，只需要将表达式置于两个 `/` 之间：

```swift
let regex4 = /[Ss]tay/
let matches4 = s.matches(of: regex4)
for match in matches4 {
  let l = match.range.lowerBound
  let r = match.range.upperBound
  printLog(s[l..<r])
}
```

字面量构建的正则表达式同样支持使用别名对匹配结果进行引用：

```swift
let regex5 = /Stay (?<s1>.+), stay (?<s2>[A-Za-z0-9]+)./
if let matches5 = try regex5.wholeMatch(in: s) {
  printLog(matches5.s1, matches5.s2)
}
```

值得注意的是，基于字符串构建的 Regex 类型必须在运行时才能对该字符串进行正确解析。而**正则字面量在编译期就能被编译器诊断出错误**，这也是我们应该优先使用正则字面量的原因。下面是 Regex 类型和字面量结合使用的示例：

```swift
let regex6 = Regex {
  "Stay"
  Capture { // 空格使用使用\\转义
    /\\ .+/
  }
  ", stay"
  Capture {
    /\\ [A-Za-z0-9]+/
  }
  "."
}
if let matches6 = try regex6.wholeMatch(in: s) {
  printLog(matches6.1, matches6.2)
}
```

## 基于正则的字符串处理算法（[SE-0357](https://github.com/apple/swift-evolution/blob/main/proposals/0357-regex-string-processing-algorithms.md)）

除了上面提到的 `matches(of:)`、`wholeMatch(in:)`，Swift 中的集合类型许多原有的方法也提供了对 Regex 的支持。比如：

```swift
printLog(s.replacing(/[Ss]tay/, with: "be"))
printLog(s.contains(/\\ foo.+/)) 
```

# 阐明了非隔离异步函数的执行（[SE-0338](https://github.com/apple/swift-evolution/blob/main/proposals/0338-clarify-execution-non-actor-async.md)）

在此之前，在 `g` 中调用 `f` 时，`f` 可能会 actor 上执行并造成长时间的阻塞。

而现在所有的非隔离异步函数的执行，都会在全局的协作并发池上执行。当然，从 actor 切换至全局并发池执行时，程序依然会进行 `Sendable` 检查。比如，在 `g` 中调用 `f` 时，如果 c 没有实现 `Sendable`，编译器会发出警告。

```swift
class C { }

// 总是在全局的协作并发池上执行
func f(_: C) async { }

actor A {
  func g(c: C) async {
		// 总是在 actor 上执行
    print("on the actor")

    await f(c)
  }
}
```

# 新的时间 API （[SE-0329](https://github.com/apple/swift-evolution/blob/main/proposals/0329-clock-instant-duration.md)）

Swift 5.7 提供了一种新的标准化时间组件，由以下三部分组成：

- Clock：基于 Clock 协议实现，是一种计算时间的机制，定义了现在以及将来某个指定的时间点唤醒工作的方式。
- Instant：基于 [InstantProtocol](https://developer.apple.com/documentation/swift/instantprotocol?changes=latest_major&language=_5) 协议实现，表示某个时间点。
- [Duration](https://developer.apple.com/documentation/swift/duration?changes=latest_major&language=_5)：基于 [DurationProtocol](https://developer.apple.com/documentation/swift/durationprotocol?changes=latest_major&language=_5) 协议实现，表示两个时间点之间的间隔。

Clock 协议定义如下，其中的关联类型 `Instant` 遵循 `InstantProtocol` 协议，而另一个关联类型 `Duration` 和 `InstantProtocol` 协议中的 `Duration: DurationProtocol` 的类型保持一致：

```swift
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public protocol Clock : Sendable {

    associatedtype Duration where Self.Duration == Self.Instant.Duration

    associatedtype Instant : InstantProtocol

    var now: Self.Instant { get }

    var minimumResolution: Self.Duration { get }

    func sleep(until deadline: Self.Instant, tolerance: Self.Instant.Duration?) async throws
}
```

系统内置了两种 Clock：

- ContinuousClock：系统睡眠时，仍能计时。
- SuspendingClock：系统睡眠时，停止计时。

两种 Clock 使用方式一样，这里以 ContinuousClock 为例。比如用来计算某个同步操作的耗时：

```swift
let clock = ContinuousClock()
let elapsed = clock.measure {
  for _ in 0..<999999 {}
}
printLog("Loop duration: \\(elapsed)")
```

Clock 还能用来计算异步事件的耗时，Task 也新增了对 Clock 的支持：

```swift
func delayWork() async throws {
  // tolerance 为容差，默认为 nil
  // 这里表示任务会睡眠 0.5 至 1 秒
  let elapsed = try await clock.measure {
    try await Task.sleep(until: .now + .seconds(0.5), tolerance: .seconds(0.5), clock: .continuous)
  }
  printLog("Sleep duration: \\(elapsed)")
  printLog("Time is up, keep working...")
}

try await delayWork()
```

如果任务在睡眠时间结束前就结束了，会抛出 `CancellationError` 类型的错误。

# 不透明类型增强了使用范围（[SE-0341](https://github.com/apple/swift-evolution/blob/main/proposals/0341-opaque-parameters.md)）

此前，不透明类型只能用于返回值。现在，我们还可以将其用于属性、下标、函数参数以及结构化的返回类型（元组、数组、闭包等）。

```swift
func tuple(_ v1: some View, _ v2: some View) -> (some View, some View) {
  (v1, v2)
}
```

# 主要关联类型以及轻量级同类型要求（[SE-0346](https://github.com/apple/swift-evolution/blob/main/proposals/0346-light-weight-same-type-syntax.md)）

协议支持多个关联类型，使用尖括号声明（类似泛型写法）的则是主要关联类型。

我们来看看 `Collection` 协议最新的定义：

```swift
public protocol Collection<Element> : Sequence {
  
  associatedtype Element
  associatedtype Iterator = IndexingIterator<Self>
  ...
}
```

这里的 `Element`，就是主要关联类型。借助这一特性以及增强了使用范围的不透明类型，在使用具有主要关联类型的协议时，写法可以更优雅。比如下面这个用于比较两个集合的函数：

```swift
func compare<C1: Collection, C2: Collection>(_ c1: C1, _ c2: C2) -> Bool
where C1.Element == C2.Element, C1.Element: Equatable { }
```

可以写得更简洁易读：

```swift
func compare<E: Equatable>(_ c1: some Collection<E>, _ c2: some Collection<E>) -> Bool { }
```

实际上，以前类似的泛型写法 `T where T: P, T.E: V` 一般都可以简写为 `some P<V>`。

# 关于存在类型的改进

## 所有协议都可以作为存在类型使用（[SE-0309](https://github.com/apple/swift-evolution/blob/main/proposals/0309-unlock-existential-types-for-all-protocols.md)）

Swift 5.6 之前，我么经常遇到协议相关的编译错误：

```markdown
Protocol can only be used as a generic constraint because it has 'Self' or associated type requirements
```

通常我们的解决方法是将协议作为泛型约束来解决，Swift 5.6 为此引入了存在类型（一个能够容纳任意遵循某个协议的具体类型的容器类型），并新增了 `any` 关键字来进行标记。这一特性在 Swift 5.7 中全面解锁，所有的协议都可以使用 `any` 关键字来进行修饰。

值得注意的是，存在类型会导致性能损耗，`any` 关键字的主要作用其实是为了提醒我们它带来的潜在副作用，因此我们应该尽量避免使用它，除非你真的需要一个动态的类型。

## 隐式打开的存在的类型（[SE-0352](https://github.com/apple/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md)）

前面我们提到存在类型是一种容器类型，它只有在运行时才能将容器打开获取到内部的具体类型。这会导致如下的代码报错：

```swift
protocol P {
  associatedtype A
  func getA() -> A
}

func takeP<T: P>(_ value: T) { }

func test(p: any P) {
  // error: protocol 'P' as a type cannot conform to itself
  takeP(p)
}
```

因为泛型约束，`takeP` 在入参时需要传入一个实现协议 `P` 的具体类型。而 `test` 中的 `p` 是存在类型，它是一个容器类型，其内部的具体类型可以动态改变，并且只有在运行时才能获取到真正的具体类型。所以，我们会看到如上的编译错误。

但现在这个错误不存在了，Swift 赋予了存在类型隐式打开的特性。在 `test` 中将 `p` 传入 `takeP` 时，`p` 容器内部的具体类型会被自动取出，然后被传递至 `takeP` 函数。这个自动拆箱的过程，有点类似可选类型中的隐式解包。

## 受约束的存在类型（[SE-0353](https://github.com/apple/swift-evolution/blob/main/proposals/0353-constrained-existential-types.md)）

具有主要关联类型的协议可以用于存在类型，通过主要关联类型对其进行约束。

比如我们将某个包含整数的集合转换称数组类型：

```swift
func mapNumbers(_ c: any Collection<Int>) -> [Int] {
  c.map { $0 }
}
```

# 分布式 actor

分布式 actor 主要用于服务端，有兴趣的读者可以参考：[SE-0336](https://github.com/apple/swift-evolution/blob/main/proposals/0336-distributed-actor-isolation.md)、[SE-0344](https://github.com/apple/swift-evolution/blob/main/proposals/0344-distributed-actor-runtime.md)。

------

*本文仅是抛砖引玉，关于 Swift 5.7 更详细的变更请参考： [Swift/CHANGELOG.md](https://github.com/apple/swift/blob/main/CHANGELOG.md)*

*文中涉及源码参考：[Source code](https://github.com/zzzwco/resources/blob/main/Swift-language/Swift5.7/main.swift)。*
