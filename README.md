# *Inject* 
Effortless modular dependency injection for Swift.

[![Unit Tests](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml/badge.svg?event=push)](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml)

___

## Getting started
To enable the injection of a value, you need two things:
- Declare a dependency default value by extending the ``DefaultValues``.
```swift
extension DefaultValues {
    var networking: NetworkingInterface { Networking() }
}
```
- Mark the variable where you need the injection as ``Injected`` 
and point it to the variable you just added into ``DefaultValues``.
```swift
final class MyAwesomeComponent: Injectable {
    @Injected(\.networking) var network
}
```

> Note: `MyAvesomeComponent` was marked by empty `Injectable` protocol, 
it tells the compiler that this class has ``Injectable/injecting(_:for:)`` 
function.  

## Injection

In your code, you don't have to do anything else to make sure the injection works.
You can inject any instance of an appropriate type into this place in your code.
```swift
let component = MyAwesomeComponent()
    .injecting(ServiceMock(), for: \.network)
```
now the instance provided to the `network`  inside the `component` will be 
the `ServiceMock()` we provided and not `Networking()` as defined in the ``DefaultValues``

## Dependency Scope and Lifetime 

By default, all the dependencies are **providing a new instance** (`.temporary`)
and **for each injection point** (`.local`) 
and deallocated once an injection point is deallocated.
```swift
@Injected(\.networking, .temporary, .local) var network
```

But you can alter it with `.shared` ``Dependency/Scope`` to provide the same instance to all consumers with `.shared` ``Dependency/Scope`` preferred.
Also, you can configure a `.permanent` ``Lifespan`` to hold it until the termination of the app.

# Installation

Adding the dependency

Inject is designed for Swift 5. To depend on the Inject package, you need to declare your dependency in your Package.swift:

```swift
.package(url: "https://github.com/MaximBazarov/Inject.git", from: "1.0.0")
```

## Concurency

## Performance

Inject utilizes the power of the [KeyPath](https://developer.apple.com/documentation/swift/keypath) feature of swift, to identify dependencies.
Which allows you to define default instances without a need to have a single shared object to register them.
As well as compile time check of the dependency graph integrity.

And [structured concurrency feature](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to make it thread-safe.

It also allows you to mark an injection point wherever you can have a variable without any burden to validate the dependency graph.

For an old component that uses initializer injection, 
a property injection, a shared instance, or has no injection at all. 
It takes you a couple of lines of changes to switch it to Inject. 
Or back, for what it's worth.

## Why yet another DI framework?
This is the question I asked the most and I share your frustration with other DI solutions. 
In fact that's the very reason Inject was created. 

Here are some of the reasons, and I'm not saying you should use Inject. 
I'm saying you have to try it and decide for yourself and that's why:

- Thread safety and [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- Inject doesn't introduce a container instance. Meaning you don't have to pass it around or create ways to have it without passing it around. (Good case for Inject btw.)
- Declarative API. You don't register dependencies, you declare a default instance instead. 
- Which is a compile-time check and not a runtime crash in case of a failure.
- Inject's API is much simpler to comprehend for anyone familiar with variables since it's only 
  - default value
  - which variable is injected
  - and injection itself
  - and on the instance, you need it not on the container or something else.
- it allows modularity since you can extend the default values structure anywhere you want.

All that makes it a good candidate to try and make your opinion.

