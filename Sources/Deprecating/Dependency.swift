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

// MARK: - Public interface
@available(*, deprecated, message: "Inject doesn't use Dependency<Value> any more, please refer to Readme.")
extension Dependency {
    /// An instance of the dependency.
    public var instance: Value {
        if let localValue { return localValue }
        
        let newInstance = getInstance()
        
        if case .local = scope { localValue = newInstance }
        
        return newInstance
    }
}

@available(*, deprecated, message: "Inject doesn't use Dependency<Value> any more, please refer to Readme.")
@MainActor public final class Dependency<Value> {
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

