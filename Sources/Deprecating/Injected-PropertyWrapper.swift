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

@available(*, deprecated, message: "This api isn't available, please refer to Readme.")
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
