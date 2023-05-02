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

@available(*, deprecated, message: "Inject doesn't use DefaultValues any more, please refer to Readme.")
@MainActor public final class DefaultValues {
    public typealias KeyPath<Value> = Swift.KeyPath<DefaultValues, Value>
    
    private static let shared = DefaultValues()
    
    /// Storage for .permanent ``Lifespan``
    private static var permanentStorage = [StorageID: Any]()
    
    /// Storage for .temporary ``Lifespan``
    private static var temporaryStorage = [StorageID: AnyWeakRef]()
    
    static func permanentInstance<Value>(
        for keyPath: KeyPath<Value>,
        scopedTo dependencyKey: DependencyKey? = nil
    ) -> Value {
        let id = StorageID(storageKeyPath: keyPath, dependencyKey: dependencyKey)
        if let value = permanentStorage[id] as? Value { return value }
        
        let newInstance = shared[keyPath: keyPath]
        permanentStorage[id] = newInstance
        return newInstance
    }
    
    static func temporaryInstance<Value>(
        for keyPath: KeyPath<Value>,
        scopedTo dependencyKey: DependencyKey? = nil
    ) -> Value {
        let id = StorageID(storageKeyPath: keyPath, dependencyKey: dependencyKey)
        if let value = temporaryStorage[id]?.value as? Value { return value }
        
        let newInstance = shared[keyPath: keyPath]
        temporaryStorage[id] = AnyWeakRef(newInstance as AnyObject)
        return newInstance
    }
    
    // MARK: - Storage ID
    struct StorageID: Hashable {
        let storageKeyPath: AnyKeyPath
        let dependencyKey: DependencyKey?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(storageKeyPath)
            if let dependencyKey {
                hasher.combine(dependencyKey)
            }
        }
        
        static func == (lhs: DefaultValues.StorageID, rhs: DefaultValues.StorageID) -> Bool {
            let equalIDs = lhs.storageKeyPath == rhs.storageKeyPath
            switch (lhs.dependencyKey, rhs.dependencyKey) {
            case (.none, .none): return equalIDs
            case (.none, .some), (.some, .none): return false
            case let (.some(lhs), .some(rhs)): return equalIDs && (lhs == rhs)
            }
        }
    }
}

// MARK: - Weak Reference
private final class AnyWeakRef {
    weak var value: AnyObject?
    init(_ value: AnyObject?) {
        self.value = value
    }
}

