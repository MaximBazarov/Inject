# ``Inject``

Effortless modular dependency injection for Swift.

Inject utilizes the power of the [KeyPath](https://developer.apple.com/documentation/swift/keypath) feature of swift, to identify dependencies.
Which allows you to define default instances without a need to have a single shared object to register them.   
As well as compile time check of the dependency graph integrity.

And [structured concurrency feature](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to make it thread-safe.

It also allows you to mark an injection point wherever you can have a variable without any burden to validate the dependency graph.

For an old component that uses initializer injection, 
a property injection, a shared instance, or has no injection at all. 
It takes you a couple of lines of changes to switch it to Inject.   
Or back, for what it's worth.

## Enabling injection
To enable the injection of a value, you need two things:
- Declare a dependency default value by extending the ``DefaultValues``.
```swift
extension DefaultValues {
    var networking: NetworkingInterface { Networking() }
}
```
- Mark the variable where you need the injection as ``Injected`` 
and point it to the variable you just added into ``DefaultValues``.
```
final class MyAwesomeComponent: Injectable {
    @Injected(\.networking) var network
}
```

> Note: `MyAwesomeComponent` was marked by empty `Injectable` protocol, 
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

## Advanced

By default, all the dependencies are **providing a new instance** (`.temporary`)
and **for each injection point** (`.local`) 
and deallocated once an injection point is deallocated.
```swift
@Injected(\.networking, .temporary, .local) var network
```

But you can alter it with `.shared` ``Dependency/Scope`` to provide the same instance to all consumers with `.shared` ``Dependency/Scope`` preferred.
Also, you can configure a `.permanent` ``Lifespan`` to hold it until the termination of the app.

## Topics

### Essential

- ``DefaultValues``
- ``Injected``
- ``Injectable/injecting(_:for:)``

