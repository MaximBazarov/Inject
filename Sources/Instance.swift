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


/// A property wrapper that enables dependency injection for a specified instance.
///
/// The Instance property wrapper retrieves an instance of the specified type from its
/// associated ``Injection``.
/// The retrieved instance is determined by the injection's configuration.
///
/// Usage:
/// ```swift
/// @Instance(networking) var network
/// ```
/// where `networking` is the ``Injection`` instance.
@MainActor @propertyWrapper public final class Instance<O> {

    // The associated Injection instance responsible for providing the instance of type O.
    let injection: Injection<O>

    /// The context in which the property wrapper is used.
    let context: Context

    // Local storage of the instance.
    var localInstance: O?

    public var wrappedValue: O {
        get {
            injection.getInstance(for: self, context: context)
        }
        set {
            logger.log(injection: injection, overriddenLocally: newValue, context: context)
            localInstance = newValue
        }
    }

    /// Initializes a new `Instance` property wrapper with the given `Injection` instance.
    ///
    /// - Parameters:
    ///   - injection: The associated `Injection` instance responsible for providing the instance of type `O`.
    ///   - file: The source file where the operation takes place. Defaults to the calling function's file.
    ///   - fileID: The unique identifier of the source file. Defaults to the calling function's file ID.
    ///   - line: The line number within the source file where the operation takes place. Defaults to the calling function's line number.
    ///   - column: The column number within the source file where the operation takes place. Defaults to the calling function's column number.
    ///   - function: The name of the function where the operation takes place. Defaults to the calling function's name.
    public init(
        _ injection: Injection<O>,
        file: String = #file,
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        function: String = #function
    ) {
        self.injection = injection
        self.context = Context(
            file: file,
            line: line,
            column: column,
            function: function
        )
    }
}
