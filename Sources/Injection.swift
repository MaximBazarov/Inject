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
    let instantiationStrategy: InstantiationStrategy
    let deallocationStrategy: DeallocationStrategy
    let instance: () -> O

    // Storage
    var sharedInstance: O?
    weak var sharedNonretainingInstance: AnyObject?

    var overridden: Injection<O>?

    /// Configure the injection of the dependency object.
    /// - Parameters:
    ///   - create: ``InstantiationStrategy``
    ///   - deallocate: ``DeallocationStrategy``
    ///   - instance: an instance of the object.
    ///   Will be used or not depending on the `strategy` and `storage`
    public init(
        create: InstantiationStrategy,
        deallocate: DeallocationStrategy,
        instance: @escaping @autoclosure () -> O
    ) {
        self.instantiationStrategy = create
        self.deallocationStrategy = deallocate
        self.instance = instance
    }

    func getInstance(for consumer: Instance<O>, context: Context) -> O {
        if let overridden {
            return overridden.getInstance(for: consumer, context: context)
        }

        // If we have instance directly injected, return right away.
        if let localInstance = consumer.localInstance { return localInstance }

        // resolve on consumer
        if instantiationStrategy == .onConsumer {
            let value = consumer.localInstance ?? instance()
            consumer.localInstance = value
            return value
        }


        // resolve shared
        switch deallocationStrategy {
        case .neverDeallocated:
            let new = sharedInstance ?? instance()
            sharedInstance = new
            return new
        case .whenLastConsumerLeave:
            let new = sharedNonretainingInstance as? O ?? instance()
            sharedNonretainingInstance = new as AnyObject
            return new
        }
    }
}
