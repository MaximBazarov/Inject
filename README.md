# *Inject* 
Effortless modular dependency injection for Swift.

[![Unit Tests](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml/badge.svg?event=push)](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaximBazarov%2FInject%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/MaximBazarov/Inject)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaximBazarov%2FInject%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/MaximBazarov/Inject)

___

Effortless modular dependency injection for Swift.

Inject is an opinionated approach to dependency inversion, aiming to make dependency injection in Swift projects effortless and error-free. It allows you to invert dependencies in your application to the degree that you can freely move injection points across your modules without any issues. Inject's API is focused on simplicity and modularity while ensuring thread safety with @MainActor.

## Features

- Thread safety using @MainActor
- Simple, modular, and flexible API
- Compile-time checks for provided instances, eliminating an entire layer of errors
- Supports shared, singleton and on demand [injection strategies](#strategies)


# Usage

Consider a protocol Service with a function doWork. This service is extracted into the Service package, along with its current implementation, ServiceImplementation.

```swift
// ServicePackage
public protocol Service {
    func doWork()
}

public final class ServiceImplementation: Service {
   func doWork() { ... }
}
```

In your application, you want to use ServiceImplementation but have the option to replace it with a mock implementation for tests or previews. To do this, you need to publish the injection of the implementation:

```swift
@MainActor public let serviceShared = Injection<Service>(
    strategy: .shared, 
    instance: ServiceImplementation()
)
```

This creates an injection point that instantiates ServiceImplementation once and deallocates it once no one is using the instance.

To use it in your app, you need the `Instance` property wrapper:

```swift
import ServicePackage

@Instance(ServicePackage.serviceShared) var service

... 
   {
      service.doWork()
   }
}
```

Anywhere you import the package that published the Injection, you can have the appropriate instance of the dependency.

## Strategies

In the new version of Inject, there are three strategies available for managing dependency injection:

**Shared:** This strategy creates a shared instance that is reused across all objects using the dependency. The instance will be deallocated when the last object referencing it is deallocated.

```swift
@MainActor let sharedDependency = Injection<DependencyType>(
    strategy: .shared,
    instance: DependencyImplementation()
)
```

**Singleton:** This strategy creates a shared instance that is reused across all objects using the dependency. The instance will remain in memory until the app is terminated.

```swift
@MainActor let singletonDependency = Injection<DependencyType>(
    strategy: .singleton,
    instance: DependencyImplementation()
)
```

**On Demand:** This strategy creates a new instance for each object using the dependency. Each instance will be deallocated when the object that holds the dependency is deallocated.

```swift
@MainActor let onDemandDependency = Injection<DependencyType>(
    strategy: .onDemand,
    instance: DependencyImplementation()
)
```

Choose the appropriate strategy based on your specific use case and requirements for dependency management.

# Overriding

There are two cases for overriding dependencies:

## Global override

Use global override when you have multiple implementations and want to use different instances depending on the target. In this case, you can globally override the injection with a new strategy, instance, or injection.

```swift
// Overriding the instance
ServicePackage.serviceShared.override(with: { _ in MockService() })

// Overriding the instance and strategy
PackageA.sharedService.override(with: { _ in MockService() }, strategy: .onDemand)

// Overriding the instance and strategy, using the instance provided before override
PackageA.sharedService.override(
    with: { service in
        service.setKey("someapikey")
        return service
    }, 
    strategy: .onDemand
)

// Overriding with another injection
@MainActor public let serviceLocal = Injection<Service>(strategy: .onDemand, instance: ServiceImplementation())

PackageA.sharedService.override(with: serviceLocal)
```

In your tests, you can also **rollback** the override when you're done testing:

```swift
func test_Override_WithInjection_Rollback_Global() {
        var sut = Consumer()
        let override = Injection<PackageA.Service>(strategy: .shared, instance: self.testInjection)
        PackageA.sharedService.override(with: override)

        XCTAssertEqual(sut.perform(), "test")

        XCTAssertEqual(ObjectIdentifier(sut.service), ObjectIdentifier(testInjection))

        PackageA.sharedService.rollbackOverride()
        sut = Consumer()
        XCTAssertNotEqual(ObjectIdentifier(sut.service), ObjectIdentifier(testInjection))
    }
```

## Local override

You can also directly override the dependency for the instance only, by directly assigning the override:

```swift
import ServicePackage
class Consumer {
    @Instance(ServicePackage.serviceShared) var service
    
    func perform() -> String {
       service.doWork()
    }
}

func test_Override_Local() {
        let sut = Consumer()
        sut.service = MockService()

        // now MockService will be used by consumer
        XCTAssertEqual(sut.perform(), "test")
}
```


# Installation

Adding the dependency

Inject is designed for Swift 5. To depend on the Inject package, you need to declare your dependency in your Package.swift:

```swift
.package(url: "https://github.com/MaximBazarov/Inject.git", from: "1.0.0")
```

# Deprecation Notice and Migration Guide

Inject 1.0.0 is now deprecated. We made a mistake by placing the injection configuration on the consumer side with @Injected. This approach leads to moving the responsibility of injection onto the client, which doesn't make sense because you would have to synchronize all the injections on your own. If you use this approach, move the configuration to the injection. Replace @Injected property wrappers with @Instance and reference the appropriate published Injection:

**For example, if you had:**

```swift
extension DefaultValues {
    var networking: Networking {
        HTTPNetworking()
    }
}
...
@Injected(\.networking, scope: .local, lifespan: .temporary) var network
```

**Change it to:**

```swift
// next to the implementation
@MainActor let networking = Injection<Networking>(
    strategy: .onDemand,
    instance: NetworkingImplementation()
)

...

// usage
@Instance(networking) var network
```

This way, you can have a single source of truth for the injection configuration.

There are three new strategies and their respective scope and lifetime:

- `.shared`: scope: `.shared`, lifespan: `.temporary`
- `.singleton`: scope: `.shared`, lifespan: `.permanent`
- `.onDemand`: scope: `.local`, lifespan: `.temporary`

Please review and adjust your code according to these updated strategies and scopes.
