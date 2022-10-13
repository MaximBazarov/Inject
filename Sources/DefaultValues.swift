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

/// Provides an interface to extend with computed properties.
/// Each computed property provides a name to reference in ``Injected``
/// and a type for enclosed ``Dependency``.
/// ```swift
/// extension DefaultValues {
///     var testService: TestServiceInterface { TestService() }
/// }
/// ```
///> Warning:
/// **Never use the @Injected inside another @Injected**
/// it will create a cycle and your application will hang and
/// then possibly killed by the system.
/// ```swift
/// var auth: Auth {
///     @Injected(\.network) var network // DON'T
///     Auth(network: network.instance)
/// }
///
/// var network: Networking {
///     @Injected(\.auth) var auth // DON'T
///     Networking(auth: auth.instance)
/// }
/// ```
/// Instead, move the dependency from the initializer into the injected property.
/// ```swift
/// final class Networking {
///   @Injected(\.auth) var auth
/// }
///
/// final class Auth {
///   @Injected(\.network) var network
/// }
/// ```
/// now you can remove them from initializer and can safely resolve this cross dependency.
/// ```swift
/// extension DefaultValues {
///     var auth: Auth { Auth() }
///     var network: Networking { Networking() }
/// }
/// ```
@MainActor
public final class DefaultValues {
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
            hasher.combine(ObjectIdentifier(storageKeyPath))
            if let dependencyKey {
                hasher.combine(dependencyKey)
            }
        }
        
        typealias ID = ObjectIdentifier
        static func == (lhs: DefaultValues.StorageID, rhs: DefaultValues.StorageID) -> Bool {
            let equalIDs = ID(lhs.storageKeyPath) == ID(rhs.storageKeyPath)
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

