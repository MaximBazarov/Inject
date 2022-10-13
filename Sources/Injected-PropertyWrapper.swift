//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Decore package open source project
//
// Copyright (c) 2020-2022 Maxim Bazarov and the Decore package
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

/// An injected property that provides an ``Dependency/instance``
/// based on configuration.
///
/// To define an injection point anywhere in your app:
/// ```swift
/// final class MyAwesomeView: Injectable {
///     @Injected(\.testService) var service
/// }
/// ```
/// Then you can access the `testService` instance in your code
/// by using ``Dependency/instance`` computed property.
/// ```swift
/// service.instance.doSomething()
/// ```
/// Depending on the ``Dependency/Scope`` and ``Lifespan``
/// provided it will be the new or shared instance.
@MainActor
@propertyWrapper
public final
class Injected<Value> {
    private let dependency: Dependency<Value>
    
    public var wrappedValue: Dependency<Value> {
        get { dependency }
    }
    
    /// Returns a ``Dependency`` configured with given
    /// ``Dependency/Scope`` and ``Lifespan``.
    ///
    /// - Parameters:
    ///   - keyPath: keyPath in the ``DefaultValues``
    ///   - lifespan: ``Lifespan`` **`.temporary`** by default.
    ///   - scope: ``Dependency/Scope`` **`.local`** by default.
    public init(
        _ keyPath: DefaultValues.KeyPath<Value>,
        lifespan: Lifespan = .temporary,
        scope: Scope = .local
    ) {
        self.dependency = Dependency(keyPath, lifespan: lifespan, scope: scope)
    }
}

