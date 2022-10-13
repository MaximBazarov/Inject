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

/// Adds ``injecting(_:for:)`` to enable ``Dependency`` overriding.
public protocol Injectable {}

public extension Injectable {
    
    /// Replaces the instance of the `Value` for given ``Injected`` property.
    ///
    /// - Parameters:
    ///   - newValue: A value to replace with.
    ///   - keyPath: Key path to the ``Injected`` property.
    /// - Returns: An instance of the dependency of type `Value`
    @MainActor func injecting<Value>(
        _ newValue: Value,
        for keyPath: KeyPath<Self, Dependency<Value>>
    ) -> Self {
        let dependency = self[keyPath: keyPath]
        dependency.override(with: newValue)
        return self
    }
}

