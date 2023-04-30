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

//===----------------------------------------------------------------------===//
// MARK: - Strategies
//===----------------------------------------------------------------------===//

/// The strategy when a new instance should be created
/// and when one from the ``InstantiationStrategy`` should be used.
///
/// - **perConsumer** - Each object requesting the dependency
/// will receive its own instance.
///
/// - **once** - New instance will be created **once** after
/// that every consumer will receive that instance.
///
public enum InstantiationStrategy {
    case onConsumer
    case shared
}


/// The strategy on when the instance should be deallocated.
///
/// - **never** - Will not be deallocated
/// and will stay until the application termination.
/// Stored on the ``InjectionValues`` storage.
/// *Won't have any effect when `create:` is `.onConsumer`
/// since this would cause ghost instances with no access to them*
///
/// - **whenLastConsumerLeave** - Hold by the consumer,
/// and when the last consumer that holds it deallocated,
/// it will be also deallocated.
///
public enum DeallocationStrategy {
    case neverDeallocated
    case whenLastConsumerLeave
}
