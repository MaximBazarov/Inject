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


/// Provides an instance of the `Injection`.
@MainActor @propertyWrapper public final class Instance<O> {

    let injection: Injection<O>
    let context: Context

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
