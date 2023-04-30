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

