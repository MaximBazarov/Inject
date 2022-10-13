# *Inject* 
Effortless modular dependency injection for Swift.

[![Unit Tests](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml/badge.svg?event=push)](https://github.com/MaximBazarov/Inject/actions/workflows/swift-build-test.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaximBazarov%2FInject%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/MaximBazarov/Inject)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMaximBazarov%2FInject%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/MaximBazarov/Inject)

___

Sometimes during the app development process we need to replace instances of classes or actors we use in production code with instances that emulate their work e.g. tests, SwiftUI previews, demo apps etc. 

Ususally that requires additional changes in the code that in turn opens up a whole new layer of errors. handlinge of theese errors is on your shoulders.

Inject lets you express your intent in a way that enables compile-time checking that you have all the instances required for the production. 
At the same time it let's you replace the instance on any object with a single line of code. 

## Usage

A very common problem would be `Image` like component, that takes an `URL` as a parameter instead of an image. For this we would need two parts:

A downloader, with code something like:
```swift
protocol DownloaderInterface {
    func downloadImage(url: URL) async throws -> UIImage
}

actor URLSessionDownloader: DownloaderInterface {
    func downloadImage(url: URL) async throws -> UIImage {
        // URLSession/dataTask ...
    }
}
```

and a component itself

```swift
struct RemoteImage: View, Injectable {
    private var downloader = URLSessionDownloader()
    @State private var image: UIImage?

    let url: URL

    var body: some View {
        Image(uiImage: image ?? placeholder)
            .resizable()
            .frame(width: 200, height: 200)
            .onAppear {
                downloadImage()
            }
    }

    func downloadImage() {
        Task { [url] in
            self.image = try? await downloader.instance.downloadImage(url: url)
        }
    }
}
```

I used SwiftUI here for simplicity, Inject doesn't require anything but `Swift 5.7`.

Now the first problem is preview, now it will need an actual `URL` and a network connection, which is not what we want.

To enable injection we need to tell the compiler that we use `URLSessionDownloader` as a default instance for the protocol `DownloaderInterface`:

```swift
import Inject

extension DefaultValues {
    var imageDownloader: DownloaderInterface { URLSessionDownloader() }
}
```

We also can now refer to it with a `KeyPath` `\DefaultValues.imageDownloader` which is very handy since we would need to replace it once if we changed from `URLSession` to something else.

That's all we need to use the instance in our view:

```swift
import Inject

struct RemoteImage: View, Injectable {
    @Injected(\.imageDownloader) var downloader
```

We have to mark our view as `Injectable` which is an empty protocol enabling the `injecting(_:_:)` function. And tell which instance we need, `\.imageDownloader` is a short syntax for `\.DefaultValues.imageDownloader`.

Now in our preview, we can easily replace the production instance of the downloader with our mock that provides a static test image, error, and other cases we want to test.

```swift
actor MockDownloader: DownloaderInterface {
    func downloadImage(url: URL) async throws -> UIImage {
        return testImage
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: tesImageURL)
            .injecting(MockDownloader(), for: \.downloader)
    }
}
```

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

## Why yet another DI framework?
This is the question I asked the most and I share your frustration with other DI solutions. 
In fact that's the very reason Inject was created. 

Here are some of the reasons, and I'm not saying you should use Inject. 
I'm saying you have to try it and decide for yourself and that's why:

- Thread safety using `@MainActor`
- Inject doesn't introduce a container instance. 
- No need to register instance in a container, defininition of a compoted property with the instance instead. 
- Compile-time check that all the instances provided, which removes a whole layer of errors.
- Inject's API operates simple concepts like instance, injection/replacement, scope and lifetime.
- Enables you to keep your code modular for free.

I believe all that makes it a good candidate to try and make your opinion.

