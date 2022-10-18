//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Inject package
// open source project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//

import Foundation

// MARK: - Public interface
extension Dependency {
    /// An instance of the dependency.
    public var instance: Value {
        if let localValue { return localValue }
        
        let newInstance = getInstance()
        
        if case .local = scope { localValue = newInstance }
        
        return newInstance
    }
}

// MARK: - Dependency<Value>
/// A type that represents a dependency with given ``Scope`` and ``Lifespan``.
///
/// When you use
/// ```swift
/// final class MyAwesomeComponent: Injectable {
///     @Injected(\.someServiceKey, .temporary, .local) var service
/// }
/// ```
/// `service` variable is of type ``Dependency``.
/// The instance itself, using ``Dependency/instance``
/// is of type `someServiceKey` in ``DefaultValues`` is e.g.
/// `SomeServiceInterface` protocol.
///
/// ``Injectable`` marks the class to tell the compiler
/// it has ``Injectable/injecting(_:for:)`` function.
///
/// ## Scope and Lifespan configuration
///
/// **`.temporary`** is the configuration of the ``Lifespan`` meaning
/// we don't want to hold the instance of this service once we are done.
///
/// **`.local`** is the ``Scope`` of the injection,
/// which means we want our personal instance to be provided,
/// not the one that is shared with others.
///
/// _You can omit both `.temporary` and `.local` since these are_
/// _the default values for the configuration._
/// ```swift
/// final class MyAwesomeComponent: Injectable {
///     @Injected(\.someServiceKey) var service
/// }
/// ```
///
/// Now you can access your instance using the ``Dependency/instance`` computed property.
/// ```swift
/// func do() {
///     service.instance.doWork()
/// }
/// ```
///
/// ## Injecting
/// To inject another than production instance in your tests or previews
/// or anywhere else:
/// ```swift
/// let component = MyAwesomeComponent()
///    .injecting(
///        SomeMock(), // injected instance
///        for: \.service
///    )
/// // component.service.instance is the injected instance that we provided.
/// ```
///
/// Note that we use the `KeyPath` to the variable in `MyAwesomeComponent` and
/// not in the ``DefaultValues`` that's because we want to inject only
/// for `MyAwesomeComponent` without affecting other consumers of the service.
///
@MainActor
public final class Dependency<Value> {
    typealias StorageKeyPath = DefaultValues.KeyPath<Value>
    
    private let storageKeyPath: StorageKeyPath
    
    private lazy var key = DependencyKey(
        id: ObjectIdentifier(self),
        keyPath: ObjectIdentifier(storageKeyPath)
    )
    private let scope: Scope
    private let lifespan: Lifespan
    private var localValue: Value?
    
    init(
        _ storageKeyPath: StorageKeyPath,
        lifespan: Lifespan = .temporary,
        scope: Scope = .local
    ) {
        self.storageKeyPath = storageKeyPath
        self.lifespan = lifespan
        self.scope = scope
    }


    /// Overrides the injected value.
    /// New value will be the one that is returned for ``instance``
    public func override(with value: Value) {
        localValue = value
    }
    
    func getInstance() -> Value {
        switch (lifespan, scope) {
        case (.permanent, .shared):
            return DefaultValues.permanentInstance(for: storageKeyPath)
        case (.permanent, .local):
            return DefaultValues.permanentInstance(for: storageKeyPath, scopedTo: key)
        case (.temporary, .shared):
            return DefaultValues.temporaryInstance(for: storageKeyPath)
        case (.temporary, .local):
            return DefaultValues()[keyPath: storageKeyPath]
        }
    }
}

