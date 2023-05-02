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

/// A configuration of how to provide an instance of the dependency object.
@MainActor public final class Injection<O> {

    // Configuration
    let context: Context
    let strategy: Strategy
    let instance: () -> O

    // Storage
    var sharedInstance: O?
    weak var sharedNonretainingInstance: AnyObject?
    var overridden: Injection<O>?

    /// Configure the injection of the dependency object.
    /// - Parameters:
    ///   - strategy: ``Strategy``
    ///   - instance: an instance of the object.
    ///   Will be used or not depending on the `strategy` and `storage`
    public init(
        strategy: Strategy,
        instance: @escaping @autoclosure () -> O,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        self.context = Context(
            file: file,
            line: line,
            column: column,
            function: function
        )
        self.strategy = strategy
        self.instance = instance
    }

    init(strategy: Strategy,
         instance: @escaping @autoclosure () -> O,
         context: Context
    ) {
        self.strategy = strategy
        self.instance = instance
        self.context = context
    }

    func getInstance(
        for consumer: Instance<O>,
        context: Context,
        isOverride: Bool = false
    ) -> O {
        // If we have instance directly injected, return right away.
        // we must check it before overrides because if it's
        // instantiated already it's better to keep consistency.
        if let localInstance = consumer.localInstance {
            logger.log(injection: self, returnedLocalInstance: localInstance, context: context)
            return localInstance
        }

        if let overridden {
            return overridden.getInstance(for: consumer, context: context, isOverride: true)
        }

        // resolve on consumer
        if strategy.create == .perConsumer {
            let value = instance()
            consumer.localInstance = value
            logger.log(injection: self, returnedLocalInstance: value, context: context)
            return value
        }

        // resolve shared
        switch strategy.destroy {
        case .neverDeallocated:
            if let sharedInstance {
                logger.log(injection: self, returnedInstanceFromStorage: sharedInstance, isOverride: isOverride, isRetaining: true, context: context)
                consumer.localInstance = sharedInstance
                return sharedInstance
            }

            let new = instance()
            logger.log(injection: self, createdNewInstance: new, isOverride: isOverride, context: context)

            sharedInstance = new
            consumer.localInstance = new

            logger.log(injection: self, returnedInstanceFromStorage: new, isOverride: isOverride, isRetaining: true, context: context)
            return new
        case .whenLastConsumerLeave:
            if let sharedInstance = sharedNonretainingInstance as? O {
                logger.log(injection: self, returnedInstanceFromStorage: sharedInstance, isOverride: isOverride, isRetaining: false, context: context)
                consumer.localInstance = sharedInstance
                return sharedInstance
            }

            let new = instance()
            logger.log(injection: self, createdNewInstance: new, isOverride: isOverride, context: context)

            sharedNonretainingInstance = new as AnyObject
            consumer.localInstance = new
            return new
        }
    }
}

//===----------------------------------------------------------------------===//
// MARK: - Override
//===----------------------------------------------------------------------===//

public extension Injection {
    func override(
        with instance: @escaping (O) -> O,
        strategy: Strategy? = nil,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        let context = Context(
            file: file,
            line: line,
            column: column,
            function: function
        )
        let override = Injection<O>(
            strategy: strategy ?? self.strategy,
            instance: instance(self.instance()),
            context: context
        )
        self.overridden = override
        logger.log(injection: self, overridden: override)
    }

    func override(
        with injection: Injection<O>
    ) {
        self.overridden = injection
    }

    func rollbackOverride(
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        let context = Context(
            file: file,
            line: line,
            column: column,
            function: function
        )
        if let overridden = self.overridden {
            logger.log(injection: self, removedOverride: overridden, context: context)
            self.overridden = nil
        }
    }
}
