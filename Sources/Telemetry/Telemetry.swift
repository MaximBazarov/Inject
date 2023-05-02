//===----------------------------------------------------------------------===//
//
// This source file is part of the Inject package open source project
//
// Copyright (c) 2023 Maxim Bazarov and the Inject package
// open source project authors
// Licensed under MIT
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation
import OSLog

@MainActor var logger: Telemetry = OSLogTelemetry()

/// Sets the logging system for the Inject library.
@MainActor public func setLogger(_ new: Telemetry) {
    logger = new
}

public protocol Telemetry {
    /// Injection returns the instance from its storage.
    /// - Parameters:
    ///   - injection: Injection that returned
    ///   - instance: instance that was returned
    ///   - isOverride: True if that was overridden injection.
    ///   - isRetaining: True if instance was from a retaining storage.
    ///   - context: context from where the instance was requested.
    func log<O>(injection: Injection<O>, returnedInstanceFromStorage instance: O, isOverride: Bool, isRetaining: Bool, context: Context)


    /// Local instance was returned to the consumer
    /// - Parameters:
    ///   - injection: injection that was used to request the instance.
    ///   - instance: instance that was returned
    ///   - context: context from where the instance was requested.
    func log<O>(injection: Injection<O>, returnedLocalInstance instance: O, context: Context)


    /// Injection was overridden.
    /// - Parameters:
    ///   - injection: injection that was overridden.
    ///   - override: a new injection it was overridden with.
    ///   - context: context where override was initiated from.
    func log<O>(injection: Injection<O>, overridden override: Injection<O>)


    /// Override of injection was removed.
    /// - Parameters:
    ///   - injection: injection for which override has been removed.
    ///   - override: override that has been removed.
    ///   - context: context from where the rollback called.
    func log<O>(injection: Injection<O>, removedOverride override: Injection<O>, context: Context)


    /// Overridden locally
    /// - Parameters:
    ///   - injection: injection that was overridden.
    ///   - override: a new injection it was overridden with.
    ///   - context: context where override was initiated from.
    func log<O>(injection: Injection<O>, overriddenLocally instance: O, context: Context)


    /// Injection called the `instance()` method
    /// - Parameters:
    ///   - injection: injection that called the `instance()` method.
    ///   - instance: returned instance.
    ///   - isOverride: when the injection was an override.
    ///   - context: context from where the instance was requested.
    func log<O>(injection: Injection<O>, createdNewInstance instance: O, isOverride: Bool, context: Context)
}

public final class Silence: Telemetry {
    public func log<O>(injection: Injection<O>, returnedInstanceFromStorage instance: O, isOverride: Bool, isRetaining: Bool, context: Context) {}
    public func log<O>(injection: Injection<O>, returnedLocalInstance instance: O, context: Context) {}
    public func log<O>(injection: Injection<O>, overridden override: Injection<O>) {}
    public func log<O>(injection: Injection<O>, removedOverride override: Injection<O>, context: Context) {}
    public func log<O>(injection: Injection<O>, overriddenLocally instance: O, context: Context) {}
    public func log<O>(injection: Injection<O>, createdNewInstance instance: O, isOverride: Bool, context: Context) {}
}

final class OSLogTelemetry: Telemetry {
    let logger = Logger(subsystem: "im.mks.inject", category: "Inject")

    func log<O>(injection: Injection<O>, createdNewInstance instance: O, isOverride: Bool, context: Context) {
        let override = isOverride ? "(override) " : ""
        logger.debug("created new instance \(ObjectIdentifier(instance as AnyObject).addressOnly), \(override)Injection<\(O.self)>: \(injection.context.debugDescription) Instance: \(context.debugDescription)")
    }

    func log<O>(injection: Injection<O>, returnedInstanceFromStorage instance: O, isOverride: Bool, isRetaining: Bool, context: Context) {
        let override = isOverride ? "(override) " : ""
        logger.debug("returned \(String(describing:instance.self)) \(ObjectIdentifier(instance as AnyObject).addressOnly), \(override)Injection<\(O.self)>: \(injection.context.debugDescription) Instance: \(context.debugDescription)")
    }

    func log<O>(injection: Injection<O>, returnedLocalInstance instance: O, context: Context) {
        logger.debug("returned local instance -> \(ObjectIdentifier(instance as AnyObject).debugDescription), from: \(context.debugDescription)")
    }

    func log<O>(injection: Injection<O>, overridden override: Injection<O>) {
        logger.debug("overridden global -> injection: \(injection.context.debugDescription), override: \(override.context.debugDescription)")
    }

    func log<O>(injection: Injection<O>, overriddenLocally instance: O, context: Context) {
        logger.debug("overridden local instance -> (\(ObjectIdentifier(instance as AnyObject).debugDescription) injection: \(injection.context.debugDescription), from: \(context.debugDescription)")
    }

    func log<O>(injection: Injection<O>, removedOverride override: Injection<O>, context: Context) {
        logger.debug("rolled back -> injection: \(injection.context.debugDescription), from: \(context.debugDescription)")
    }
}

extension ObjectIdentifier {
    var addressOnly: String {
        debugDescription
            .replacingOccurrences(of: "ObjectIdentifier", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "\"", with: "")
    }
}
