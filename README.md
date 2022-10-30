# *Inject* 
Effortless modular dependency injection for Swift.

[![Unit Tests](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml/badge.svg?event=push)](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaximBazarov%2FInject%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/MaximBazarov/Inject)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaximBazarov%2FInject%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/MaximBazarov/Inject)

___

Sometimes during the app development process we need to replace instances of classes or actors we use in production code with instances that emulate their work e.g. tests, SwiftUI previews, demo apps etc. 

Ususally that requires additional changes in the code that in turn opens up a whole new layer of errors. handling of theese errors is on your shoulders.

Inject lets you express your intent in a way that enables compile-time checking that you have all the instances required for the production. 
At the same time it let's you replace the instance on any object with a single line of code. 


## How to Use
Here's an example of a class that needs networking and parser instances to fetch items from the server:
```swift
final class BackendSDK {

    @Injected(\.networking) var network
    @Injected(\.parser) var parser

    func fetchItems() async throws -> [Item] {
        guard let url = URL(string: baseURL + "/items")
        else { throw InvalidURL() }
        let data = try await network.instance.fetch(url)
        return try await parser.instance.parse(data, as: [Item].self)
    }
}
```

And here's an example of replacing one of the services with a mock in SwiftUI preview:

```swift

struct SomeView: View {
    @Injected(\.networking) var network
    ...
}

extension SomeView: Injectable {}

struct SomeView_Previews: PreviewProvider {
    static var previews: some View {
        SomeView()
            .injecting(MockNetworking(), for: \.network)
    }
}
```

With this convenient property wrapper `@Injected` you define a dependency requirement in a declarative way:
- `\.networking` is the `KeyPath` to the instance to be obtained at [`\DefaultValues.networking`. ](#default-values)
 
- `network` is the name of our injection point that we use to inject in preview `.injecting(MockNetworking(), for: \.network)`.
It behaves just like a normal variable would, with one exception, instead of providing an instance it provides a `Dependency<T>` wrapper, that has a computed property `.instance` to obtain an actual instance of type `T`.

- **MockNetworking** - A class that we use only in tests or previews, that might simulate the network.

- Note: *We have to mark our view with an empty protocol `Injectable` to enable the `injecting(_:_:)` function.*

**That's it, you are done with dependency injection without a need to know what exactly that is.**


The only thing that is missing is to tell the compiler what are the default values for our `\.networking` and `\.parser` dependencies. And that's where `DefaultValues` come in handy.

## Default Values

**Unlike other popular solutions Inject doesn't have a container** instead it provides you with a `DefaultValues` class to extend with computed properties.

**You never need to create an instance of this class**, all you need to do is to extend it with the variable of the type of the dependency it represents and return a default implementation for it:

```swift
extension DefaultValues {
    /// Default instance for Networking
    var networking: Networking {
        HTTPNetworking()
    }

    /// Default instance for Parser
    var parser: Parser {
        JSONParser()
    }
}
```

If you noticed `networking` and `parser` are the names we referred to earlier.

## Dependency configuration

You might wonder, what is the lifespan of the instances provided? Do they stay in memory forever like singletons or they are destroyed when the object that has them `@Injected` is destroyed? 

And what is the scope, are all instances for all classes the same, or each class will have a new instance for its `@Injected`?

The answer is, by default, all the instances are created for each `@Injected` and are destroyed once the object that holds `@Injected` is destroyed.

But you can change that with the `Scope` and `Lifespan`, default values would be:

```swift
@Injected(\.networking, scope: .local, lifespan: .temporary) var network
```

here are the possible values:

### Scope

- `.local` - new instance for each `@Injected`
- `.shared` - same instance for all `@Injected`

### Lifespan

- `.permanent` - instance stays till the app is deallocated.
- `.temporary` - instance deallocated when the **last** `@Injected` referencing it is deallocated.

## Why yet another DI framework?

This is the question I asked the most.

Here are some of the reasons to try *Inject* and decide for yourself:

- Thread safety using `@MainActor`
- Inject doesn't resolve instances using a container, it doesn't have a container in the first place. Which is a huge advantage over other popular DI solutions for which it is the biggest bottleneck.
- Compile-time check that all the instances provided, which removes a whole layer of errors.
- Inject's API operates simple concepts like instance, injection/replacement, scope, and lifespan.
- It's extremely modular, you one-line it anywhere you want.

There is much more than that, I will soon provide a couple of examples using inject in the app and in another library to showcase how powerful and flexible Inject is.

Meanwhile, it's a good candidate for you to try and make your dependency injection a breeze.


# Installation

Adding the dependency

Inject is designed for Swift 5. To depend on the Inject package, you need to declare your dependency in your Package.swift:

```swift
.package(url: "https://github.com/MaximBazarov/Inject.git", from: "1.0.0")
```



