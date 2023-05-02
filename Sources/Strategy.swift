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

/// ``Injection`` uses Strategy to define the way instances should be created,
/// shared and when they should be deallocated.
public struct Strategy {
    let create: InstantiationStrategy
    let destroy: DeallocationStrategy

    /// The strategy when a new instance should be created
    /// and when one from the ``InstantiationStrategy`` should be used.
    enum InstantiationStrategy {
        /// - **perConsumer** - Each object requesting the dependency
        /// will receive its own instance.
        case perConsumer

        /// - **once** - New instance will be created **once** after
        /// that every consumer will receive that instance.
        case shared
    }

    /// The strategy on when the instance should be deallocated.
    enum DeallocationStrategy {
        /// - **never** - Will not be deallocated
        /// and will stay until the application termination.
        /// Stored on the ``InjectionValues`` storage.
        /// *Won't have any effect when `create:` is `.onConsumer`
        /// since this would cause ghost instances with no access to them*
        case neverDeallocated

        /// - **whenLastConsumerLeave** - Hold by the consumer,
        /// and when the last consumer that holds it deallocated,
        /// it will be also deallocated.
        case whenLastConsumerLeave
    }
}

public extension Strategy {
    /// Instance is shared and never deallocated
    static let singleton = Strategy(create: .shared, destroy: .neverDeallocated)

    /// Instance is shared but deallocates when no one is using(referring) it.
    static let shared = Strategy(create: .shared, destroy: .whenLastConsumerLeave)

    /// A new instance created for every consumer and deallocates when this consumer deallocates.
    static let onDemand = Strategy(create: .perConsumer, destroy: .whenLastConsumerLeave)
}
