//===----------------------------------------------------------------------===//
//
// This source file is part of the Decide package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Decide package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

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
/// Depending on the ``Scope`` and ``Lifespan``
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
    /// ``Scope`` and ``Lifespan``.
    ///
    /// - Parameters:
    ///   - keyPath: keyPath in the ``DefaultValues``
    ///   - lifespan: ``Lifespan`` **`.temporary`** by default.
    ///   - scope: ``Scope`` **`.local`** by default.
    public init(
        _ keyPath: DefaultValues.KeyPath<Value>,
        lifespan: Lifespan = .temporary,
        scope: Scope = .local
    ) {
        self.dependency = Dependency(keyPath, lifespan: lifespan, scope: scope)
    }
}
