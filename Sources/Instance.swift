//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2020-2023 Maxim Bazarov and the Inject package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation


/// Provides an instance of the `Injection`.
@MainActor @propertyWrapper public final class Instance<O> {

    var localInstance: O?
    let keyPath: InstanceProviders.KeyPath<O>
    let context: Context

    public var wrappedValue: O {
        get {
            if let localInstance { return localInstance }
            let value = InstanceProviders[keyPath].getInstance(for: self, context: context)
            localInstance = value // cache to skip resolving
            return value
        }
    }

    public init(
        _ keyPath: InstanceProviders.KeyPath<O>,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        self.keyPath = keyPath
        self.context = Context(
            symbol: Self.self,
            file: file,
            line: line,
            column: column,
            function: function
        )
    }
}

public protocol OverridableInjections {
    @MainActor mutating func inject<Instance>(
        _ newValue: Instance,
        for keyPath: WritableKeyPath<Self, Instance>
    )
}

public extension OverridableInjections {
    @MainActor mutating func inject<Instance>(
        _ newValue: Instance,
        for keyPath: WritableKeyPath<Self, Instance>
    ) {
        self[keyPath: keyPath] = newValue
    }
}
