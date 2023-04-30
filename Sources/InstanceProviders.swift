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

/// Storage for dependencies configurations.
///
/// To declare a configuration:
/// ```swift
/// extension InstanceProviders {
///     // Configuration "net" of type Networking
///     var net: Injection<Networking> { .init(
///         create: .once,
///         deallocate: .whenLastConsumerLeave,
///         instance: Network()
///     )}
/// }
/// ```
/// - **net** - KeyPath consumers will have to refer to using ``Instance``
/// ```swift
/// @Instance(\.net) var net
/// ```
///
@MainActor public final class InstanceProviders {

    /// `KeyPath` to ``Injection`` in ``InjectionValues``.
    public typealias KeyPath<T> = Swift.KeyPath<InstanceProviders, Injection<T>>

    
    //===------------------------------------------------------------------===//
    // MARK: - Storage
    //===------------------------------------------------------------------===//

    // We can't use subscript to static values in swift as of today.
    // Also we can't have stored properties in extensions.
    // Both combined we need our own static storage
    // and an instance of InstanceProviders.
    // drawbacks: typecast from Any when read value from storage.
    var storage = [AnyKeyPath: Any]()
    static let shared = InstanceProviders()
    static subscript<T>(_ keyPath: KeyPath<T>) -> Injection<T> {
        get {
            shared.configurationCopyingToStorage(keyPath)
        }
    }

    func configurationCopyingToStorage<T>(_ keyPath: KeyPath<T>) -> Injection<T> {
        if let value = storage[keyPath] as? Injection<T> {
            return value
        }
        let value = self[keyPath: keyPath]
        storage[keyPath] = value
        return value
    }


    //===------------------------------------------------------------------===//
    // MARK: - Override
    //===------------------------------------------------------------------===//

    /// Overrides ``Injection`` configuration.
    /// - Parameters:
    ///   - keyPath: ``InstanceProviders/KeyPath`` to value.
    ///   - create: Override ``InstantiationStrategy`` if not nil.
    ///   - deallocate: Override ``DeallocationStrategy`` if not nil.
    ///   - instance: A closure to call with original instance
    ///   that returns overridden instance.
    public static func override<O>(
        _ keyPath: InstanceProviders.KeyPath<O>,
        create: InstantiationStrategy? = nil,
        deallocate: DeallocationStrategy? = nil,
        instance: @escaping (() -> O) -> O,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        let config = InstanceProviders[keyPath]
        let overridden = Injection(
            create: create ?? config.instantiationStrategy,
            deallocate: deallocate ?? config.deallocationStrategy,
            instance: instance(config.instance)
        )
        config.overridden = overridden
    }
}
